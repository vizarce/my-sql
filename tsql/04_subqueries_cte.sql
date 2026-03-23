-- =============================================================================
-- FILE: 04_subqueries_cte.sql  (T-SQL / SQL Server)
-- PURPOSE: Comprehensive examples of Subqueries & CTEs
-- TOPICS COVERED:
--   1. Scalar subquery (single value) in SELECT
--   2. Scalar subquery in WHERE
--   3. Correlated subquery (references outer query)
--   4. Subquery in FROM clause (derived table / inline view)
--   5. EXISTS / NOT EXISTS
--   6. IN / NOT IN with subquery
--   7. ALL / ANY comparisons
--   8. Basic CTE (WITH clause)
--   9. Multiple CTEs chained together
--  10. CTE used for DRY aggregation
--  11. Recursive CTE — employee org hierarchy
--  12. Recursive CTE — category tree
-- NOTE: T-SQL recursive CTEs do NOT use the RECURSIVE keyword;
--       recursion is enabled automatically when a CTE references itself.
-- =============================================================================


-- ===========================================================================
-- 1. SCALAR SUBQUERY IN SELECT — embed aggregate as a column
-- ===========================================================================

-- Show each product's price versus the overall average price
SELECT
    product_name,
    price,
    (SELECT ROUND(AVG(price), 2) FROM products)         AS overall_avg_price,
    ROUND(price - (SELECT AVG(price) FROM products), 2) AS diff_from_avg
FROM products
ORDER BY diff_from_avg DESC;

-- Show each order total alongside the customer's lifetime spend
SELECT
    o.order_id,
    o.order_date,
    c.first_name + N' ' + c.last_name          AS customer_name,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)  AS order_total,
    (
        SELECT ROUND(SUM(oi2.quantity * oi2.unit_price), 2)
        FROM orders o2
        JOIN order_items oi2 ON oi2.order_id = o2.order_id
        WHERE o2.customer_id = o.customer_id
    )                                           AS customer_lifetime_spend
FROM orders o
JOIN customers c     ON c.customer_id = o.customer_id
JOIN order_items oi  ON oi.order_id   = o.order_id
GROUP BY o.order_id, o.order_date, c.first_name, c.last_name, o.customer_id
ORDER BY customer_lifetime_spend DESC;


-- ===========================================================================
-- 2. SCALAR SUBQUERY IN WHERE — filter against a computed threshold
-- ===========================================================================

-- Products priced above the overall average
SELECT product_id, product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- Employees earning more than the company-wide average salary
SELECT
    employee_id,
    first_name + N' ' + last_name AS employee_name,
    salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;


-- ===========================================================================
-- 3. CORRELATED SUBQUERY — references a column from the outer query
-- ===========================================================================

-- Products priced above their own category average
SELECT
    p.product_id,
    p.product_name,
    p.price,
    cat.category_name
FROM products p
JOIN categories cat ON cat.category_id = p.category_id
WHERE p.price > (
    SELECT AVG(p2.price)
    FROM products p2
    WHERE p2.category_id = p.category_id   -- references outer p
)
ORDER BY cat.category_name, p.price DESC;

-- Employees earning more than their department's average
SELECT
    e.employee_id,
    e.first_name + N' ' + e.last_name AS employee_name,
    d.department_name,
    e.salary,
    ROUND((SELECT AVG(e2.salary)
           FROM employees e2
           WHERE e2.department_id = e.department_id), 2) AS dept_avg_salary
FROM employees e
JOIN departments d ON d.department_id = e.department_id
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
)
ORDER BY d.department_name, e.salary DESC;

-- Orders where order total is above the customer's own average order value
SELECT
    o.order_id,
    o.order_date,
    c.first_name + N' ' + c.last_name  AS customer_name,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS order_total
