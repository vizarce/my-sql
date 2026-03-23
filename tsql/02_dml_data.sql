-- =============================================================================
-- FILE: 02_dml_data.sql  (T-SQL / SQL Server)
-- PURPOSE: Seed data — INSERT statements for all tables
-- Run AFTER 01_ddl_schema.sql
-- NOTE: Tables use IDENTITY columns; explicit IDs are set via
--       SET IDENTITY_INSERT <table> ON / OFF so downstream FK references work.
-- =============================================================================

-- =============================================================================
-- departments (8 rows)
-- =============================================================================
SET IDENTITY_INSERT departments ON;
INSERT INTO departments (department_id, department_name, location, budget) VALUES
  (1, N'Sales',       N'Kyiv',    500000.00),
  (2, N'Engineering', N'Lviv',    900000.00),
  (3, N'Marketing',   N'Kyiv',    300000.00),
  (4, N'Warehouse',   N'Odesa',   200000.00),
  (5, N'HR',          N'Kyiv',    150000.00),
  (6, N'Finance',     N'Kyiv',    250000.00),
  (7, N'Support',     N'Kharkiv', 180000.00),
  (8, N'Management',  N'Kyiv',   1200000.00);
SET IDENTITY_INSERT departments OFF;

-- =============================================================================
-- employees (20 rows)
-- Hierarchy: CEO (id=1) → directors → managers → staff
-- =============================================================================
SET IDENTITY_INSERT employees ON;
INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, salary, department_id, manager_id) VALUES
  -- Top management
  ( 1, N'Olena',    N'Kovalenko',  N'o.kovalenko@shop.ua',   '2018-01-10', 15000.00, 8, NULL),
  ( 2, N'Mykola',   N'Shevchenko', N'm.shevchenko@shop.ua',  '2018-03-15',  9500.00, 1, 1),
  ( 3, N'Iryna',    N'Petrenko',   N'i.petrenko@shop.ua',    '2018-05-20', 10200.00, 2, 1),
  ( 4, N'Vasyl',    N'Bondarenko', N'v.bondarenko@shop.ua',  '2018-07-01',  8800.00, 3, 1),
  ( 5, N'Natalia',  N'Tkachenko',  N'n.tkachenko@shop.ua',   '2019-01-12',  7900.00, 5, 1),
  -- Sales team
  ( 6, N'Andriy',   N'Marchenko',  N'a.marchenko@shop.ua',   '2019-03-01',  6500.00, 1, 2),
  ( 7, N'Oksana',   N'Savchenko',  N'o.savchenko@shop.ua',   '2019-06-15',  6200.00, 1, 2),
  ( 8, N'Dmytro',   N'Kravchenko', N'd.kravchenko@shop.ua',  '2020-01-20',  5800.00, 1, 2),
  -- Engineering team
  ( 9, N'Serhiy',   N'Lysenko',    N's.lysenko@shop.ua',     '2019-02-10',  8500.00, 2, 3),
  (10, N'Yulia',    N'Moroz',      N'y.moroz@shop.ua',       '2019-09-05',  8000.00, 2, 3),
  (11, N'Pavlo',    N'Karpenko',   N'p.karpenko@shop.ua',    '2020-03-12',  7500.00, 2, 9),
  (12, N'Alina',    N'Voronova',   N'a.voronova@shop.ua',    '2020-07-22',  7200.00, 2, 9),
  -- Marketing team
  (13, N'Roman',    N'Hrytsenko',  N'r.hrytsenko@shop.ua',   '2020-02-14',  6000.00, 3, 4),
  (14, N'Kateryna', N'Zinchenko',  N'k.zinchenko@shop.ua',   '2020-08-18',  5700.00, 3, 4),
  -- Warehouse team
  (15, N'Ivan',     N'Polishchuk', N'i.polishchuk@shop.ua',  '2019-11-01',  5000.00, 4, 1),
  (16, N'Larysa',   N'Sydorenko',  N'l.sydorenko@shop.ua',   '2020-04-10',  4800.00, 4, 15),
  -- Finance team
  (17, N'Halyna',   N'Kuzyk',      N'h.kuzyk@shop.ua',       '2019-04-23',  7100.00, 6, 1),
  (18, N'Bohdan',   N'Romaniuk',   N'b.romaniuk@shop.ua',    '2021-01-11',  6300.00, 6, 17),
  -- Support team
  (19, N'Tetiana',  N'Bilous',     N't.bilous@shop.ua',      '2021-05-03',  5200.00, 7, 1),
  (20, N'Volodymyr',N'Savchuk',    N'v.savchuk@shop.ua',     '2022-02-28',  5100.00, 7, 19);
