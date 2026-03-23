-- =============================================================================
-- FILE: 05_window_functions.sql  (T-SQL / SQL Server)
-- PURPOSE: Comprehensive examples of Window Functions
-- TOPICS COVERED:
--   1. ROW_NUMBER  — unique sequential row number
--   2. RANK / DENSE_RANK — ranking with and without gaps
--   3. NTILE  — divide rows into buckets (quartiles, deciles)
--   4. Aggregate window functions (SUM, AVG, COUNT, MIN, MAX OVER)
--   5. Running total (cumulative SUM)
--   6. Moving average (sliding window frame)
--   7. LAG / LEAD — access previous / next row
--   8. FIRST_VALUE / LAST_VALUE — boundary values in a window
--   9. PERCENT_RANK / CUME_DIST — relative position in a window
--  10. Partitioned windows — analytics within groups
--  11. Combined example — full analytical report
-- NOTE: T-SQL does NOT support a named WINDOW clause (no WINDOW keyword).
--       Window definitions must be inlined in each OVER() clause.
-- =============================================================================


-- ===========================================================================
-- 1. ROW_NUMBER — unique sequential number, no ties
-- ===========================================================================

-- Assign a sequential row number to products ordered by price (descending)
SELECT
    ROW_NUMBER() OVER (ORDER BY price DESC) AS row_num,
    product_name,
    price
FROM products;

-- Row number within each category (reset per category)
SELECT
    ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) AS rank_in_category,
    category_id,
    product_name,
    price
FROM products
ORDER BY category_id, rank_in_category;

-- Practical use: select only the 3rd–5th most expensive products overall
-- T-SQL approach 1: subquery + WHERE
SELECT *
FROM (
    SELECT
        ROW_NUMBER() OVER (ORDER BY price DESC) AS rn,
        product_name, price
    FROM products
) AS ranked
WHERE rn BETWEEN 3 AND 5;

-- T-SQL approach 2: OFFSET/FETCH (SQL Server 2012+)
SELECT product_name, price
FROM products
ORDER BY price DESC
OFFSET 2 ROWS FETCH NEXT 3 ROWS ONLY;


-- ===========================================================================
-- 2. RANK / DENSE_RANK — handle ties differently
-- ===========================================================================

-- RANK vs DENSE_RANK on product price: see how ties affect numbering
SELECT
    product_name,
    price,
    RANK()       OVER (ORDER BY price DESC) AS rank_with_gaps,
    DENSE_RANK() OVER (ORDER BY price DESC) AS dense_rank_no_gaps
FROM products
ORDER BY price DESC;

-- Top-1 most expensive product in each category (using RANK)
SELECT category_id, product_name, price
FROM (
    SELECT
        category_id,
        product_name,
        price,
        RANK() OVER (PARTITION BY category_id ORDER BY price DESC) AS rnk
    FROM products
) AS ranked
WHERE rnk = 1
ORDER BY category_id;

-- Employee salary rank within their department
SELECT
    e.first_name + N' ' + e.last_name  AS employee_name,
    d.department_name,
    e.salary,
    RANK()       OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS salary_rank,
    DENSE_RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS salary_dense_rank
FROM employees e
JOIN departments d ON d.department_id = e.department_id
ORDER BY d.department_name, salary_rank;


-- ===========================================================================
-- 3. NTILE — divide rows into equal-sized buckets
-- ===========================================================================

-- Divide products into 4 price quartiles
SELECT
    product_name,
    price,
    NTILE(4) OVER (ORDER BY price) AS price_quartile
FROM products
ORDER BY price;

-- Divide employees into salary terciles within each department
SELECT
    e.first_name + N' ' + e.last_name  AS employee_name,
    d.department_name,
    e.salary,
    NTILE(3) OVER (PARTITION BY e.department_id ORDER BY e.salary) AS salary_tercile
FROM employees e
JOIN departments d ON d.department_id = e.department_id
ORDER BY d.department_name, e.salary;


-- ===========================================================================
-- 4. AGGREGATE WINDOW FUNCTIONS — SUM / AVG / COUNT / MIN / MAX OVER
-- ===========================================================================

-- Show each employee's salary alongside department stats (no GROUP BY needed)
SELECT
    e.first_name + N' ' + e.last_name                              AS employee_name,
    d.department_name,
    e.salary,
    COUNT(*)     OVER (PARTITION BY e.department_id)               AS dept_headcount,
    ROUND(AVG(CAST(e.salary AS DECIMAL(10,2)))
                 OVER (PARTITION BY e.department_id), 2)           AS dept_avg_salary,
    SUM(e.salary) OVER (PARTITION BY e.department_id)              AS dept_total_salary,
    MIN(e.salary) OVER (PARTITION BY e.department_id)              AS dept_min_salary,
    MAX(e.salary) OVER (PARTITION BY e.department_id)              AS dept_max_salary,
    ROUND(e.salary - AVG(CAST(e.salary AS DECIMAL(10,2)))
                     OVER (PARTITION BY e.department_id), 2)       AS diff_from_dept_avg
