-- =============================================================================
-- FILE: 08_indexes.sql  (T-SQL / SQL Server)
-- PURPOSE: Demonstrate index types, creation, and management in T-SQL
-- TOPICS COVERED:
--   1. Clustered index — definition and creation
--   2. Nonclustered index — basic
--   3. Unique index
--   4. Composite (multi-column) index
--   5. Covering index (INCLUDE columns)
--   6. Filtered index
--   7. Nonclustered columnstore index
--   8. Clustered columnstore index
--   9. Index options: FILLFACTOR, PAD_INDEX, ONLINE, SORT_IN_TEMPDB
--  10. Viewing index metadata (sys.indexes, sys.index_columns)
--  11. Index usage statistics (sys.dm_db_index_usage_stats)
--  12. Fragmentation & maintenance (sys.dm_db_index_physical_stats)
-- NOTE: All indexes can be dropped and recreated — script is idempotent.
-- =============================================================================

-- ===========================================================================
-- HOUSEKEEPING — drop demo indexes if they already exist
-- ===========================================================================
IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.orders')       AND name = N'idx_orders_customer_date')
    DROP INDEX idx_orders_customer_date ON dbo.orders;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.orders')       AND name = N'idx_orders_status')
    DROP INDEX idx_orders_status ON dbo.orders;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.orders')       AND name = N'idx_orders_status_filtered')
    DROP INDEX idx_orders_status_filtered ON dbo.orders;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.order_items')  AND name = N'idx_oi_product_covering')
    DROP INDEX idx_oi_product_covering ON dbo.order_items;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.products')     AND name = N'idx_products_category_price')
    DROP INDEX idx_products_category_price ON dbo.products;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.products')     AND name = N'idx_products_name_unique')
    DROP INDEX idx_products_name_unique ON dbo.products;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.employees')    AND name = N'idx_emp_dept_salary')
    DROP INDEX idx_emp_dept_salary ON dbo.employees;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.payments')     AND name = N'idx_pay_method_date')
    DROP INDEX idx_pay_method_date ON dbo.payments;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.reviews')      AND name = N'idx_reviews_product_rating')
    DROP INDEX idx_reviews_product_rating ON dbo.reviews;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.customers')    AND name = N'idx_customers_country_city')
    DROP INDEX idx_customers_country_city ON dbo.customers;

-- Columnstore indexes (demo table)
IF OBJECT_ID('dbo.order_items_wide', 'U') IS NOT NULL DROP TABLE dbo.order_items_wide;
GO


-- ===========================================================================
-- 1. CLUSTERED INDEX
-- A table can have ONLY ONE clustered index.
-- The clustered index determines the physical storage order of the rows.
-- By default, PRIMARY KEY creates a clustered index.
-- Example: create one explicitly on a non-PK column.
-- ===========================================================================

-- Note: tables in 01_ddl_schema.sql already have clustered PKs.
-- The example below shows the syntax used to create a clustered index
-- on an existing heap (a table without a clustered index):

-- CREATE CLUSTERED INDEX idx_orders_date_clustered
--     ON dbo.orders (order_date ASC);
-- (Commented out because orders already has a clustered PK.)

-- Viewing existing clustered index:
SELECT
    i.name           AS index_name,
    i.type_desc      AS index_type,
    i.is_primary_key,
    i.is_unique,
    STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS key_columns
FROM sys.indexes          i
JOIN sys.index_columns    ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
JOIN sys.columns          c  ON c.object_id  = i.object_id AND c.column_id = ic.column_id
WHERE i.object_id = OBJECT_ID('dbo.orders')
  AND i.type_desc = N'CLUSTERED'
  AND ic.is_included_column = 0
GROUP BY i.name, i.type_desc, i.is_primary_key, i.is_unique;
GO


-- ===========================================================================
-- 2. NONCLUSTERED INDEX — basic single-column
-- Improves lookup speed for queries filtering on that column.
-- ===========================================================================

-- Speeds up: SELECT ... FROM orders WHERE status = 'delivered'
CREATE NONCLUSTERED INDEX idx_orders_status
    ON dbo.orders (status ASC);
GO


-- ===========================================================================
-- 3. UNIQUE INDEX
-- Enforces uniqueness of values; functionally identical to a UNIQUE constraint
-- but created as an explicit index object.
-- ===========================================================================