SET IDENTITY_INSERT employees OFF;

-- =============================================================================
-- categories (12 rows — 2-level hierarchy)
-- =============================================================================
SET IDENTITY_INSERT categories ON;
INSERT INTO categories (category_id, category_name, parent_category_id) VALUES
  -- Root categories
  ( 1, N'Electronics',      NULL),
  ( 2, N'Clothing',         NULL),
  ( 3, N'Home & Garden',    NULL),
  ( 4, N'Books',            NULL),
  -- Electronics sub-categories
  ( 5, N'Smartphones',      1),
  ( 6, N'Laptops',          1),
  ( 7, N'Tablets',          1),
  ( 8, N'Accessories',      1),
  -- Clothing sub-categories
  ( 9, N'Men''s Clothing',  2),
  (10, N'Women''s Clothing',2),
  -- Home & Garden sub-categories
  (11, N'Kitchen',          3),
  (12, N'Garden Tools',     3);
SET IDENTITY_INSERT categories OFF;

-- =============================================================================
-- products (30 rows)
-- =============================================================================
SET IDENTITY_INSERT products ON;
INSERT INTO products (product_id, product_name, category_id, price, cost, stock_quantity, created_at) VALUES
  -- Smartphones (cat 5)
  ( 1, N'iPhone 15 Pro',           5,  1299.00,  850.00,  80, '2023-09-20'),
  ( 2, N'Samsung Galaxy S24',      5,  1099.00,  700.00, 120, '2024-01-15'),
  ( 3, N'Google Pixel 8',          5,   799.00,  500.00,  60, '2023-10-12'),
  ( 4, N'Xiaomi 14 Pro',           5,   699.00,  420.00,  90, '2024-02-01'),
  -- Laptops (cat 6)
  ( 5, N'MacBook Pro 14"',         6,  2499.00, 1600.00,  40, '2023-11-01'),
  ( 6, N'Dell XPS 15',             6,  1799.00, 1100.00,  55, '2023-08-10'),
  ( 7, N'Lenovo ThinkPad X1',      6,  1599.00, 1000.00,  70, '2024-01-20'),
  ( 8, N'ASUS ZenBook 14',         6,  1099.00,  700.00,  85, '2024-02-10'),
  -- Tablets (cat 7)
  ( 9, N'iPad Pro 12.9"',          7,  1199.00,  750.00,  50, '2023-11-10'),
  (10, N'Samsung Galaxy Tab S9',   7,   849.00,  520.00,  65, '2024-01-08'),
  (11, N'Lenovo Tab P12',          7,   499.00,  300.00, 100, '2024-03-01'),
  -- Accessories (cat 8)
  (12, N'AirPods Pro',             8,   279.00,  140.00, 200, '2023-09-20'),
  (13, N'Samsung Galaxy Buds2',    8,   149.00,   70.00, 180, '2024-01-15'),
  (14, N'Logitech MX Master 3',    8,    99.00,   45.00, 150, '2023-07-01'),
  (15, N'USB-C Hub 7-in-1',        8,    49.00,   18.00, 300, '2023-06-15'),
  -- Men''s Clothing (cat 9)
  (16, N'Men''s Classic T-Shirt',  9,    29.00,    8.00, 500, '2023-01-01'),
  (17, N'Men''s Slim Jeans',       9,    79.00,   28.00, 250, '2023-01-15'),
  (18, N'Men''s Leather Jacket',   9,   299.00,  120.00,  80, '2023-02-01'),
  -- Women''s Clothing (cat 10)
  (19, N'Women''s Running Shoes',  10,  149.00,   60.00, 120, '2023-02-15'),
  (20, N'Women''s Summer Dress',   10,   59.00,   20.00, 200, '2023-03-01'),
  (21, N'Women''s Yoga Pants',     10,   69.00,   25.00, 180, '2023-03-15'),
  (22, N'Women''s Blazer',         10,  199.00,   80.00,  90, '2023-04-01'),
  -- Kitchen (cat 11)
  (23, N'Coffee Maker Deluxe',     11,  129.00,   55.00,  70, '2023-04-15'),
  (24, N'Instant Pot 8qt',         11,  119.00,   50.00,  85, '2023-05-01'),
  (25, N'KitchenAid Stand Mixer',  11,  449.00,  220.00,  35, '2023-05-15'),
  (26, N'Air Fryer XL',            11,   99.00,   40.00, 110, '2023-06-01'),
  -- Garden Tools (cat 12)
  (27, N'Garden Hose 50ft',        12,   79.00,   30.00, 150, '2023-06-15'),
  (28, N'Garden Hose Premium',     12,   45.00,   15.00, 200, '2023-07-01'),
  (29, N'Cordless Lawn Mower',     12,  349.00,  180.00,  25, '2023-07-15'),
  (30, N'Pruning Shears Pro',      12,   35.00,   12.00, 300, '2023-08-01');
