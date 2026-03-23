-- =============================================================================
-- FILE: 06_stored_procedures.sql  (T-SQL / SQL Server)
-- PURPOSE: Demonstrate Stored Procedure creation and usage patterns in T-SQL
-- TOPICS COVERED:
--   1. Basic stored procedure — no parameters
--   2. Input parameters
--   3. Input + OUTPUT parameter
--   4. Default parameter values
--   5. Stored procedure with a CTE
--   6. Stored procedure with a temp table (#temp)
--   7. Stored procedure with TRY-CATCH error handling
--   8. Stored procedure that calls another procedure (nested exec)
--   9. Stored procedure with a transaction inside
--  10. Dropping / recreating procedures safely
-- =============================================================================

-- ===========================================================================
-- HOUSEKEEPING — drop all demo procedures if they exist
-- ===========================================================================
IF OBJECT_ID('dbo.usp_GetAllProducts',          'P') IS NOT NULL DROP PROCEDURE dbo.usp_GetAllProducts;
IF OBJECT_ID('dbo.usp_GetCustomerOrders',        'P') IS NOT NULL DROP PROCEDURE dbo.usp_GetCustomerOrders;
IF OBJECT_ID('dbo.usp_GetTopProductsByCategory', 'P') IS NOT NULL DROP PROCEDURE dbo.usp_GetTopProductsByCategory;
IF OBJECT_ID('dbo.usp_GetCustomerStats',         'P') IS NOT NULL DROP PROCEDURE dbo.usp_GetCustomerStats;
IF OBJECT_ID('dbo.usp_GetEmployeeHierarchy',     'P') IS NOT NULL DROP PROCEDURE dbo.usp_GetEmployeeHierarchy;
IF OBJECT_ID('dbo.usp_GetMonthlySalesReport',    'P') IS NOT NULL DROP PROCEDURE dbo.usp_GetMonthlySalesReport;
IF OBJECT_ID('dbo.usp_UpdateProductPrice',       'P') IS NOT NULL DROP PROCEDURE dbo.usp_UpdateProductPrice;
IF OBJECT_ID('dbo.usp_ProcessOrder',             'P') IS NOT NULL DROP PROCEDURE dbo.usp_ProcessOrder;
IF OBJECT_ID('dbo.usp_GetSalesRepReport',        'P') IS NOT NULL DROP PROCEDURE dbo.usp_GetSalesRepReport;
IF OBJECT_ID('dbo.usp_PlaceOrderWithPayment',    'P') IS NOT NULL DROP PROCEDURE dbo.usp_PlaceOrderWithPayment;
GO


-- ===========================================================================
-- 1. BASIC STORED PROCEDURE — no parameters
-- Returns the full product catalogue with category names.
-- ===========================================================================
CREATE PROCEDURE dbo.usp_GetAllProducts
AS
BEGIN
    SET NOCOUNT ON;  -- suppress "N rows affected" messages

    SELECT
        p.product_id,
        p.product_name,
        cat.category_name,
        p.price,
        p.cost,
        ROUND(p.price - p.cost, 2)                AS unit_profit,
        p.stock_quantity,
        p.created_at
    FROM products p
    JOIN categories cat ON cat.category_id = p.category_id
    ORDER BY cat.category_name, p.product_name;
END;
GO

-- Execute:
EXEC dbo.usp_GetAllProducts;
GO


-- ===========================================================================
-- 2. INPUT PARAMETERS
-- Returns all orders for a given customer, optionally filtered by status.
-- @status = NULL returns orders in every status.
-- ===========================================================================
CREATE PROCEDURE dbo.usp_GetCustomerOrders
    @customer_id INT,
    @status      NVARCHAR(20) = NULL   -- default: no status filter
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        o.order_id,
        o.order_date,
        o.status,
        o.shipping_city,
        o.shipping_country,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS order_total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.customer_id = @customer_id
      AND (@status IS NULL OR o.status = @status)
    GROUP BY o.order_id, o.order_date, o.status,
             o.shipping_city, o.shipping_country
    ORDER BY o.order_date DESC;
END;
GO

-- Execute examples:
EXEC dbo.usp_GetCustomerOrders @customer_id = 1;                          -- all orders
EXEC dbo.usp_GetCustomerOrders @customer_id = 1, @status = N'delivered';  -- delivered only
GO


-- ===========================================================================
-- 3. INPUT + OUTPUT PARAMETER
-- Returns the top N products in a category and outputs the count via @out_count.
-- ===========================================================================
CREATE PROCEDURE dbo.usp_GetTopProductsByCategory
    @category_name NVARCHAR(100),
    @top_n         INT           = 5,      -- how many products to return
    @out_count     INT           OUTPUT    -- returns actual row count
AS
BEGIN
    SET NOCOUNT ON;

    -- Use a temp table to capture results so we can count them
    SELECT TOP (@top_n)
        p.product_id,
        p.product_name,
        p.price,
        SUM(oi.quantity)                           AS units_sold,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
    INTO #top_products
    FROM products p
    JOIN categories cat ON cat.category_id = p.category_id
    JOIN order_items oi ON oi.product_id   = p.product_id
    WHERE cat.category_name = @category_name
    GROUP BY p.product_id, p.product_name, p.price
    ORDER BY revenue DESC;

    SET @out_count = @@ROWCOUNT;  -- number of rows inserted into #top_products

    SELECT * FROM #top_products ORDER BY revenue DESC;

    DROP TABLE #top_products;
END;
GO

-- Execute and capture the output parameter:
DECLARE @cnt INT;
EXEC dbo.usp_GetTopProductsByCategory
    @category_name = N'Smartphones',
    @top_n         = 3,
    @out_count     = @cnt OUTPUT;
SELECT @cnt AS rows_returned;
GO


-- ===========================================================================
-- 4. DEFAULT PARAMETER VALUES
-- Returns customer lifetime statistics; @min_orders filters low-volume customers.
-- ===========================================================================
CREATE PROCEDURE dbo.usp_GetCustomerStats
    @country    NVARCHAR(100) = NULL,  -- NULL = all countries
    @min_orders INT           = 1      -- only customers with >= N orders
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.customer_id,
        c.first_name + N' ' + c.last_name  AS customer_name,
        c.country,
        COUNT(DISTINCT o.order_id)          AS total_orders,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS lifetime_spend,
        MIN(o.order_date)                   AS first_order,
        MAX(o.order_date)                   AS last_order
    FROM customers c
    JOIN orders o       ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id   = o.order_id
    WHERE (@country IS NULL OR c.country = @country)
    GROUP BY c.customer_id, c.first_name, c.last_name, c.country
    HAVING COUNT(DISTINCT o.order_id) >= @min_orders
    ORDER BY lifetime_spend DESC;
END;
GO

EXEC dbo.usp_GetCustomerStats;                                      -- all customers
EXEC dbo.usp_GetCustomerStats @country = N'USA';                    -- USA only
EXEC dbo.usp_GetCustomerStats @country = N'USA', @min_orders = 2;  -- USA, 2+ orders
GO


-- ===========================================================================
-- 5. STORED PROCEDURE WITH RECURSIVE CTE
-- Builds the employee org chart starting from a given manager_id.
-- @root_employee_id = NULL starts from the top (CEO).
-- ===========================================================================
CREATE PROCEDURE dbo.usp_GetEmployeeHierarchy
    @root_employee_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    WITH org_chart AS (
        -- Anchor: the chosen root (or CEO if NULL)
        SELECT
            employee_id,
            first_name + N' ' + last_name  AS employee_name,
            manager_id,
            0                              AS depth,
            CAST(first_name + N' ' + last_name AS NVARCHAR(500)) AS path
        FROM employees
        WHERE (@root_employee_id IS NULL AND manager_id IS NULL)
           OR (employee_id = @root_employee_id)

        UNION ALL

        SELECT
            e.employee_id,
            e.first_name + N' ' + e.last_name,
            e.manager_id,
            oc.depth + 1,
            CAST(oc.path + N' -> ' + e.first_name + N' ' + e.last_name AS NVARCHAR(500))
        FROM employees e
        JOIN org_chart oc ON oc.employee_id = e.manager_id
    )
    SELECT
        REPLICATE(N'    ', depth) + employee_name AS indented_name,
        depth,
        path
    FROM org_chart
    ORDER BY path
    OPTION (MAXRECURSION 20);
END;
GO

EXEC dbo.usp_GetEmployeeHierarchy;               -- full org chart
EXEC dbo.usp_GetEmployeeHierarchy @root_employee_id = 2;  -- Sales subtree
GO


-- ===========================================================================
-- 6. STORED PROCEDURE WITH A TEMP TABLE
-- Builds a monthly sales report and stores intermediate results in a #temp table.
-- ===========================================================================
CREATE PROCEDURE dbo.usp_GetMonthlySalesReport
    @year INT = NULL   -- NULL = current year
AS
BEGIN
    SET NOCOUNT ON;

    IF @year IS NULL
        SET @year = YEAR(GETDATE());

    -- Build monthly aggregation in a temp table
    SELECT
        YEAR(o.order_date)                          AS report_year,
        MONTH(o.order_date)                         AS report_month,
        FORMAT(o.order_date, 'MMMM')                AS month_name,
        COUNT(DISTINCT o.order_id)                  AS total_orders,
        COUNT(DISTINCT o.customer_id)               AS unique_customers,
        ROUND(SUM(oi.quantity * oi.unit_price), 2)  AS gross_revenue,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100)), 2) AS net_revenue
    INTO #monthly_stats
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE YEAR(o.order_date) = @year
    GROUP BY YEAR(o.order_date), MONTH(o.order_date), FORMAT(o.order_date, 'MMMM');

    -- Return data enriched with month-over-month change
    SELECT
        report_year,
        report_month,
        month_name,
        total_orders,
        unique_customers,
        gross_revenue,
        net_revenue,
        LAG(gross_revenue) OVER (ORDER BY report_month) AS prev_month_revenue,
        ROUND(gross_revenue - LAG(gross_revenue) OVER (ORDER BY report_month), 2) AS mom_change
    FROM #monthly_stats
    ORDER BY report_month;

    DROP TABLE #monthly_stats;
