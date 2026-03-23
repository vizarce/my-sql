-- =============================================================================
-- FILE: 01_ddl_schema.sql  (T-SQL / SQL Server)
-- PURPOSE: Full DDL — Create all tables for the e-commerce learning database
-- DOMAIN:  E-commerce (departments, employees, categories, products,
--          customers, orders, order_items, payments, reviews)
-- ENGINE:  SQL Server 2016+ / Azure SQL Database
-- =============================================================================

-- Drop tables in reverse dependency order so the script is idempotent
-- SQL Server 2016+ supports DROP TABLE IF EXISTS
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
    department_id   INT              NOT NULL IDENTITY(1,1),
    department_name NVARCHAR(100)    NOT NULL,
    location        NVARCHAR(100)    NOT NULL,
    budget          DECIMAL(12, 2)   NOT NULL CONSTRAINT df_dept_budget DEFAULT 0.00,
    CONSTRAINT pk_departments PRIMARY KEY (department_id)
);

-- -----------------------------------------------------------------------------
-- employees
-- Self-referential manager_id enables recursive CTE hierarchy queries.
-- Salary column supports aggregation / window function salary analysis.
-- -----------------------------------------------------------------------------
CREATE TABLE employees (
    employee_id   INT           NOT NULL IDENTITY(1,1),
    first_name    NVARCHAR(50)  NOT NULL,
    last_name     NVARCHAR(50)  NOT NULL,
    email         NVARCHAR(100) NOT NULL,
    hire_date     DATE          NOT NULL,
    salary        DECIMAL(10,2) NOT NULL,
    department_id INT           NOT NULL,
    manager_id    INT               NULL,   -- NULL for top-level (CEO)
    CONSTRAINT pk_employees       PRIMARY KEY (employee_id),
    CONSTRAINT uq_employee_email  UNIQUE      (email),
    CONSTRAINT fk_emp_dept        FOREIGN KEY (department_id) REFERENCES departments (department_id),
    CONSTRAINT fk_emp_manager     FOREIGN KEY (manager_id)    REFERENCES employees   (employee_id)
);

-- -----------------------------------------------------------------------------
-- categories
-- Self-referential parent_category_id supports recursive CTE tree queries.
-- E.g.  Electronics → Phones → Smartphones
-- -----------------------------------------------------------------------------
CREATE TABLE categories (
    category_id        INT           NOT NULL IDENTITY(1,1),
    category_name      NVARCHAR(100) NOT NULL,
    parent_category_id INT               NULL,
    CONSTRAINT pk_categories  PRIMARY KEY (category_id),
    CONSTRAINT fk_cat_parent  FOREIGN KEY (parent_category_id) REFERENCES categories (category_id)
);

-- -----------------------------------------------------------------------------
-- products
-- price vs cost enables profit margin subquery / window analyses.
-- stock_quantity supports inventory aggregation examples.
-- -----------------------------------------------------------------------------
CREATE TABLE products (
    product_id      INT            NOT NULL IDENTITY(1,1),
    product_name    NVARCHAR(200)  NOT NULL,
    category_id     INT            NOT NULL,
    price           DECIMAL(10, 2) NOT NULL,
    cost            DECIMAL(10, 2) NOT NULL,
    stock_quantity  INT            NOT NULL CONSTRAINT df_prod_stock DEFAULT 0,
    created_at      DATE           NOT NULL,
    CONSTRAINT pk_products  PRIMARY KEY (product_id),
    CONSTRAINT fk_prod_cat  FOREIGN KEY (category_id) REFERENCES categories (category_id)
);

-- -----------------------------------------------------------------------------
-- customers
-- registration_date enables cohort / time-series aggregation queries.
-- city / country support geographic GROUP BY examples.
-- -----------------------------------------------------------------------------
CREATE TABLE customers (
    customer_id       INT           NOT NULL IDENTITY(1,1),
    first_name        NVARCHAR(50)  NOT NULL,
    last_name         NVARCHAR(50)  NOT NULL,
    email             NVARCHAR(100) NOT NULL,
    city              NVARCHAR(100) NOT NULL,
    country           NVARCHAR(100) NOT NULL,
    registration_date DATE          NOT NULL,
    CONSTRAINT pk_customers       PRIMARY KEY (customer_id),
    CONSTRAINT uq_customer_email  UNIQUE      (email)
);