SET IDENTITY_INSERT products OFF;

-- =============================================================================
-- customers (25 rows)
-- =============================================================================
SET IDENTITY_INSERT customers ON;
INSERT INTO customers (customer_id, first_name, last_name, email, city, country, registration_date) VALUES
  ( 1, N'Alice',   N'Johnson',   N'alice.j@mail.com',    N'New York',  N'USA',     '2022-01-15'),
  ( 2, N'Bob',     N'Smith',     N'bob.s@mail.com',      N'London',    N'UK',      '2022-02-10'),
  ( 3, N'Carol',   N'Williams',  N'carol.w@mail.com',    N'Toronto',   N'Canada',  '2022-03-05'),
  ( 4, N'David',   N'Brown',     N'david.b@mail.com',    N'Sydney',    N'Australia','2022-03-20'),
  ( 5, N'Eva',     N'Jones',     N'eva.j@mail.com',      N'Berlin',    N'Germany', '2022-04-12'),
  ( 6, N'Frank',   N'Garcia',    N'frank.g@mail.com',    N'Madrid',    N'Spain',   '2022-05-08'),
  ( 7, N'Grace',   N'Miller',    N'grace.m@mail.com',    N'Paris',     N'France',  '2022-06-01'),
  ( 8, N'Henry',   N'Davis',     N'henry.d@mail.com',    N'Chicago',   N'USA',     '2022-06-20'),
  ( 9, N'Iris',    N'Martinez',  N'iris.m@mail.com',     N'Barcelona', N'Spain',   '2022-07-15'),
  (10, N'Jack',    N'Wilson',    N'jack.w@mail.com',     N'Melbourne', N'Australia','2022-08-03'),
  (11, N'Kate',    N'Anderson',  N'kate.a@mail.com',     N'Vancouver', N'Canada',  '2022-08-25'),
  (12, N'Leo',     N'Taylor',    N'leo.t@mail.com',      N'Munich',    N'Germany', '2022-09-10'),
  (13, N'Maria',   N'Thomas',    N'maria.t@mail.com',    N'Rome',      N'Italy',   '2022-10-01'),
  (14, N'Nick',    N'Jackson',   N'nick.j@mail.com',     N'Amsterdam', N'Netherlands','2022-10-18'),
  (15, N'Olivia',  N'White',     N'olivia.w@mail.com',   N'Los Angeles',N'USA',    '2022-11-05'),
  (16, N'Paul',    N'Harris',    N'paul.h@mail.com',     N'Houston',   N'USA',     '2022-11-22'),
  (17, N'Quinn',   N'Martin',    N'quinn.m@mail.com',    N'Dublin',    N'Ireland', '2022-12-10'),
  (18, N'Rachel',  N'Thompson',  N'rachel.t@mail.com',   N'Warsaw',    N'Poland',  '2023-01-05'),
  (19, N'Sam',     N'Garcia',    N'sam.g@mail.com',      N'Kyiv',      N'Ukraine', '2023-01-20'),
  (20, N'Tina',    N'Martinez',  N'tina.m@mail.com',     N'Lisbon',    N'Portugal','2023-02-08'),
  (21, N'Uma',     N'Robinson',  N'uma.r@mail.com',      N'Prague',    N'Czech Republic','2023-03-01'),
  (22, N'Victor',  N'Clark',     N'victor.c@mail.com',   N'Vienna',    N'Austria', '2023-03-15'),
  (23, N'Wendy',   N'Lewis',     N'wendy.l@mail.com',    N'Brussels',  N'Belgium', '2023-04-02'),
  (24, N'Xander',  N'Lee',       N'xander.l@mail.com',   N'Seoul',     N'South Korea','2023-04-20'),
  (25, N'Yara',    N'Walker',    N'yara.w@mail.com',     N'Stockholm', N'Sweden',  '2023-05-10');