END;
GO

EXEC dbo.usp_GetMonthlySalesReport @year = 2023;
EXEC dbo.usp_GetMonthlySalesReport;  -- current year
GO


-- ===========================================================================
-- 7. TRY-CATCH ERROR HANDLING
-- Updates a product's price; validates input and raises a custom error.
-- ===========================================================================
CREATE PROCEDURE dbo.usp_UpdateProductPrice
    @product_id INT,
    @new_price  DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    -- Input validation
    IF @new_price <= 0
    BEGIN
        RAISERROR(N'Price must be greater than zero. Supplied value: %g', 16, 1, @new_price);
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM products WHERE product_id = @product_id)
    BEGIN
        RAISERROR(N'Product with ID %d does not exist.', 16, 1, @product_id);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE products
        SET    price = @new_price
        WHERE  product_id = @product_id;

        COMMIT TRANSACTION;

        SELECT
            product_id,
            product_name,
            price AS new_price
        FROM products
        WHERE product_id = @product_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Re-raise the error to the caller
        THROW;
    END CATCH;
END;
GO

EXEC dbo.usp_UpdateProductPrice @product_id = 1, @new_price = 1399.00;   -- valid
EXEC dbo.usp_UpdateProductPrice @product_id = 1, @new_price = -50.00;    -- should error
EXEC dbo.usp_UpdateProductPrice @product_id = 999, @new_price = 100.00;  -- non-existent
GO


