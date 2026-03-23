-- =============================================================================
-- FILE: 01_ddl_schema.sql
-- PURPOSE: Full DDL — Create all tables for the e-commerce learning database
-- DOMAIN:  E-commerce (departments, employees, categories, products,
--          customers, orders, order_items, payments, reviews)
-- =============================================================================

-- Drop tables in reverse dependency order so the script is idempotent
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

-- -----------------------------------------------------------------------------
-- departments
-- One row per business department (Sales, IT, Warehouse, …)
-- Used for GROUP BY / window function examples with salary bands.
-- -----------------------------------------------------------------------------
CREATE TABLE departments (
    department_id   INT            NOT NULL AUTO_INCREMENT,
    department_name VARCHAR(100)   NOT NULL,
    location        VARCHAR(100)   NOT NULL,
    budget          DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (department_id)
);

-- -----------------------------------------------------------------------------
-- employees
-- Self-referential manager_id enables recursive CTE hierarchy queries.
-- Salary column supports aggregation / window function salary analysis.
-- -----------------------------------------------------------------------------
CREATE TABLE employees (
    employee_id   INT           NOT NULL AUTO_INCREMENT,
    first_name    VARCHAR(50)   NOT NULL,
    last_name     VARCHAR(50)   NOT NULL,
    email         VARCHAR(100)  NOT NULL,
    hire_date     DATE          NOT NULL,
    salary        DECIMAL(10,2) NOT NULL,
    department_id INT           NOT NULL,
    manager_id    INT               NULL,   -- NULL for top-level (CEO)
    PRIMARY KEY (employee_id),
    UNIQUE  KEY uq_employee_email (email),
    FOREIGN KEY fk_emp_dept    (department_id) REFERENCES departments (department_id),
    FOREIGN KEY fk_emp_manager (manager_id)    REFERENCES employees   (employee_id)
);

-- -----------------------------------------------------------------------------
-- categories
-- Self-referential parent_category_id supports recursive CTE tree queries.
-- E.g.  Electronics → Phones → Smartphones
-- -----------------------------------------------------------------------------
CREATE TABLE categories (
    category_id        INT          NOT NULL AUTO_INCREMENT,
    category_name      VARCHAR(100) NOT NULL,
    parent_category_id INT              NULL,
    PRIMARY KEY (category_id),
    FOREIGN KEY fk_cat_parent (parent_category_id) REFERENCES categories (category_id)
);

-- -----------------------------------------------------------------------------
-- products
-- price vs cost enables profit margin subquery / window analyses.
-- stock_quantity supports inventory aggregation examples.
-- -----------------------------------------------------------------------------
CREATE TABLE products (
    product_id      INT            NOT NULL AUTO_INCREMENT,
    product_name    VARCHAR(200)   NOT NULL,
    category_id     INT            NOT NULL,
    price           DECIMAL(10, 2) NOT NULL,
    cost            DECIMAL(10, 2) NOT NULL,
    stock_quantity  INT            NOT NULL DEFAULT 0,
    created_at      DATE           NOT NULL,
    PRIMARY KEY (product_id),
    FOREIGN KEY fk_prod_cat (category_id) REFERENCES categories (category_id)
);

-- -----------------------------------------------------------------------------
-- customers
-- registration_date enables cohort / time-series aggregation queries.
-- city / country support geographic GROUP BY examples.
-- -----------------------------------------------------------------------------
CREATE TABLE customers (
    customer_id       INT          NOT NULL AUTO_INCREMENT,
    first_name        VARCHAR(50)  NOT NULL,
    last_name         VARCHAR(50)  NOT NULL,
    email             VARCHAR(100) NOT NULL,
    city              VARCHAR(100) NOT NULL,
    country           VARCHAR(100) NOT NULL,
    registration_date DATE         NOT NULL,
    PRIMARY KEY (customer_id),
    UNIQUE KEY uq_customer_email (email)
);

-- -----------------------------------------------------------------------------
-- orders
-- status ENUM enables filtering / conditional aggregation examples.
-- employee_id links to the sales rep who processed the order.
-- -----------------------------------------------------------------------------
CREATE TABLE orders (
    order_id         INT          NOT NULL AUTO_INCREMENT,
    customer_id      INT          NOT NULL,
    employee_id      INT              NULL,
    order_date       DATE         NOT NULL,
    status           ENUM('pending','processing','shipped','delivered','cancelled')
                                  NOT NULL DEFAULT 'pending',
    shipping_city    VARCHAR(100)     NULL,
    shipping_country VARCHAR(100)     NULL,
    PRIMARY KEY (order_id),
    FOREIGN KEY fk_ord_cust (customer_id) REFERENCES customers (customer_id),
    FOREIGN KEY fk_ord_emp  (employee_id) REFERENCES employees (employee_id)
);

-- -----------------------------------------------------------------------------
-- order_items
-- discount column enables conditional aggregation (net vs gross revenue).
-- Composite of order_id + product_id is the natural business key.
-- -----------------------------------------------------------------------------
CREATE TABLE order_items (
    order_item_id INT            NOT NULL AUTO_INCREMENT,
    order_id      INT            NOT NULL,
    product_id    INT            NOT NULL,
    quantity      INT            NOT NULL,
    unit_price    DECIMAL(10, 2) NOT NULL,
    discount      DECIMAL(5, 2)  NOT NULL DEFAULT 0.00,
    PRIMARY KEY (order_item_id),
    UNIQUE KEY uq_order_product (order_id, product_id),
    FOREIGN KEY fk_oi_order   (order_id)   REFERENCES orders   (order_id),
    FOREIGN KEY fk_oi_product (product_id) REFERENCES products (product_id)
);

-- -----------------------------------------------------------------------------
-- payments
-- Multiple payments per order model supports partial-payment queries.
-- payment_method enables conditional aggregation examples.
-- -----------------------------------------------------------------------------
CREATE TABLE payments (
    payment_id     INT            NOT NULL AUTO_INCREMENT,
    order_id       INT            NOT NULL,
    payment_date   DATE           NOT NULL,
    amount         DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('credit_card','debit_card','paypal','bank_transfer','cash')
                                  NOT NULL,
    PRIMARY KEY (payment_id),
    FOREIGN KEY fk_pay_order (order_id) REFERENCES orders (order_id)
);

-- -----------------------------------------------------------------------------
-- reviews
-- rating 1-5 supports AVG / distribution aggregation.
-- JOIN to products + customers enables correlated subquery examples.
-- -----------------------------------------------------------------------------
CREATE TABLE reviews (
    review_id   INT  NOT NULL AUTO_INCREMENT,
    product_id  INT  NOT NULL,
    customer_id INT  NOT NULL,
    rating      TINYINT NOT NULL,
    review_text TEXT     NULL,
    review_date DATE NOT NULL,
    PRIMARY KEY (review_id),
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5),
    UNIQUE KEY  uq_review (product_id, customer_id),
    FOREIGN KEY fk_rev_prod (product_id)  REFERENCES products  (product_id),
    FOREIGN KEY fk_rev_cust (customer_id) REFERENCES customers (customer_id)
);
