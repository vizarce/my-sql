-- =============================================================================
-- FILE: 07_transactions.sql  (T-SQL / SQL Server)
-- PURPOSE: Demonstrate transaction management in T-SQL
-- TOPICS COVERED:
--   1. Basic BEGIN TRANSACTION / COMMIT
--   2. BEGIN TRANSACTION / ROLLBACK on error
--   3. @@TRANCOUNT — nesting level
--   4. SAVE TRANSACTION — savepoints
--   5. SET XACT_ABORT ON — auto-rollback on statement error
--   6. TRY-CATCH with transaction
--   7. Nested transactions using @@TRANCOUNT
--   8. NAMED transactions
--   9. Read-only transaction with isolation levels
--  10. Checking transaction state — sys.dm_tran_active_transactions
-- =============================================================================


-- ===========================================================================
-- 1. BASIC BEGIN TRANSACTION / COMMIT
-- Transfer budget between two departments atomically.
-- ===========================================================================
BEGIN TRANSACTION;

    UPDATE departments
    SET    budget = budget - 50000.00
    WHERE  department_name = N'Sales';

    UPDATE departments
    SET    budget = budget + 50000.00
    WHERE  department_name = N'Engineering';

COMMIT TRANSACTION;

-- Verify the change
SELECT department_name, budget
FROM   departments
WHERE  department_name IN (N'Sales', N'Engineering');
GO


-- ===========================================================================
-- 2. BEGIN TRANSACTION / ROLLBACK — undo on deliberate error
-- Demonstrate rolling back when a business rule is violated.
-- ===========================================================================
BEGIN TRANSACTION;

    -- Step 1: mark the order as cancelled
    UPDATE orders
    SET    status = N'cancelled'
    WHERE  order_id = 50;

    -- Step 2: check if a payment already exists — if so, refuse the cancellation
    IF EXISTS (
        SELECT 1 FROM payments WHERE order_id = 50
    )
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT N'Cancellation refused: payment already recorded for order 50.';
    END
    ELSE
    BEGIN
        COMMIT TRANSACTION;
        PRINT N'Order 50 cancelled successfully.';
    END
GO


-- ===========================================================================
-- 3. @@TRANCOUNT — transaction nesting counter
-- @@TRANCOUNT tracks how deeply nested the current transaction is.
-- Only the outermost COMMIT actually persists data; inner COMMITs just decrement.
-- Only the outermost ROLLBACK (or ROLLBACK TRANSACTION with no savepoint) rolls back everything.
-- ===========================================================================
PRINT N'Before any transaction: @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS NVARCHAR(5));

BEGIN TRANSACTION;                  -- @@TRANCOUNT = 1
    PRINT N'Level 1: ' + CAST(@@TRANCOUNT AS NVARCHAR(5));

    BEGIN TRANSACTION;              -- @@TRANCOUNT = 2
        PRINT N'Level 2: ' + CAST(@@TRANCOUNT AS NVARCHAR(5));

        UPDATE products SET stock_quantity = stock_quantity + 1 WHERE product_id = 1;

    COMMIT TRANSACTION;             -- @@TRANCOUNT back to 1 (does NOT actually commit yet)
    PRINT N'After inner commit: ' + CAST(@@TRANCOUNT AS NVARCHAR(5));

COMMIT TRANSACTION;                 -- @@TRANCOUNT = 0 → data is now permanently committed
PRINT N'After outer commit: ' + CAST(@@TRANCOUNT AS NVARCHAR(5));

-- Undo the test change
UPDATE products SET stock_quantity = stock_quantity - 1 WHERE product_id = 1;
GO


-- ===========================================================================
-- 4. SAVE TRANSACTION — savepoints (partial rollback)
-- SAVE TRANSACTION creates a named savepoint inside the current transaction.
-- ROLLBACK TRANSACTION <name> rolls back only to that savepoint, not the whole TX.
-- ===========================================================================
BEGIN TRANSACTION outer_tx;

    -- Phase 1: update product prices (always committed)
    UPDATE products SET price = price * 1.05 WHERE category_id = 5;  -- Smartphones +5%

    SAVE TRANSACTION after_price_update;   -- ← savepoint

    -- Phase 2: apply experimental stock adjustment (may be rolled back)
    UPDATE products SET stock_quantity = 0 WHERE category_id = 5;

    -- Simulate a business check failure
    IF (SELECT COUNT(*) FROM products WHERE category_id = 5 AND stock_quantity = 0) > 3
    BEGIN
        -- Roll back only phase 2, keep phase 1
        ROLLBACK TRANSACTION after_price_update;
        PRINT N'Stock update rolled back to savepoint; price update kept.';
    END

COMMIT TRANSACTION outer_tx;   -- commit price updates

-- Restore original prices
UPDATE products SET price = price / 1.05 WHERE category_id = 5;
GO


-- ===========================================================================
-- 5. SET XACT_ABORT ON
-- When XACT_ABORT is ON, any run-time error automatically rolls back the
-- entire transaction without requiring explicit CATCH/ROLLBACK code.
-- Recommended practice for stored procedures.
-- ===========================================================================
SET XACT_ABORT ON;

BEGIN TRANSACTION;

    INSERT INTO payments (order_id, payment_date, amount, payment_method)
    VALUES (1, CAST(GETDATE() AS DATE), 100.00, N'credit_card');

    -- This will fail: uq_order_product would be violated if we try inserting
    -- a duplicate (order 1, product 1) — SQL Server auto-rolls back the TX
    -- INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
    -- VALUES (1, 1, 1, 1299.00, 0.00);  -- uncomment to test auto-rollback