-- Ensure no two products share the same name
CREATE UNIQUE NONCLUSTERED INDEX idx_products_name_unique
    ON dbo.products (product_name ASC);
GO


-- ===========================================================================
-- 4. COMPOSITE (MULTI-COLUMN) INDEX
-- Column order matters: most selective / most-queried column first.
-- ===========================================================================

-- Optimises: WHERE customer_id = ? ORDER BY order_date DESC
CREATE NONCLUSTERED INDEX idx_orders_customer_date
    ON dbo.orders (customer_id ASC, order_date DESC);
GO

-- Optimises: JOIN / GROUP BY on (department_id, salary)
CREATE NONCLUSTERED INDEX idx_emp_dept_salary
    ON dbo.employees (department_id ASC, salary DESC);
GO

-- Optimises: WHERE category_id = ? ORDER BY price
CREATE NONCLUSTERED INDEX idx_products_category_price
    ON dbo.products (category_id ASC, price ASC);
GO


-- ===========================================================================
-- 5. COVERING INDEX — nonclustered index with INCLUDE columns
-- The INCLUDE columns are stored at the leaf level but are NOT key columns.
-- When all needed columns are in the index (key + include), the query engine
-- can satisfy the query from the index alone — an "index-only scan".
-- ===========================================================================

-- Query this index will cover:
--   SELECT product_id, quantity, unit_price, discount
--   FROM   order_items
--   WHERE  order_id = ?
CREATE NONCLUSTERED INDEX idx_oi_product_covering
    ON dbo.order_items (order_id ASC, product_id ASC)
    INCLUDE (quantity, unit_price, discount);
GO

-- Query covered by the payments index:
--   SELECT order_id, payment_date, amount
--   FROM   payments
--   WHERE  payment_method = ? AND payment_date BETWEEN ? AND ?
CREATE NONCLUSTERED INDEX idx_pay_method_date
    ON dbo.payments (payment_method ASC, payment_date ASC)
    INCLUDE (order_id, amount);
GO


-- ===========================================================================
-- 6. FILTERED INDEX
-- A nonclustered index built over a subset of rows (a WHERE predicate).
-- Smaller than a full index → faster seeks and less maintenance overhead.
-- ===========================================================================

-- Only index "active" orders (not cancelled / delivered)
-- Speeds up: WHERE status IN ('pending','processing','shipped')
CREATE NONCLUSTERED INDEX idx_orders_status_filtered
    ON dbo.orders (status ASC, order_date DESC)
    WHERE status IN (N'pending', N'processing', N'shipped');
GO

-- Index only highly-rated reviews (rating = 4 or 5)
CREATE NONCLUSTERED INDEX idx_reviews_product_rating
    ON dbo.reviews (product_id ASC, rating DESC)
    INCLUDE (customer_id, review_date)
    WHERE rating >= 4;
GO


-- ===========================================================================
-- 7. NONCLUSTERED COLUMNSTORE INDEX
-- Columnstore indexes store data column-by-column (rather than row-by-row),
-- which is highly efficient for analytical / aggregation queries.
-- A NONCLUSTERED columnstore can coexist with a rowstore clustered index.
-- ===========================================================================

-- Add a nonclustered columnstore index to order_items for OLAP queries
CREATE NONCLUSTERED COLUMNSTORE INDEX idx_oi_columnstore
    ON dbo.order_items (order_id, product_id, quantity, unit_price, discount);
GO

-- Drop it afterwards so it doesn't affect other demos
DROP INDEX idx_oi_columnstore ON dbo.order_items;
GO


-- ===========================================================================
-- 8. CLUSTERED COLUMNSTORE INDEX
-- Replaces the traditional clustered (rowstore) index.
-- Best for large fact tables used in data warehouse / analytics workloads.
-- A table can have ONLY ONE clustered index (rowstore or columnstore).
-- Demo table: wide order_items copy for analytics.
-- ===========================================================================

CREATE TABLE dbo.order_items_wide (
    order_item_id INT,
    order_id      INT,
    product_id    INT,
    quantity      INT,
    unit_price    DECIMAL(10,2),
    discount      DECIMAL(5,2),
    order_date    DATE,
    status        NVARCHAR(20),
    customer_id   INT,
    country       NVARCHAR(100)
);

-- Populate from existing data
INSERT INTO dbo.order_items_wide
SELECT
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    oi.quantity,
    oi.unit_price,
    oi.discount,
    o.order_date,
    o.status,
    o.customer_id,
    o.shipping_country
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id;