FROM orders o
JOIN customers c     ON c.customer_id = o.customer_id
JOIN order_items oi  ON oi.order_id   = o.order_id
GROUP BY o.order_id, o.order_date, c.first_name, c.last_name, o.customer_id
HAVING SUM(oi.quantity * oi.unit_price) > (
    SELECT AVG(sub.order_total)
    FROM (
        SELECT o2.order_id,
               SUM(oi2.quantity * oi2.unit_price) AS order_total
        FROM orders o2
        JOIN order_items oi2 ON oi2.order_id = o2.order_id
        WHERE o2.customer_id = o.customer_id       -- references outer o
        GROUP BY o2.order_id
    ) sub
)
ORDER BY order_total DESC;


-- ===========================================================================
-- 4. SUBQUERY IN FROM — derived table / inline view
-- ===========================================================================

-- Top-5 customers by total spend (derived table approach)
-- T-SQL: wrap in SELECT TOP or use OFFSET/FETCH outside
SELECT TOP 5
    customer_name,
    total_spend,
    total_orders
FROM (
    SELECT
        c.first_name + N' ' + c.last_name      AS customer_name,
        COUNT(DISTINCT o.order_id)              AS total_orders,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_spend
    FROM customers c
    JOIN orders o       ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id   = o.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name
) AS ranked_customers
ORDER BY total_spend DESC;

-- Average monthly revenue across all months (derived table)
-- T-SQL: FORMAT(date, 'yyyy-MM') replaces MySQL DATE_FORMAT(date, '%Y-%m')
SELECT ROUND(AVG(monthly_revenue), 2) AS avg_monthly_revenue
FROM (
    SELECT
        FORMAT(o.order_date, 'yyyy-MM')            AS month,
        SUM(oi.quantity * oi.unit_price)            AS monthly_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY FORMAT(o.order_date, 'yyyy-MM')
) AS monthly_totals;


-- ===========================================================================
-- 5. EXISTS / NOT EXISTS — semi-join and anti-join
-- ===========================================================================

-- Customers who have placed at least one order (semi-join with EXISTS)
SELECT customer_id, first_name, last_name, email
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
)
ORDER BY customer_id;

-- Customers who have NEVER placed an order (anti-join with NOT EXISTS)
SELECT customer_id, first_name, last_name, email, registration_date
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
)
ORDER BY registration_date;

-- Products that have never been ordered
SELECT product_id, product_name, price
FROM products p
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.product_id = p.product_id
)
ORDER BY product_name;


-- ===========================================================================
-- 6. IN / NOT IN WITH SUBQUERY
-- ===========================================================================

-- Orders placed by customers from the USA or UK (IN with subquery)
SELECT o.order_id, o.order_date, o.status, c.country
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.customer_id IN (
    SELECT customer_id
    FROM customers
    WHERE country IN (N'USA', N'UK')
)
ORDER BY o.order_date;

-- Products that have NOT received any reviews (NOT IN approach)
SELECT product_id, product_name, price
FROM products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id
    FROM reviews
)
ORDER BY product_name;


-- ===========================================================================
-- 7. ALL / ANY COMPARISONS
-- ===========================================================================

-- Products more expensive than ALL laptops
SELECT product_id, product_name, price
FROM products
WHERE price > ALL (
    SELECT price
    FROM products
    WHERE category_id = (SELECT category_id FROM categories WHERE category_name = N'Laptops')
)
ORDER BY price;

-- Employees who earn more than AT LEAST ONE person in the Engineering department
SELECT
    employee_id,
    first_name + N' ' + last_name AS employee_name,
    salary
FROM employees
WHERE salary > ANY (
    SELECT e2.salary
    FROM employees e2
    JOIN departments d ON d.department_id = e2.department_id
    WHERE d.department_name = N'Engineering'
)
ORDER BY salary;


-- ===========================================================================
-- 8. BASIC CTE (WITH clause)
-- ===========================================================================

-- CTE: total revenue per customer, then filter to top spenders
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.first_name + N' ' + c.last_name          AS customer_name,
        c.country,
        COUNT(DISTINCT o.order_id)                 AS total_orders,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
    FROM customers c
    JOIN orders o       ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id   = o.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.country
)
SELECT *
FROM customer_revenue
WHERE total_revenue > 2000
ORDER BY total_revenue DESC;