-- ===========================================================================
-- 8. NESTED PROCEDURE CALL
-- Sales-rep report that internally calls usp_GetCustomerStats for context.
-- ===========================================================================
CREATE PROCEDURE dbo.usp_GetSalesRepReport
    @employee_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate the employee exists and is assigned to Sales
    IF NOT EXISTS (
        SELECT 1
        FROM employees e
        JOIN departments d ON d.department_id = e.department_id
        WHERE e.employee_id = @employee_id
    )
    BEGIN
        RAISERROR(N'Employee %d not found.', 16, 1, @employee_id);
        RETURN;
    END;

    -- Employee profile
    SELECT
        e.employee_id,
        e.first_name + N' ' + e.last_name  AS employee_name,
        d.department_name,
        e.hire_date,
        e.salary
    FROM employees e
    JOIN departments d ON d.department_id = e.department_id
    WHERE e.employee_id = @employee_id;

    -- Order performance summary for this rep
    SELECT
        COUNT(DISTINCT o.order_id)                 AS total_orders,
        COUNT(DISTINCT o.customer_id)              AS unique_customers,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS gross_revenue,
        MIN(o.order_date)                          AS first_order_date,
        MAX(o.order_date)                          AS last_order_date
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.employee_id = @employee_id;

    -- Monthly breakdown
    SELECT
        YEAR(o.order_date)   AS order_year,
        MONTH(o.order_date)  AS order_month,
        COUNT(DISTINCT o.order_id)                 AS orders_count,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.employee_id = @employee_id
    GROUP BY YEAR(o.order_date), MONTH(o.order_date)
    ORDER BY order_year, order_month;