SET IDENTITY_INSERT customers OFF;

-- =============================================================================
-- orders (50 rows)
-- =============================================================================
SET IDENTITY_INSERT orders ON;
INSERT INTO orders (order_id, customer_id, employee_id, order_date, status, shipping_city, shipping_country) VALUES
  ( 1,  1,  6, '2023-01-03', N'delivered',   N'New York',   N'USA'),
  ( 2,  2,  7, '2023-01-10', N'delivered',   N'London',     N'UK'),
  ( 3,  3,  6, '2023-01-18', N'delivered',   N'Toronto',    N'Canada'),
  ( 4,  4,  8, '2023-01-28', N'delivered',   N'Sydney',     N'Australia'),
  ( 5,  5,  6, '2023-02-05', N'delivered',   N'Berlin',     N'Germany'),
  ( 6,  6,  7, '2023-02-20', N'delivered',   N'Madrid',     N'Spain'),
  ( 7,  7,  6, '2023-03-01', N'delivered',   N'Paris',      N'France'),
  ( 8,  8,  8, '2023-03-12', N'delivered',   N'Chicago',    N'USA'),
  ( 9,  9,  7, '2023-03-22', N'delivered',   N'Barcelona',  N'Spain'),
  (10, 10,  6, '2023-04-08', N'delivered',   N'Melbourne',  N'Australia'),
  (11, 11,  7, '2023-04-20', N'delivered',   N'Vancouver',  N'Canada'),
  (12, 12,  8, '2023-05-05', N'delivered',   N'Munich',     N'Germany'),
  (13, 13,  6, '2023-05-18', N'delivered',   N'Rome',       N'Italy'),
  (14, 14,  7, '2023-06-01', N'delivered',   N'Amsterdam',  N'Netherlands'),
  (15, 15,  6, '2023-06-15', N'delivered',   N'Los Angeles',N'USA'),
  (16, 16,  8, '2023-07-01', N'delivered',   N'Houston',    N'USA'),
  (17, 17,  7, '2023-07-14', N'delivered',   N'Dublin',     N'Ireland'),
  (18, 18,  6, '2023-07-28', N'delivered',   N'Warsaw',     N'Poland'),
  (19, 19,  8, '2023-08-10', N'delivered',   N'Kyiv',       N'Ukraine'),
  (20, 20,  7, '2023-08-22', N'delivered',   N'Lisbon',     N'Portugal'),
  (21, 21,  6, '2023-09-05', N'delivered',   N'Prague',     N'Czech Republic'),
  (22, 22,  8, '2023-09-18', N'delivered',   N'Vienna',     N'Austria'),
  (23, 23,  7, '2023-10-02', N'delivered',   N'Brussels',   N'Belgium'),
  (24, 24,  6, '2023-10-15', N'delivered',   N'Seoul',      N'South Korea'),
  (25, 25,  8, '2023-10-28', N'delivered',   N'Stockholm',  N'Sweden'),
  (26,  1,  7, '2023-11-08', N'delivered',   N'New York',   N'USA'),
  (27,  3,  6, '2023-11-20', N'delivered',   N'Toronto',    N'Canada'),
  (28,  5,  8, '2023-12-01', N'delivered',   N'Berlin',     N'Germany'),
  (29,  7,  7, '2023-12-12', N'delivered',   N'Paris',      N'France'),
  (30,  9,  6, '2023-12-24', N'delivered',   N'Barcelona',  N'Spain'),
  (31,  2,  8, '2024-01-04', N'shipped',     N'London',     N'UK'),
  (32,  4,  7, '2024-01-10', N'shipped',     N'Sydney',     N'Australia'),
  (33,  6,  6, '2024-01-16', N'shipped',     N'Madrid',     N'Spain'),
  (34,  8,  8, '2024-01-22', N'processing',  N'Chicago',    N'USA'),
  (35, 10,  7, '2024-01-28', N'processing',  N'Melbourne',  N'Australia'),
  (36, 12,  6, '2024-01-05', N'delivered',   N'Munich',     N'Germany'),
  (37, 14,  8, '2024-01-18', N'delivered',   N'Amsterdam',  N'Netherlands'),
  (38, 16,  7, '2024-01-31', N'processing',  N'Houston',    N'USA'),
  (39,  1,  6, '2024-02-05', N'delivered',   N'New York',   N'USA'),
  (40,  3,  8, '2024-02-12', N'shipped',     N'Toronto',    N'Canada'),
  (41, 11,  7, '2023-11-01', N'delivered',   N'Vancouver',  N'Canada'),
  (42, 13,  6, '2023-11-14', N'delivered',   N'Rome',       N'Italy'),
  (43, 15,  8, '2023-11-25', N'delivered',   N'Los Angeles',N'USA'),
  (44, 17,  7, '2023-12-07', N'delivered',   N'Dublin',     N'Ireland'),
  (45, 19,  6, '2023-12-18', N'delivered',   N'Kyiv',       N'Ukraine'),
  (46, 21,  8, '2024-01-30', N'delivered',   N'Prague',     N'Czech Republic'),
  (47,  5,  7, '2024-02-06', N'pending',     N'Berlin',     N'Germany'),
  (48,  9,  6, '2024-02-11', N'pending',     N'Barcelona',  N'Spain'),
  (49, 23,  8, '2023-10-20', N'delivered',   N'Brussels',   N'Belgium'),
  (50, 24,  7, '2024-01-12', N'delivered',   N'Seoul',      N'South Korea');