-- CTE: monthly sales, then compare each month to the previous
-- T-SQL: FORMAT() instead of DATE_FORMAT()
WITH monthly_sales AS (
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
    LAG(revenue) OVER (ORDER BY sales_month) AS prev_month_revenue,
    ROUND(revenue - LAG(revenue) OVER (ORDER BY sales_month), 2) AS mom_change
FROM monthly_sales
ORDER BY sales_month;


-- ===========================================================================
-- 9. MULTIPLE CTEs CHAINED TOGETHER
-- ===========================================================================

-- Step 1: compute per-product revenue
-- Step 2: compute per-category revenue
-- Step 3: show each product's share within its category
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS product_rev
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category_id
),
category_revenue AS (
    SELECT
        category_id,
        SUM(product_rev) AS category_rev
    FROM product_revenue
    GROUP BY category_id
)
SELECT
    c.category_name,
    pr.product_name,
    pr.product_rev,
    cr.category_rev,
    ROUND(pr.product_rev / cr.category_rev * 100, 2) AS pct_of_category
FROM product_revenue pr
JOIN category_revenue cr ON cr.category_id = pr.category_id
JOIN categories c         ON c.category_id = pr.category_id
ORDER BY c.category_name, pct_of_category DESC;


-- ===========================================================================
-- 10. CTE FOR DRY AGGREGATION — reuse the same computed set
-- ===========================================================================

-- Compute department salary stats once, then use them twice
WITH dept_stats AS (
    SELECT
        d.department_id,
        d.department_name,
        COUNT(e.employee_id)    AS headcount,
        ROUND(AVG(e.salary), 2) AS avg_salary,
        SUM(e.salary)           AS total_salary
    FROM departments d
    JOIN employees e ON e.department_id = d.department_id
    GROUP BY d.department_id, d.department_name
)
-- Show departments whose avg salary is above the company avg
SELECT
    department_name,
    headcount,
    avg_salary,
    total_salary,
    (SELECT ROUND(AVG(salary), 2) FROM employees) AS company_avg_salary
FROM dept_stats
WHERE avg_salary > (SELECT AVG(salary) FROM employees)
ORDER BY avg_salary DESC;


-- ===========================================================================
-- 11. RECURSIVE CTE — employee organisation hierarchy
-- NOTE: T-SQL does NOT use the RECURSIVE keyword; recursion is automatic.
--       Use MAXRECURSION option to control max depth (0 = unlimited).
-- ===========================================================================

-- Walk the manager → employee tree; output full path and depth
WITH org_chart AS (
    -- Anchor: CEO (no manager)
    SELECT
        employee_id,
        first_name + N' ' + last_name       AS employee_name,
        manager_id,
        0                                    AS depth,
        CAST(first_name + N' ' + last_name AS NVARCHAR(500)) AS path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive: join each employee to their manager row
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
    REPLICATE(N'    ', depth) + employee_name AS indented_name,  -- REPLICATE instead of REPEAT
    depth,
    path
FROM org_chart
ORDER BY path
OPTION (MAXRECURSION 10);  -- safety limit for the recursion depth


-- ===========================================================================
-- 12. RECURSIVE CTE — category tree
-- ===========================================================================

WITH category_tree AS (
    -- Anchor: root categories (no parent)
    SELECT
        category_id,
        category_name,
        parent_category_id,
        0                                          AS depth,
        CAST(category_name AS NVARCHAR(300))       AS full_path
    FROM categories
    WHERE parent_category_id IS NULL

    UNION ALL

    -- Recursive: children
    SELECT
        c.category_id,
        c.category_name,
        c.parent_category_id,
        ct.depth + 1,
        CAST(ct.full_path + N' > ' + c.category_name AS NVARCHAR(300))
    FROM categories c
    JOIN category_tree ct ON ct.category_id = c.parent_category_id
)
SELECT
    REPLICATE(N'  ', depth) + category_name AS indented_category,
    depth,
    full_path
FROM category_tree
ORDER BY full_path
OPTION (MAXRECURSION 10);