END;
GO

EXEC dbo.usp_GetSalesRepReport @employee_id = 6;
GO


-- ===========================================================================
-- 9. STORED PROCEDURE WITH TRANSACTION
-- Places a new order together with its items as an atomic unit.
-- Demonstrates BEGIN TRAN / COMMIT / ROLLBACK inside a stored procedure.
-- ===========================================================================
CREATE PROCEDURE dbo.usp_PlaceOrderWithPayment
    @customer_id     INT,
    @employee_id     INT,
    @product_id      INT,
    @quantity        INT,
    @payment_method  NVARCHAR(20) = N'credit_card'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;  -- auto-rollback on any error

    DECLARE @order_id      INT;
    DECLARE @unit_price    DECIMAL(10,2);
    DECLARE @order_total   DECIMAL(10,2);
    DECLARE @payment_date  DATE = CAST(GETDATE() AS DATE);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Fetch current product price
        SELECT @unit_price = price
        FROM products
        WHERE product_id = @product_id;

        IF @unit_price IS NULL
        BEGIN
            RAISERROR(N'Product %d not found.', 16, 1, @product_id);
        END;

        -- Create the order header
        INSERT INTO orders (customer_id, employee_id, order_date, status, shipping_city, shipping_country)
        SELECT
            @customer_id,
            @employee_id,
            @payment_date,
            N'pending',
            c.city,
            c.country
        FROM customers c
        WHERE c.customer_id = @customer_id;

        SET @order_id = SCOPE_IDENTITY();  -- retrieve the new order_id

        -- Add order item
        INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
        VALUES (@order_id, @product_id, @quantity, @unit_price, 0.00);

        -- Calculate total and record payment
        SET @order_total = @unit_price * @quantity;

        INSERT INTO payments (order_id, payment_date, amount, payment_method)
        VALUES (@order_id, @payment_date, @order_total, @payment_method);

        -- Reduce stock
        UPDATE products
        SET    stock_quantity = stock_quantity - @quantity
        WHERE  product_id = @product_id;

        COMMIT TRANSACTION;

        -- Return the new order details
        SELECT @order_id AS new_order_id, @order_total AS total_charged;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- Example call (uses existing customer 1, employee 6, product 3):
EXEC dbo.usp_PlaceOrderWithPayment
    @customer_id    = 1,
    @employee_id    = 6,
    @product_id     = 3,
    @quantity       = 1,
    @payment_method = N'paypal';
GO


-- ===========================================================================
-- 10. CREATE OR ALTER (SQL Server 2016+)
-- Idempotent procedure definition — no need to DROP first.
-- ===========================================================================
CREATE OR ALTER PROCEDURE dbo.usp_GetAllProducts
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.product_id,
        p.product_name,
        cat.category_name,
        p.price,
        p.cost,
        ROUND(p.price - p.cost, 2) AS unit_profit,
        p.stock_quantity,
        p.created_at
    FROM products p
    JOIN categories cat ON cat.category_id = p.category_id
    ORDER BY cat.category_name, p.product_name;
END;
GO

-- Inspect stored procedure metadata using system catalog views
SELECT
    name            AS procedure_name,
    create_date,
    modify_date,
    type_desc
FROM sys.objects
WHERE type = 'P'
  AND schema_id = SCHEMA_ID('dbo')
ORDER BY name;

-- Inspect parameters of a specific procedure
SELECT
    p.name           AS param_name,
    t.name           AS data_type,
    p.max_length,
    p.is_output,
    p.has_default_value,
    p.default_value
FROM sys.parameters p
JOIN sys.types      t ON t.user_type_id = p.user_type_id
JOIN sys.objects    o ON o.object_id    = p.object_id
WHERE o.name = N'usp_GetCustomerOrders'
ORDER BY p.parameter_id;
