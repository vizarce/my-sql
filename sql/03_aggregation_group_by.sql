-- =============================================================================
-- FILE: 03_aggregation_group_by.sql
-- PURPOSE: Comprehensive examples of Aggregation Functions & GROUP BY
-- TOPICS COVERED:
--   1. Basic aggregate functions (COUNT, SUM, AVG, MIN, MAX)
--   2. GROUP BY single column
--   3. GROUP BY multiple columns
--   4. HAVING clause
--   5. Aggregate functions with expressions
--   6. Conditional aggregation (CASE inside aggregate)
--   7. GROUP BY with ORDER BY
--   8. COUNT DISTINCT
--   9. GROUP BY with JOINs
--  10. ROLLUP & CUBE (subtotals and grand totals)
-- =============================================================================


-- ===========================================================================
-- 1. BASIC AGGREGATE FUNCTIONS — summary of the entire table
-- ===========================================================================

-- Total number of products
SELECT COUNT(*) AS total_products
FROM products;

-- Total, average, min and max price across all products
SELECT
    COUNT(*)          AS total_products,
    ROUND(AVG(price), 2) AS avg_price,
    MIN(price)           AS min_price,
    MAX(price)           AS max_price,
    SUM(price)           AS sum_of_all_prices
FROM products;

-- Total number of orders and customers with at least one order
SELECT
    COUNT(*)                  AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers_ordered
FROM orders;


-- ===========================================================================
-- 2. GROUP BY — SINGLE COLUMN
-- ===========================================================================

-- Number of products per category
SELECT
    c.category_name,
    COUNT(p.product_id) AS product_count
FROM categories c
LEFT JOIN products p ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY product_count DESC;

-- Number of orders per status
SELECT
    status,
    COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY order_count DESC;

-- Total revenue (gross) per country
SELECT
    o.shipping_country,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS gross_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.shipping_country
ORDER BY gross_revenue DESC;


-- ===========================================================================
-- 3. GROUP BY — MULTIPLE COLUMNS
-- ===========================================================================

-- Orders count and revenue by year and month
SELECT
    YEAR(o.order_date)  AS order_year,
    MONTH(o.order_date) AS order_month,
    COUNT(DISTINCT o.order_id)                             AS orders_count,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)             AS gross_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100)), 2) AS net_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY YEAR(o.order_date), MONTH(o.order_date)
ORDER BY order_year, order_month;

-- Revenue and order count by country and status
SELECT
    o.shipping_country,
    o.status,
    COUNT(DISTINCT o.order_id) AS orders_count,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS gross_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.shipping_country, o.status
ORDER BY o.shipping_country, o.status;


-- ===========================================================================
-- 4. HAVING — Filter on aggregated values
-- ===========================================================================

-- Categories with more than 3 products
SELECT
    c.category_name,
    COUNT(p.product_id) AS product_count
FROM categories c
JOIN products p ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name
HAVING COUNT(p.product_id) > 3
ORDER BY product_count DESC;

-- Customers who placed 3 or more orders
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) >= 3
ORDER BY total_orders DESC;

-- Countries generating more than $2,000 in total revenue
SELECT
    o.shipping_country,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS gross_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.shipping_country
HAVING SUM(oi.quantity * oi.unit_price) > 2000
ORDER BY gross_revenue DESC;


-- ===========================================================================
-- 5. AGGREGATE FUNCTIONS WITH EXPRESSIONS
-- ===========================================================================

-- Gross revenue, net revenue (after discount) and total discount per product
SELECT
    p.product_name,
    SUM(oi.quantity)                                                      AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)                            AS gross_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount / 100)), 2) AS net_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * oi.discount / 100), 2)       AS total_discount
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY net_revenue DESC;

-- Profit margin per category
-- profit = (unit_price - cost) * quantity
SELECT
    cat.category_name,
    ROUND(SUM(oi.quantity * (oi.unit_price - p.cost)), 2) AS total_profit,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)            AS gross_revenue,
    ROUND(
        SUM(oi.quantity * (oi.unit_price - p.cost)) /
        NULLIF(SUM(oi.quantity * oi.unit_price), 0) * 100
    , 2)                                                  AS profit_margin_pct
FROM categories cat
JOIN products p    ON p.category_id  = cat.category_id
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY cat.category_id, cat.category_name
ORDER BY total_profit DESC;


-- ===========================================================================
-- 6. CONDITIONAL AGGREGATION — CASE inside aggregate
-- ===========================================================================

-- Revenue split: delivered vs other statuses, per country
SELECT
    o.shipping_country,
    ROUND(SUM(CASE WHEN o.status = 'delivered'
                   THEN oi.quantity * oi.unit_price ELSE 0 END), 2) AS delivered_revenue,
    ROUND(SUM(CASE WHEN o.status <> 'delivered'
                   THEN oi.quantity * oi.unit_price ELSE 0 END), 2) AS other_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)                       AS total_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.shipping_country
ORDER BY total_revenue DESC;