-- Create a clustered columnstore index — replaces default heap structure
CREATE CLUSTERED COLUMNSTORE INDEX cci_order_items_wide
    ON dbo.order_items_wide;
GO

-- Analytical query that benefits from the columnstore index
SELECT
    country,
    YEAR(order_date)                          AS order_year,
    SUM(quantity * unit_price)                AS gross_revenue,
    SUM(quantity * unit_price * (1 - discount/100)) AS net_revenue,
    COUNT(DISTINCT order_id)                  AS total_orders
FROM dbo.order_items_wide
WHERE status = N'delivered'
GROUP BY country, YEAR(order_date)
ORDER BY country, order_year;
GO


-- ===========================================================================
-- 9. INDEX OPTIONS
-- FILLFACTOR: percentage of each leaf page to fill at index creation.
--   - Lower value (e.g. 70) leaves free space → fewer page splits on INSERT
--   - Higher value (e.g. 90-100) makes reads faster but more splits on INSERT
-- PAD_INDEX: apply FILLFACTOR also to non-leaf (intermediate) pages.
-- ONLINE: allows reads and writes to continue during index build/rebuild.
--   - Only available in SQL Server Enterprise / Developer editions.
-- SORT_IN_TEMPDB: uses tempdb for the sort phase → reduces fragmentation of
--   the target database log.
-- ===========================================================================

-- Recreate the customers index with explicit options
IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.customers') AND name = N'idx_customers_country_city')
    DROP INDEX idx_customers_country_city ON dbo.customers;

CREATE NONCLUSTERED INDEX idx_customers_country_city
    ON dbo.customers (country ASC, city ASC)
    INCLUDE (customer_id, first_name, last_name)
    WITH (
        FILLFACTOR      = 80,   -- leave 20% free on leaf pages
        PAD_INDEX       = ON,   -- apply fill factor to intermediate pages too
        SORT_IN_TEMPDB  = ON,   -- build sort in tempdb
        STATISTICS_NORECOMPUTE = OFF,  -- keep auto-statistics update enabled
        DROP_EXISTING   = OFF,  -- index does not already exist
        ONLINE          = OFF   -- ONLINE = ON requires Enterprise edition
    );
GO

-- REBUILD an index to remove fragmentation (equivalent of OPTIMIZE TABLE in MySQL)
ALTER INDEX idx_orders_customer_date ON dbo.orders REBUILD
    WITH (FILLFACTOR = 85, ONLINE = OFF);
GO

-- REORGANIZE: light defragmentation (online, low-impact, no fill-factor reset)
ALTER INDEX idx_orders_status ON dbo.orders REORGANIZE;
GO

-- Disable / enable an index (disable prevents use but keeps the definition)
ALTER INDEX idx_orders_status ON dbo.orders DISABLE;
ALTER INDEX idx_orders_status ON dbo.orders REBUILD;  -- re-enables and rebuilds
GO

-- Rebuild ALL indexes on a table
ALTER INDEX ALL ON dbo.products REBUILD WITH (FILLFACTOR = 85);
GO


-- ===========================================================================
-- 10. VIEWING INDEX METADATA
-- ===========================================================================

-- All indexes on all user tables in the current database
SELECT
    OBJECT_NAME(i.object_id)      AS table_name,
    i.name                        AS index_name,
    i.type_desc                   AS index_type,
    i.is_unique,
    i.is_primary_key,
    i.filter_definition,          -- non-NULL for filtered indexes
    STRING_AGG(
        CASE ic.is_included_column
            WHEN 0 THEN c.name
            ELSE NULL
        END, ', ')
        WITHIN GROUP (ORDER BY ic.key_ordinal) AS key_columns,
    STRING_AGG(
        CASE ic.is_included_column
            WHEN 1 THEN c.name
            ELSE NULL
        END, ', ')
        WITHIN GROUP (ORDER BY ic.index_column_id) AS included_columns
FROM sys.indexes          i
JOIN sys.index_columns    ic ON ic.object_id = i.object_id
                             AND ic.index_id  = i.index_id
JOIN sys.columns          c  ON c.object_id  = i.object_id
                             AND c.column_id  = ic.column_id
JOIN sys.tables           t  ON t.object_id  = i.object_id
WHERE t.is_ms_shipped = 0       -- exclude system tables
  AND i.type > 0                -- exclude heaps (type = 0)