COMMIT TRANSACTION;

SET XACT_ABORT OFF;
GO


-- ===========================================================================
-- 6. TRY-CATCH WITH TRANSACTION
-- The recommended pattern for production code:
-- wrap all work in TRY, handle errors in CATCH.
-- ===========================================================================
BEGIN TRY
    BEGIN TRANSACTION;

        -- Simulate a multi-step business operation
        UPDATE employees
        SET    salary = salary * 1.10      -- 10% pay raise
        WHERE  department_id = (
                   SELECT department_id
                   FROM   departments
                   WHERE  department_name = N'Engineering'
               );

        -- Optional: assert the total Engineering salary budget stays below limit
        DECLARE @eng_total DECIMAL(12,2);
        SELECT  @eng_total = SUM(salary)
        FROM    employees
        WHERE   department_id = (
                    SELECT department_id FROM departments
                    WHERE  department_name = N'Engineering'
                );

        IF @eng_total > 200000
        BEGIN
            RAISERROR(N'Engineering payroll budget exceeded: %g', 16, 1, @eng_total);
        END;

    COMMIT TRANSACTION;
    PRINT N'Salary update committed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT N'Transaction rolled back.';
    PRINT N'Error '    + CAST(ERROR_NUMBER()    AS NVARCHAR(10))
        + N': '        + ERROR_MESSAGE();
    PRINT N'Severity ' + CAST(ERROR_SEVERITY()  AS NVARCHAR(5))
        + N', State '  + CAST(ERROR_STATE()     AS NVARCHAR(5));
END CATCH;

-- Restore salaries
UPDATE employees SET salary = salary / 1.10
WHERE department_id = (SELECT department_id FROM departments WHERE department_name = N'Engineering');
GO


-- ===========================================================================
-- 7. NAMED TRANSACTION
-- A transaction can be given a name for clarity; only the outermost name matters.
-- ===========================================================================
BEGIN TRANSACTION order_cancellation;

    UPDATE orders  SET status = N'cancelled'  WHERE order_id = 48;
    DELETE FROM payments WHERE order_id = 48 AND payment_id = 0;  -- no payment for order 48

COMMIT TRANSACTION order_cancellation;
GO


-- ===========================================================================
-- 8. DEADLOCK / ISOLATION LEVELS — READ COMMITTED SNAPSHOT
-- SQL Server supports several transaction isolation levels.
-- SET TRANSACTION ISOLATION LEVEL controls the current session.
-- ===========================================================================

-- READ UNCOMMITTED: reads dirty (uncommitted) data — lowest isolation
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT order_id, status FROM orders WHERE order_id BETWEEN 1 AND 5;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;   -- restore default

-- REPEATABLE READ: prevents non-repeatable reads within the same transaction
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
    SELECT customer_id, country FROM customers WHERE customer_id = 1;
    -- ... other work ...
    SELECT customer_id, country FROM customers WHERE customer_id = 1;  -- same result guaranteed
COMMIT TRANSACTION;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- SNAPSHOT: reads a consistent version of data as of transaction start
-- Requires enabling ALLOW_SNAPSHOT_ISOLATION on the database first:
-- ALTER DATABASE <dbname> SET ALLOW_SNAPSHOT_ISOLATION ON;
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRANSACTION;
    SELECT product_id, price FROM products WHERE category_id = 5;
COMMIT TRANSACTION;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO


-- ===========================================================================
-- 9. IMPLICIT TRANSACTIONS
-- With IMPLICIT_TRANSACTIONS ON every DML/DDL statement auto-begins a TX.
-- Requires explicit COMMIT or ROLLBACK to close it.
-- ===========================================================================
SET IMPLICIT_TRANSACTIONS ON;

UPDATE products SET stock_quantity = stock_quantity + 5 WHERE product_id = 15;
-- @@TRANCOUNT is now 1 — transaction was started automatically

COMMIT TRANSACTION;   -- explicit commit required
PRINT N'Implicit transaction committed.';

SET IMPLICIT_TRANSACTIONS OFF;  -- restore default
GO


-- ===========================================================================
-- 10. INSPECTING ACTIVE TRANSACTIONS
-- Use DMVs to see open transactions in the current session / database.
-- ===========================================================================

-- Active transactions in the current database
SELECT
    at.transaction_id,
    at.name                           AS tran_name,
    at.transaction_begin_time,
    CASE at.transaction_type
        WHEN 1 THEN N'Read/Write'
        WHEN 2 THEN N'Read-Only'
        WHEN 3 THEN N'System'
        WHEN 4 THEN N'Distributed'
    END                               AS tran_type,
    CASE at.transaction_state
        WHEN 0 THEN N'Initializing'
        WHEN 1 THEN N'Initialised'
        WHEN 2 THEN N'Active'
        WHEN 3 THEN N'Ended (read-only)'
        WHEN 4 THEN N'Committed (with DTC)'
        WHEN 5 THEN N'Prepared (with DTC)'
        WHEN 6 THEN N'Committed'
        WHEN 7 THEN N'Rolling Back'
        WHEN 8 THEN N'Rolled Back'
    END                               AS tran_state
FROM sys.dm_tran_active_transactions AS at
JOIN sys.dm_tran_session_transactions AS st
    ON st.transaction_id = at.transaction_id
WHERE st.session_id = @@SPID;   -- limit to the current session

-- Quick check: is there an open transaction?
SELECT @@TRANCOUNT AS open_transaction_count;