FROM employees e
JOIN departments d ON d.department_id = e.department_id
ORDER BY d.department_name, e.salary DESC;

-- Each order's revenue + customer share of total revenue
SELECT
    o.order_id,
    c.first_name + N' ' + c.last_name                  AS customer_name,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)          AS order_revenue,
    ROUND(SUM(SUM(oi.quantity * oi.unit_price))
          OVER (PARTITION BY o.customer_id), 2)         AS customer_total_revenue,
    ROUND(SUM(SUM(oi.quantity * oi.unit_price))
          OVER (), 2)                                   AS grand_total_revenue
FROM orders o
JOIN customers c     ON c.customer_id = o.customer_id
JOIN order_items oi  ON oi.order_id   = o.order_id
GROUP BY o.order_id, o.customer_id, c.first_name, c.last_name
ORDER BY customer_total_revenue DESC, o.order_id;


-- ===========================================================================
-- 5. RUNNING TOTAL — cumulative SUM with ROWS UNBOUNDED PRECEDING
-- ===========================================================================

-- Cumulative revenue by order date (running total)
SELECT
    o.order_id,
    o.order_date,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)                         AS order_revenue,
    ROUND(SUM(SUM(oi.quantity * oi.unit_price))
          OVER (ORDER BY o.order_date, o.order_id
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS cumulative_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.order_date
ORDER BY o.order_date, o.order_id;

-- Running headcount over hire dates
SELECT
    hire_date,
    employee_id,
    first_name + N' ' + last_name                                  AS employee_name,
    COUNT(*) OVER (ORDER BY hire_date, employee_id
                   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_headcount
FROM employees
ORDER BY hire_date, employee_id;


-- ===========================================================================
-- 6. MOVING AVERAGE — sliding window frame
-- ===========================================================================

-- 3-month moving average of monthly revenue
WITH monthly_revenue AS (
    SELECT
        FORMAT(o.order_date, 'yyyy-MM')            AS sales_month,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY FORMAT(o.order_date, 'yyyy-MM')
)
SELECT
    sales_month,
    revenue,
    ROUND(AVG(CAST(revenue AS DECIMAL(12,2))) OVER (
        ORDER BY sales_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_3m
FROM monthly_revenue
ORDER BY sales_month;


-- ===========================================================================
-- 7. LAG / LEAD — access rows before or after the current row
-- ===========================================================================

-- Month-over-month revenue change using LAG
WITH monthly AS (
    SELECT
        FORMAT(o.order_date, 'yyyy-MM')            AS sales_month,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY FORMAT(o.order_date, 'yyyy-MM')
)
SELECT
    sales_month,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY sales_month)                               AS prev_month_revenue,
    ROUND(revenue - LAG(revenue, 1) OVER (ORDER BY sales_month), 2)           AS mom_diff,
    ROUND(
        (revenue - LAG(revenue, 1) OVER (ORDER BY sales_month))
        / NULLIF(LAG(revenue, 1) OVER (ORDER BY sales_month), 0) * 100
    , 2)                                                                       AS mom_pct_change
FROM monthly
ORDER BY sales_month;

-- Show each employee's previous and next hire within their department
SELECT
    e.first_name + N' ' + e.last_name   AS employee_name,
    d.department_name,
    e.hire_date,
    LAG(e.first_name + N' ' + e.last_name)
        OVER (PARTITION BY e.department_id ORDER BY e.hire_date) AS prev_hired,
    LEAD(e.first_name + N' ' + e.last_name)
        OVER (PARTITION BY e.department_id ORDER BY e.hire_date) AS next_hired
FROM employees e
JOIN departments d ON d.department_id = e.department_id
ORDER BY d.department_name, e.hire_date;


-- ===========================================================================
-- 8. FIRST_VALUE / LAST_VALUE — boundary values in the window
-- ===========================================================================

-- Compare each product's price to the cheapest & most expensive in its category
-- NOTE: T-SQL does not support the WINDOW clause; each OVER() must be inlined.
SELECT
    cat.category_name,
    p.product_name,
    p.price,
    FIRST_VALUE(p.product_name) OVER (
        PARTITION BY p.category_id ORDER BY p.price
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS cheapest_in_category,
    FIRST_VALUE(p.price) OVER (
        PARTITION BY p.category_id ORDER BY p.price
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS cheapest_price,
    LAST_VALUE(p.product_name) OVER (
        PARTITION BY p.category_id ORDER BY p.price
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS most_expensive_in_category
FROM products p
JOIN categories cat ON cat.category_id = p.category_id
ORDER BY cat.category_name, p.price;


-- ===========================================================================
-- 9. PERCENT_RANK / CUME_DIST — relative standing
-- ===========================================================================

-- Relative salary position of each employee across the whole company
SELECT
    first_name + N' ' + last_name        AS employee_name,
    salary,
    ROUND(PERCENT_RANK() OVER (ORDER BY salary) * 100, 2) AS pct_rank,
    ROUND(CUME_DIST()    OVER (ORDER BY salary) * 100, 2) AS cume_dist_pct
FROM employees
ORDER BY salary;

-- Product price percentile within its category
SELECT
    cat.category_name,
    p.product_name,
    p.price,
    ROUND(PERCENT_RANK() OVER (PARTITION BY p.category_id ORDER BY p.price) * 100, 1) AS price_pct_rank,
    ROUND(CUME_DIST()    OVER (PARTITION BY p.category_id ORDER BY p.price) * 100, 1) AS price_cume_dist
FROM products p
JOIN categories cat ON cat.category_id = p.category_id
ORDER BY cat.category_name, p.price;


-- ===========================================================================
-- 10. PARTITIONED WINDOWS — analytics scoped to a group
-- ===========================================================================

-- For each customer, rank their own orders by value (highest first)
SELECT
    c.first_name + N' ' + c.last_name                               AS customer_name,
    o.order_id,
    o.order_date,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)                       AS order_revenue,
    RANK() OVER (
        PARTITION BY o.customer_id
        ORDER BY SUM(oi.quantity * oi.unit_price) DESC
    )                                                                AS customer_order_rank
FROM orders o
JOIN customers c     ON c.customer_id = o.customer_id
JOIN order_items oi  ON oi.order_id   = o.order_id
GROUP BY o.order_id, o.order_date, o.customer_id, c.first_name, c.last_name
ORDER BY customer_name, customer_order_rank;

-- Find each customer's single highest-value order
SELECT *
FROM (
    SELECT
        c.first_name + N' ' + c.last_name                   AS customer_name,
        o.order_id,
        o.order_date,
        ROUND(SUM(oi.quantity * oi.unit_price), 2)           AS order_revenue,
        RANK() OVER (
            PARTITION BY o.customer_id
            ORDER BY SUM(oi.quantity * oi.unit_price) DESC
        )                                                    AS rnk
    FROM orders o
    JOIN customers c     ON c.customer_id = o.customer_id
    JOIN order_items oi  ON oi.order_id   = o.order_id
    GROUP BY o.order_id, o.order_date, o.customer_id, c.first_name, c.last_name
) AS sub
WHERE rnk = 1
ORDER BY order_revenue DESC;


-- ===========================================================================
-- 11. COMBINED ANALYTICAL REPORT — all techniques together
-- ===========================================================================
-- Goal: full product sales dashboard
--   • total units sold & revenue per product
--   • rank by revenue within category
--   • % of category revenue
--   • cumulative revenue within category (sorted by revenue DESC)
--   • revenue compared to previous product in same category

WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        cat.category_name,
        SUM(oi.quantity)                                       AS units_sold,
        ROUND(SUM(oi.quantity * oi.unit_price), 2)             AS revenue
    FROM products p
    JOIN categories cat   ON cat.category_id = p.category_id
    JOIN order_items oi   ON oi.product_id   = p.product_id
    GROUP BY p.product_id, p.product_name, p.category_id, cat.category_name
)
SELECT
    category_name,
    product_name,
    units_sold,
    revenue,
    -- Rank within category (highest revenue first)
    RANK() OVER (PARTITION BY category_id ORDER BY revenue DESC)           AS category_rank,
    -- % share of category revenue
    ROUND(revenue /
          SUM(revenue) OVER (PARTITION BY category_id) * 100, 2)          AS pct_of_category,
    -- Cumulative revenue within category
    ROUND(SUM(revenue) OVER (
        PARTITION BY category_id
        ORDER BY revenue DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2)             AS cumulative_cat_revenue,
    -- Revenue difference vs. previous product in category (by revenue rank)
    ROUND(revenue - LAG(revenue) OVER (
        PARTITION BY category_id ORDER BY revenue DESC), 2)               AS diff_from_prev_in_cat,
    -- Overall company rank
    RANK() OVER (ORDER BY revenue DESC)                                    AS overall_rank
FROM product_sales
ORDER BY category_name, category_rank;