SET IDENTITY_INSERT orders OFF;

-- =============================================================================
-- order_items (~90 rows)
-- =============================================================================
SET IDENTITY_INSERT order_items ON;
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price, discount) VALUES
  -- order 1
  ( 1,  1,  1, 1, 1299.00,  0.00),
  ( 2,  1, 12, 2,  279.00,  5.00),
  -- order 2
  ( 3,  2,  5, 1, 2499.00,  0.00),
  ( 4,  2, 15, 3,   49.00,  0.00),
  -- order 3
  ( 5,  3,  6, 1, 1799.00,  0.00),
  ( 6,  3, 14, 2,   99.00, 10.00),
  -- order 4
  ( 7,  4,  9, 1, 1199.00,  0.00),
  ( 8,  4, 13, 1,  149.00,  0.00),
  -- order 5
  ( 9,  5,  6, 1, 1799.00,  0.00),
  (10,  5, 15, 3,   49.00,  0.00),
  -- order 6
  (11,  6, 20, 2,   59.00,  0.00),
  (12,  6, 22, 1,  199.00,  0.00),
  -- order 7
  (13,  7,  7, 1, 1599.00,  0.00),
  (14,  7, 14, 1,   99.00,  5.00),
  -- order 8
  (15,  8, 24, 1,  119.00,  0.00),
  (16,  8, 26, 1,   99.00,  0.00),
  -- order 9
  (17,  9,  3, 1,  799.00,  0.00),
  (18,  9, 12, 2,  279.00, 10.00),
  -- order 10
  (19, 10, 25, 1,  449.00,  0.00),
  (20, 10, 27, 1,   79.00,  0.00),
  -- order 11
  (21, 11, 16, 3,   29.00,  0.00),
  (22, 11, 17, 2,   79.00,  0.00),
  -- order 12
  (23, 12,  8, 1, 1099.00,  0.00),
  (24, 12, 15, 2,   49.00,  0.00),
  -- order 13
  (25, 13,  4, 1,  699.00,  0.00),
  (26, 13, 18, 1,  299.00,  5.00),
  -- order 14
  (27, 14, 10, 1,  849.00,  0.00),
  (28, 14, 21, 2,   69.00,  0.00),
  -- order 15
  (29, 15, 19, 1,  149.00,  0.00),
  (30, 15, 23, 1,  129.00,  0.00),
  -- order 16
  (31, 16,  1, 1, 1299.00,  0.00),
  (32, 16, 12, 1,  279.00,  0.00),
  -- order 17
  (33, 17,  5, 1, 2499.00,  5.00),
  -- order 18
  (34, 18,  2, 1, 1099.00,  0.00),
  (35, 18, 13, 2,  149.00,  0.00),
  -- order 19
  (36, 19,  6, 1, 1799.00, 10.00),
  -- order 20
  (37, 20, 11, 1,  499.00,  0.00),
  (38, 20, 15, 5,   49.00,  0.00),
  -- order 21
  (39, 21, 17, 2,   79.00,  0.00),
  (40, 21, 19, 1,  149.00,  5.00),
  -- order 22
  (41, 22,  3, 1,  799.00,  0.00),
  -- order 23
  (42, 23, 28, 1,   45.00,  0.00),
  (43, 23, 29, 1,  349.00,  0.00),
  -- order 24
  (44, 24, 30, 2,   35.00,  0.00),
  (45, 24, 25, 1,  449.00,  0.00),
  -- order 25
  (46, 25,  9, 1, 1199.00,  0.00),
  -- order 26
  (47, 26, 22, 1,  199.00,  0.00),
  (48, 26, 20, 2,   59.00,  5.00),
  -- order 27
  (49, 27,  7, 1, 1599.00,  0.00),
  -- order 28
  (50, 28,  4, 1,  699.00,  0.00),
  (51, 28, 14, 1,   99.00,  0.00),
  -- order 29
  (52, 29,  8, 1, 1099.00,  0.00),
  -- order 30
  (53, 30,  1, 1, 1299.00,  0.00),
  (54, 30, 12, 1,  279.00,  0.00),
  -- order 31
  (55, 31, 10, 1,  849.00,  0.00),
  -- order 32
  (56, 32,  2, 1, 1099.00,  0.00),
  -- order 33
  (57, 33,  5, 1, 2499.00,  0.00),
  -- order 34
  (58, 34, 17, 3,   79.00,  0.00),
  -- order 35
  (59, 35,  6, 1, 1799.00,  0.00),
  -- order 36
  (60, 36,  3, 1,  799.00,  0.00),
  (61, 36, 15, 2,   49.00,  0.00),
  -- order 37
  (62, 37, 25, 1,  449.00,  0.00),
  (63, 37, 26, 2,   99.00,  0.00),
  -- order 38
  (64, 38, 11, 1,  499.00,  0.00),
  -- order 39
  (65, 39,  1, 1, 1299.00,  5.00),
  (66, 39, 13, 1,  149.00,  0.00),
  -- order 40
  (67, 40,  7, 1, 1599.00,  0.00),
  -- order 41
  (68, 41,  2, 1, 1099.00,  0.00),
  (69, 41, 16, 2,   29.00,  0.00),
  -- order 42
  (70, 42,  4, 1,  699.00,  0.00),
  -- order 43
  (71, 43, 23, 1,  129.00,  0.00),
  (72, 43, 21, 1,   69.00,  0.00),
  -- order 44
  (73, 44, 18, 1,  299.00,  0.00),
  -- order 45
  (74, 45,  9, 1, 1199.00,  0.00),
  (75, 45, 12, 1,  279.00,  5.00),
  -- order 46
  (76, 46,  5, 1, 2499.00,  0.00),
  -- order 47
  (77, 47,  8, 1, 1099.00,  0.00),
  -- order 48
  (78, 48,  3, 1,  799.00,  0.00),
  (79, 48, 14, 2,   99.00,  0.00),
  -- order 49
  (80, 49, 24, 2,  119.00,  0.00),
  (81, 49, 27, 1,   79.00,  0.00),
  -- order 50
  (82, 50, 10, 1,  849.00,  0.00);