GROUP BY
    i.object_id,
    i.name,
    i.type_desc,
    i.is_unique,
    i.is_primary_key,
    i.filter_definition
ORDER BY table_name, index_name;
GO


-- ===========================================================================
-- 11. INDEX USAGE STATISTICS
-- sys.dm_db_index_usage_stats shows how often indexes are used since last restart.
-- ===========================================================================

SELECT
    OBJECT_NAME(ius.object_id)        AS table_name,
    i.name                            AS index_name,
    i.type_desc,
    ius.user_seeks,
    ius.user_scans,
    ius.user_lookups,
    ius.user_updates,
    ius.last_user_seek,
    ius.last_user_scan
FROM sys.dm_db_index_usage_stats ius
JOIN sys.indexes                  i  ON i.object_id = ius.object_id
                                     AND i.index_id  = ius.index_id
WHERE ius.database_id = DB_ID()     -- current database only
  AND OBJECT_NAME(ius.object_id) IN (
      N'orders', N'order_items', N'products', N'customers',
      N'employees', N'payments', N'reviews'
  )
ORDER BY table_name, index_name;
GO


-- ===========================================================================
-- 12. FRAGMENTATION & MAINTENANCE
-- sys.dm_db_index_physical_stats shows avg_fragmentation_in_percent.
-- General rule:
--   < 5%  → no action needed
--   5–30% → REORGANIZE (online, low impact)
--   > 30% → REBUILD (more aggressive, faster result)
-- ===========================================================================

SELECT
    OBJECT_NAME(ps.object_id)               AS table_name,
    i.name                                  AS index_name,
    i.type_desc,
    ps.avg_fragmentation_in_percent,
    ps.page_count,
    CASE
        WHEN ps.avg_fragmentation_in_percent < 5  THEN N'No action'
        WHEN ps.avg_fragmentation_in_percent < 30 THEN N'REORGANIZE'
        ELSE                                           N'REBUILD'
    END                                     AS recommended_action
FROM sys.dm_db_index_physical_stats(
         DB_ID(),          -- current database
         NULL,             -- all tables
         NULL,             -- all indexes
         NULL,             -- all partitions
         N'LIMITED'        -- limited mode is fast; use 'DETAILED' for accurate page stats
     ) AS ps
JOIN sys.indexes i ON i.object_id = ps.object_id
                   AND i.index_id  = ps.index_id
WHERE ps.page_count > 10   -- skip tiny indexes
  AND i.type > 0            -- skip heaps
ORDER BY ps.avg_fragmentation_in_percent DESC;
GO

-- Dynamic maintenance script: REBUILD or REORGANIZE based on fragmentation level
DECLARE @sql         NVARCHAR(MAX) = N'';
DECLARE @table_name  SYSNAME;
DECLARE @index_name  SYSNAME;
DECLARE @frag        FLOAT;

DECLARE maint_cursor CURSOR FOR
    SELECT
        OBJECT_NAME(ps.object_id),
        i.name,
        ps.avg_fragmentation_in_percent
    FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, N'LIMITED') ps
    JOIN sys.indexes i ON i.object_id = ps.object_id AND i.index_id = ps.index_id
    WHERE ps.avg_fragmentation_in_percent > 5
      AND ps.page_count > 10
      AND i.type > 0
      AND OBJECT_NAME(ps.object_id) IN (
              N'orders', N'order_items', N'products', N'customers',
              N'employees', N'payments', N'reviews'
          );

OPEN maint_cursor;
FETCH NEXT FROM maint_cursor INTO @table_name, @index_name, @frag;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @frag >= 30
        SET @sql = N'ALTER INDEX ' + QUOTENAME(@index_name)
                 + N' ON dbo.' + QUOTENAME(@table_name)
                 + N' REBUILD WITH (ONLINE = OFF);';
    ELSE
        SET @sql = N'ALTER INDEX ' + QUOTENAME(@index_name)
                 + N' ON dbo.' + QUOTENAME(@table_name)
                 + N' REORGANIZE;';

    PRINT @sql;       -- print first; replace with EXEC(@sql) in production
    FETCH NEXT FROM maint_cursor INTO @table_name, @index_name, @frag;
END;

CLOSE maint_cursor;
DEALLOCATE maint_cursor;
GO