-- -----------------------------------------------------------------------------
-- orders
-- T-SQL has no ENUM type — status is modelled as NVARCHAR(20) with a CHECK
-- constraint to enforce the allowed values.
-- employee_id links to the sales rep who processed the order.
-- -----------------------------------------------------------------------------
CREATE TABLE orders (
    order_id         INT           NOT NULL IDENTITY(1,1),
    customer_id      INT           NOT NULL,
    employee_id      INT               NULL,
    order_date       DATE          NOT NULL,
    status           NVARCHAR(20)  NOT NULL
        CONSTRAINT df_order_status  DEFAULT 'pending'
        CONSTRAINT chk_order_status CHECK (status IN ('pending','processing','shipped','delivered','cancelled')),
    shipping_city    NVARCHAR(100)     NULL,
    shipping_country NVARCHAR(100)     NULL,
    CONSTRAINT pk_orders    PRIMARY KEY (order_id),
    CONSTRAINT fk_ord_cust  FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
    CONSTRAINT fk_ord_emp   FOREIGN KEY (employee_id) REFERENCES employees (employee_id)
);

-- -----------------------------------------------------------------------------
-- order_items
-- discount column enables conditional aggregation (net vs gross revenue).
-- Composite of order_id + product_id is the natural business key.
-- -----------------------------------------------------------------------------
CREATE TABLE order_items (
    order_item_id INT            NOT NULL IDENTITY(1,1),
    order_id      INT            NOT NULL,
    product_id    INT            NOT NULL,
    quantity      INT            NOT NULL,
    unit_price    DECIMAL(10, 2) NOT NULL,
    discount      DECIMAL(5, 2)  NOT NULL CONSTRAINT df_oi_discount DEFAULT 0.00,
    CONSTRAINT pk_order_items   PRIMARY KEY (order_item_id),
    CONSTRAINT uq_order_product UNIQUE      (order_id, product_id),
    CONSTRAINT fk_oi_order      FOREIGN KEY (order_id)   REFERENCES orders   (order_id),
    CONSTRAINT fk_oi_product    FOREIGN KEY (product_id) REFERENCES products (product_id)
);

-- -----------------------------------------------------------------------------
-- payments
-- Multiple payments per order model supports partial-payment queries.
-- payment_method stored as NVARCHAR with CHECK constraint (no ENUM in T-SQL).
-- -----------------------------------------------------------------------------
CREATE TABLE payments (
    payment_id     INT            NOT NULL IDENTITY(1,1),
    order_id       INT            NOT NULL,
    payment_date   DATE           NOT NULL,
    amount         DECIMAL(10, 2) NOT NULL,
    payment_method NVARCHAR(20)   NOT NULL
        CONSTRAINT chk_pay_method CHECK (payment_method IN ('credit_card','debit_card','paypal','bank_transfer','cash')),
    CONSTRAINT pk_payments   PRIMARY KEY (payment_id),
    CONSTRAINT fk_pay_order  FOREIGN KEY (order_id) REFERENCES orders (order_id)
);

-- -----------------------------------------------------------------------------
-- reviews
-- rating 1-5 supports AVG / distribution aggregation.
-- JOIN to products + customers enables correlated subquery examples.
-- -----------------------------------------------------------------------------
CREATE TABLE reviews (
    review_id   INT           NOT NULL IDENTITY(1,1),
    product_id  INT           NOT NULL,
    customer_id INT           NOT NULL,
    rating      TINYINT       NOT NULL,
    review_text NVARCHAR(MAX)     NULL,
    review_date DATE          NOT NULL,
    CONSTRAINT pk_reviews    PRIMARY KEY (review_id),
    CONSTRAINT chk_rating    CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT uq_review     UNIQUE  (product_id, customer_id),
    CONSTRAINT fk_rev_prod   FOREIGN KEY (product_id)  REFERENCES products  (product_id),
    CONSTRAINT fk_rev_cust   FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
);