SET IDENTITY_INSERT order_items OFF;

-- =============================================================================
-- payments (40 rows)
-- =============================================================================
SET IDENTITY_INSERT payments ON;
INSERT INTO payments (payment_id, order_id, payment_date, amount, payment_method) VALUES
  ( 1,  1, '2023-01-06',  1553.05, N'credit_card'),
  ( 2,  2, '2023-01-13',  2697.00, N'paypal'),
  ( 3,  3, '2023-01-22',  1978.20, N'credit_card'),
  ( 4,  4, '2023-02-04',  1348.00, N'debit_card'),
  ( 5,  5, '2023-02-16',  1946.00, N'credit_card'),
  ( 6,  6, '2023-03-01',   317.00, N'paypal'),
  ( 7,  7, '2023-03-09',  1693.05, N'credit_card'),
  ( 8,  8, '2023-03-23',   218.00, N'bank_transfer'),
  ( 9,  9, '2023-04-02',  1327.20, N'credit_card'),
  (10, 10, '2023-04-19',   528.00, N'paypal'),
  (11, 11, '2023-05-06',   245.00, N'debit_card'),
  (12, 12, '2023-05-21',  1197.00, N'credit_card'),
  (13, 13, '2023-06-03',   983.05, N'credit_card'),
  (14, 14, '2023-06-16',   987.00, N'paypal'),
  (15, 15, '2023-07-02',   278.00, N'credit_card'),
  (16, 16, '2023-07-15',  1578.00, N'credit_card'),
  (17, 17, '2023-07-29',  2374.05, N'paypal'),
  (18, 18, '2023-08-11',  1397.00, N'debit_card'),
  (19, 19, '2023-08-26',  1619.10, N'credit_card'),
  (20, 20, '2023-09-06',   744.00, N'paypal'),
  (21, 21, '2023-09-19',   296.55, N'credit_card'),
  (22, 22, '2023-10-03',   799.00, N'debit_card'),
  (23, 23, '2023-10-17',   394.00, N'bank_transfer'),
  (24, 24, '2023-11-02',   519.00, N'credit_card'),
  (25, 25, '2023-11-16',  1199.00, N'paypal'),
  (26, 26, '2023-12-02',   311.20, N'credit_card'),
  (27, 27, '2023-12-16',  1599.00, N'debit_card'),
  (28, 28, '2024-01-09',   798.00, N'credit_card'),
  (29, 29, '2024-01-23',  1099.00, N'paypal'),
  (30, 36, '2024-01-16',   897.00, N'credit_card'),
  (31, 37, '2024-01-29',   647.00, N'bank_transfer'),
  (32, 39, '2024-02-12',  1583.55, N'credit_card'),
  (33, 41, '2023-11-11',  1157.00, N'paypal'),
  (34, 42, '2023-11-23',   699.00, N'credit_card'),
  (35, 43, '2023-12-04',   198.00, N'debit_card'),
  (36, 44, '2023-12-19',   299.00, N'credit_card'),
  (37, 45, '2024-01-06',  1448.05, N'credit_card'),
  (38, 46, '2024-02-13',  2499.00, N'paypal'),
  (39, 49, '2023-10-29',   317.00, N'bank_transfer'),
  (40, 50, '2024-01-19',   849.00, N'credit_card');