-- Count of products in each price tier
SELECT
    CASE
        WHEN price < 50    THEN '< $50'
        WHEN price < 200   THEN '$50 – $199'
        WHEN price < 500   THEN '$200 – $499'
        WHEN price < 1000  THEN '$500 – $999'
        ELSE               '$1,000+'
    END                      AS price_tier,
    COUNT(*)                 AS product_count,
    ROUND(AVG(price), 2)     AS avg_price_in_tier
FROM products
GROUP BY price_tier
ORDER BY MIN(price);

-- Employee salary statistics per department
SELECT
    d.department_name,
    COUNT(e.employee_id)         AS headcount,
    ROUND(AVG(e.salary), 2)      AS avg_salary,
    MIN(e.salary)                AS min_salary,
    MAX(e.salary)                AS max_salary,
    ROUND(SUM(e.salary), 2)      AS total_salary_cost,
    COUNT(CASE WHEN e.salary > 7000 THEN 1 END) AS employees_above_7k
FROM departments d
JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY avg_salary DESC;


-- ===========================================================================
-- 7. GROUP BY WITH ORDER BY — sorting by aggregate result
-- ===========================================================================

-- Top 10 best-selling products (by units sold)
SELECT
    p.product_name,
    c.category_name,
    SUM(oi.quantity)                     AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS gross_revenue
FROM products p
JOIN categories c    ON c.category_id  = p.category_id
JOIN order_items oi  ON oi.product_id  = p.product_id
GROUP BY p.product_id, p.product_name, c.category_name
ORDER BY units_sold DESC
LIMIT 10;

-- Bottom 5 performing employees by number of orders handled
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.department_name,
    COUNT(o.order_id) AS orders_handled
FROM employees e
JOIN departments d ON d.department_id = e.department_id
LEFT JOIN orders o ON o.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, d.department_name
ORDER BY orders_handled ASC
LIMIT 5;


-- ===========================================================================
-- 8. COUNT DISTINCT — counting unique values
-- ===========================================================================

-- Number of distinct countries and cities per year
SELECT
    YEAR(order_date)                AS order_year,
    COUNT(DISTINCT shipping_country) AS distinct_countries,
    COUNT(DISTINCT shipping_city)    AS distinct_cities
FROM orders
GROUP BY YEAR(order_date)
ORDER BY order_year;

-- Number of unique products bought per customer
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT oi.product_id)           AS unique_products_bought,
    COUNT(DISTINCT o.order_id)              AS total_orders
FROM customers c
JOIN orders o      ON o.customer_id  = c.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY unique_products_bought DESC;


-- ===========================================================================
-- 9. GROUP BY WITH JOINS — multi-table aggregation
-- ===========================================================================

-- Average product rating and review count per category
SELECT
    cat.category_name,
    COUNT(r.review_id)          AS review_count,
    ROUND(AVG(r.rating), 2)     AS avg_rating,
    MIN(r.rating)               AS min_rating,
    MAX(r.rating)               AS max_rating
FROM categories cat
JOIN products p ON p.category_id = cat.category_id
LEFT JOIN reviews r ON r.product_id = p.product_id
GROUP BY cat.category_id, cat.category_name
ORDER BY avg_rating DESC;

-- Sales rep performance: revenue, orders, average order value
SELECT
    CONCAT(e.first_name, ' ', e.last_name)     AS sales_rep,
    COUNT(DISTINCT o.order_id)                 AS total_orders,
    COUNT(DISTINCT o.customer_id)              AS unique_customers,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS gross_revenue,
    ROUND(AVG(oi.quantity * oi.unit_price), 2) AS avg_item_value
FROM employees e
JOIN orders o       ON o.employee_id  = e.employee_id
JOIN order_items oi ON oi.order_id    = o.order_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY gross_revenue DESC;


-- ===========================================================================
-- 10. ROLLUP — grand totals and sub-totals
-- ===========================================================================

-- Revenue by year → month with grand total row (ROLLUP)
-- Using a CTE first avoids only_full_group_by conflicts with ROLLUP + COALESCE
WITH monthly_rev AS (
    SELECT
        YEAR(o.order_date)                             AS yr,
        MONTH(o.order_date)                            AS mo,
        ROUND(SUM(oi.quantity * oi.unit_price), 2)     AS gross_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY YEAR(o.order_date), MONTH(o.order_date) WITH ROLLUP
)
SELECT
    COALESCE(CAST(yr AS CHAR), 'ALL YEARS')   AS order_year,
    COALESCE(CAST(mo AS CHAR), 'ALL MONTHS')  AS order_month,
    gross_revenue
FROM monthly_rev
ORDER BY yr, mo;

-- Revenue by category with subtotals per parent category (ROLLUP)
WITH cat_rev AS (
    SELECT
        parent.category_name  AS parent_cat,
        child.category_name   AS child_cat,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS gross_revenue
    FROM categories parent
    JOIN categories child ON child.parent_category_id = parent.category_id
    JOIN products p        ON p.category_id           = child.category_id
    JOIN order_items oi    ON oi.product_id           = p.product_id
    GROUP BY parent.category_name, child.category_name WITH ROLLUP
)
SELECT
    COALESCE(parent_cat, 'ALL CATEGORIES') AS parent_category,
    COALESCE(child_cat,  'SUBTOTAL')        AS category,
    gross_revenue
FROM cat_rev
ORDER BY parent_cat, child_cat;