SET IDENTITY_INSERT payments OFF;

-- =============================================================================
-- reviews (30 rows)
-- =============================================================================
SET IDENTITY_INSERT reviews ON;
INSERT INTO reviews (review_id, product_id, customer_id, rating, review_text, review_date) VALUES
  ( 1,  1,  1, 5, N'Amazing phone, worth every penny!',          '2023-01-20'),
  ( 2,  5,  2, 5, N'Best laptop I ever owned.',                  '2023-01-28'),
  ( 3,  2,  3, 4, N'Great value for the price.',                 '2023-02-05'),
  ( 4,  9,  4, 4, N'Excellent display, smooth performance.',     '2023-02-20'),
  ( 5,  6,  5, 5, N'Perfect for work and gaming.',               '2023-03-02'),
  ( 6, 20,  6, 3, N'Nice dress but sizing runs small.',          '2023-03-15'),
  ( 7,  7,  7, 5, N'Super fast and lightweight.',                '2023-03-25'),
  ( 8, 24,  8, 4, N'Works perfectly, easy to use.',              '2023-04-08'),
  ( 9,  3,  9, 4, N'Clean UI and great camera.',                 '2023-04-18'),
  (10, 25, 10, 5, N'My kitchen staple! Love it.',                '2023-05-03'),
  (11, 16, 11, 4, N'Comfortable and durable.',                   '2023-05-19'),
  (12,  8, 12, 4, N'Solid laptop for the price.',                '2023-06-05'),
  (13,  4, 13, 5, N'Incredible battery life.',                   '2023-06-18'),
  (14, 10, 14, 3, N'Good tablet, a bit slow at times.',          '2023-07-04'),
  (15, 19, 15, 4, N'Very comfy for long runs.',                  '2023-07-15'),
  (16,  1, 16, 4, N'Great phone, love the camera.',              '2023-07-30'),
  (17,  5, 17, 5, N'Blazing fast for video editing.',            '2023-08-14'),
  (18,  2, 18, 5, N'Switched from iPhone, no regrets!',          '2023-08-28'),
  (19, 17, 21, 4, N'Well-made jeans, true to size.',             '2023-09-20'),
  (20, 22, 22, 5, N'Elegant blazer, perfect fit.',               '2023-12-10'),
  (21, 12,  1, 5, N'Best earbuds I have used.',                  '2023-02-10'),
  (22, 13,  3, 4, N'Good sound quality.',                        '2023-03-05'),
  (23, 14,  5, 4, N'Smooth scrolling, comfortable grip.',        '2023-03-18'),
  (24, 26, 23, 4, N'Cooks everything perfectly.',                '2023-10-20'),
  (25, 29, 24, 5, N'Quiet mower, great battery life.',           '2024-02-01'),
  (26, 28, 25, 4, N'Good quality hose, no leaks.',               '2024-02-15'),
  (27, 30, 20, 5, N'Sharp blades, very comfortable.',            '2023-11-12'),
  (28, 11, 12, 3, N'Decent tablet but slow sometimes.',          '2023-06-20'),
  (29, 15,  2, 5, N'Excellent hub, all ports work great.',       '2023-02-05'),
  (30, 18,  4, 4, N'Quality jacket, warm and stylish.',          '2023-03-01');
SET IDENTITY_INSERT reviews OFF;
