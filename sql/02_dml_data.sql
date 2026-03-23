-- =============================================================================
-- FILE: 02_dml_data.sql
-- PURPOSE: Seed data — INSERT statements for all tables
-- Run AFTER 01_ddl_schema.sql
-- =============================================================================

-- =============================================================================
-- departments (8 rows)
-- =============================================================================
INSERT INTO departments (department_name, location, budget) VALUES
  ('Sales',        'Kyiv',    500000.00),
  ('Engineering',  'Lviv',    900000.00),
  ('Marketing',    'Kyiv',    300000.00),
  ('Warehouse',    'Odesa',   200000.00),
  ('HR',           'Kyiv',    150000.00),
  ('Finance',      'Kyiv',    250000.00),
  ('Support',      'Kharkiv', 180000.00),
  ('Management',   'Kyiv',   1200000.00);

-- =============================================================================
-- employees (20 rows)
-- Hierarchy: CEO (id=1) → directors → managers → staff
-- =============================================================================
INSERT INTO employees (first_name, last_name, email, hire_date, salary, department_id, manager_id) VALUES
  -- Top management
  ('Olena',   'Kovalenko',  'o.kovalenko@shop.ua',   '2018-01-10', 15000.00, 8, NULL),
  ('Mykola',  'Shevchenko', 'm.shevchenko@shop.ua',  '2018-03-15',  9500.00, 1, 1),
  ('Iryna',   'Petrenko',   'i.petrenko@shop.ua',    '2018-05-20', 10200.00, 2, 1),
  ('Vasyl',   'Bondarenko', 'v.bondarenko@shop.ua',  '2018-07-01',  8800.00, 3, 1),
  ('Natalia', 'Tkachenko',  'n.tkachenko@shop.ua',   '2019-01-12',  7900.00, 5, 1),
  -- Sales team
  ('Andriy',  'Marchenko',  'a.marchenko@shop.ua',   '2019-03-01',  6500.00, 1, 2),
  ('Oksana',  'Savchenko',  'o.savchenko@shop.ua',   '2019-06-15',  6200.00, 1, 2),
  ('Dmytro',  'Kravchenko', 'd.kravchenko@shop.ua',  '2020-01-20',  5800.00, 1, 2),
  -- Engineering team
  ('Serhiy',  'Lysenko',    's.lysenko@shop.ua',     '2019-02-10',  8500.00, 2, 3),
  ('Yulia',   'Moroz',      'y.moroz@shop.ua',       '2019-09-05',  8000.00, 2, 3),
  ('Pavlo',   'Karpenko',   'p.karpenko@shop.ua',    '2020-03-12',  7500.00, 2, 9),
  ('Alina',   'Voronova',   'a.voronova@shop.ua',    '2020-07-22',  7200.00, 2, 9),
  -- Marketing team
  ('Roman',   'Hrytsenko',  'r.hrytsenko@shop.ua',   '2020-02-14',  6000.00, 3, 4),
  ('Kateryna','Zinchenko',  'k.zinchenko@shop.ua',   '2020-08-18',  5700.00, 3, 4),
  -- Warehouse team
  ('Ivan',    'Polishchuk', 'i.polishchuk@shop.ua',  '2019-11-01',  5000.00, 4, 1),
  ('Larysa',  'Sydorenko',  'l.sydorenko@shop.ua',   '2020-04-10',  4800.00, 4, 15),
  -- Finance team
  ('Halyna',  'Kuzyk',      'h.kuzyk@shop.ua',       '2019-04-23',  7100.00, 6, 1),
  ('Bohdan',  'Romaniuk',   'b.romaniuk@shop.ua',    '2021-01-11',  6300.00, 6, 17),
  -- Support team
  ('Tetiana', 'Bilous',     't.bilous@shop.ua',      '2021-05-03',  5200.00, 7, 1),
  ('Volodymyr','Savchuk',   'v.savchuk@shop.ua',     '2022-02-28',  5100.00, 7, 19);

-- =============================================================================
-- categories (12 rows — 2-level hierarchy)
-- =============================================================================
INSERT INTO categories (category_name, parent_category_id) VALUES
  -- Root categories
  ('Electronics',        NULL),   --  1
  ('Clothing',           NULL),   --  2
  ('Home & Garden',      NULL),   --  3
  ('Books',              NULL),   --  4
  -- Electronics sub-categories
  ('Smartphones',        1),      --  5
  ('Laptops',            1),      --  6
  ('Tablets',            1),      --  7
  ('Accessories',        1),      --  8
  -- Clothing sub-categories
  ('Men\'s Clothing',    2),      --  9
  ('Women\'s Clothing',  2),      -- 10
  -- Home & Garden sub-categories
  ('Kitchen',            3),      -- 11
  ('Garden Tools',       3);      -- 12

-- =============================================================================
-- products (30 rows)
-- =============================================================================
INSERT INTO products (product_name, category_id, price, cost, stock_quantity, created_at) VALUES
  -- Smartphones (cat 5)
  ('iPhone 15 Pro',           5,  1299.00,  850.00,  80, '2023-09-20'),
  ('Samsung Galaxy S24',      5,  1099.00,  700.00, 120, '2024-01-15'),
  ('Google Pixel 8',          5,   799.00,  500.00,  60, '2023-10-12'),
  ('Xiaomi 14 Pro',           5,   699.00,  420.00,  90, '2024-02-01'),
  -- Laptops (cat 6)
  ('MacBook Pro 14"',         6,  2499.00, 1600.00,  40, '2023-11-01'),
  ('Dell XPS 15',             6,  1799.00, 1100.00,  55, '2023-08-10'),
  ('Lenovo ThinkPad X1',      6,  1599.00, 1000.00,  70, '2024-01-20'),
  ('ASUS ZenBook 14',         6,  1099.00,  700.00,  85, '2024-02-10'),
  -- Tablets (cat 7)
  ('iPad Pro 12.9"',          7,  1199.00,  750.00,  50, '2023-11-10'),
  ('Samsung Galaxy Tab S9',   7,   849.00,  520.00,  65, '2024-01-08'),
  ('Lenovo Tab P12',          7,   499.00,  300.00, 100, '2024-03-01'),
  -- Accessories (cat 8)
  ('AirPods Pro',             8,   279.00,  140.00, 200, '2023-09-20'),
  ('Samsung Galaxy Buds2',    8,   149.00,   70.00, 180, '2024-01-15'),
  ('Logitech MX Master 3',    8,    99.00,   45.00, 150, '2023-07-01'),
  ('USB-C Hub 7-in-1',        8,    49.00,   18.00, 300, '2023-06-15'),
  -- Men's Clothing (cat 9)
  ('Men\'s Classic T-Shirt',  9,    29.00,    8.00, 500, '2023-01-01'),
  ('Men\'s Slim Jeans',       9,    79.00,   28.00, 250, '2023-01-15'),
  ('Men\'s Leather Jacket',   9,   299.00,  120.00,  80, '2023-02-01'),
  ('Men\'s Running Shoes',    9,   149.00,   60.00, 120, '2023-03-10'),
  -- Women's Clothing (cat 10)
  ('Women\'s Summer Dress',  10,    59.00,   18.00, 350, '2023-04-01'),
  ('Women\'s Yoga Pants',    10,    69.00,   22.00, 280, '2023-04-15'),
  ('Women\'s Blazer',        10,   199.00,   80.00,  90, '2023-05-01'),
  ('Women\'s Sneakers',      10,   129.00,   52.00, 160, '2023-05-20'),
  -- Kitchen (cat 11)
  ('Instant Pot 7-in-1',     11,   119.00,   55.00, 140, '2023-02-10'),
  ('KitchenAid Stand Mixer', 11,   449.00,  250.00,  35, '2023-03-05'),
  ('Ninja Air Fryer',        11,    99.00,   42.00, 170, '2023-04-20'),
  ('Coffee Maker Deluxe',    11,    79.00,   32.00, 200, '2023-05-15'),
  -- Garden Tools (cat 12)
  ('Garden Hose 30m',        12,    45.00,   16.00, 220, '2023-03-15'),
  ('Electric Lawn Mower',    12,   349.00,  190.00,  45, '2023-04-01'),
  ('Pruning Shears Set',     12,    35.00,   10.00, 310, '2023-03-25');

-- =============================================================================
-- customers (25 rows)
-- =============================================================================
INSERT INTO customers (first_name, last_name, email, city, country, registration_date) VALUES
  ('Alice',   'Johnson',    'alice.j@email.com',     'New York',    'USA',     '2022-01-15'),
  ('Bob',     'Smith',      'bob.s@email.com',       'London',      'UK',      '2022-02-20'),
  ('Carlos',  'Garcia',     'carlos.g@email.com',    'Madrid',      'Spain',   '2022-03-10'),
  ('Diana',   'Lee',        'diana.l@email.com',     'Seoul',       'Korea',   '2022-04-05'),
  ('Ethan',   'Brown',      'ethan.b@email.com',     'Toronto',     'Canada',  '2022-05-22'),
  ('Fiona',   'Wilson',     'fiona.w@email.com',     'Sydney',      'Australia','2022-06-14'),
  ('George',  'Taylor',     'george.t@email.com',    'Berlin',      'Germany', '2022-07-08'),
  ('Hannah',  'Anderson',   'hannah.a@email.com',    'Paris',       'France',  '2022-08-19'),
  ('Ian',     'Thomas',     'ian.t@email.com',       'Tokyo',       'Japan',   '2022-09-03'),
  ('Julia',   'Moore',      'julia.m@email.com',     'Rome',        'Italy',   '2022-10-27'),
  ('Kevin',   'Jackson',    'kevin.j@email.com',     'Chicago',     'USA',     '2022-11-11'),
  ('Laura',   'White',      'laura.w@email.com',     'Amsterdam',   'Netherlands','2022-12-05'),
  ('Mike',    'Harris',     'mike.h@email.com',      'Toronto',     'Canada',  '2023-01-18'),
  ('Nina',    'Martin',     'nina.m@email.com',      'Warsaw',      'Poland',  '2023-02-09'),
  ('Oscar',   'Thompson',   'oscar.t@email.com',     'Kyiv',        'Ukraine', '2023-03-14'),
  ('Paula',   'Garcia',     'paula.g@email.com',     'Barcelona',   'Spain',   '2023-04-25'),
  ('Quinn',   'Martinez',   'quinn.m@email.com',     'Mexico City', 'Mexico',  '2023-05-30'),
  ('Rachel',  'Robinson',   'rachel.r@email.com',    'London',      'UK',      '2023-06-16'),
  ('Sam',     'Clark',      'sam.c@email.com',       'Sydney',      'Australia','2023-07-22'),
  ('Tina',    'Rodriguez',  'tina.r@email.com',      'Buenos Aires','Argentina','2023-08-07'),
  ('Umar',    'Lewis',      'umar.l@email.com',      'Dubai',       'UAE',     '2023-09-19'),
  ('Vera',    'Lee',        'vera.l@email.com',      'Singapore',   'Singapore','2023-10-03'),
  ('Will',    'Walker',     'will.w@email.com',      'New York',    'USA',     '2023-11-14'),
  ('Xena',    'Hall',       'xena.h@email.com',      'Berlin',      'Germany', '2023-12-01'),
  ('Yuri',    'Allen',      'yuri.a@email.com',      'Kyiv',        'Ukraine', '2024-01-10');

-- =============================================================================
-- orders (50 rows — spread across 2023-2024)
-- =============================================================================
INSERT INTO orders (customer_id, employee_id, order_date, status, shipping_city, shipping_country) VALUES
  ( 1,  6, '2023-01-05', 'delivered', 'New York',    'USA'),
  ( 2,  7, '2023-01-12', 'delivered', 'London',      'UK'),
  ( 3,  8, '2023-01-20', 'delivered', 'Madrid',      'Spain'),
  ( 4,  6, '2023-02-03', 'delivered', 'Seoul',       'Korea'),
  ( 5,  7, '2023-02-15', 'delivered', 'Toronto',     'Canada'),
  ( 6,  8, '2023-02-28', 'delivered', 'Sydney',      'Australia'),
  ( 7,  6, '2023-03-08', 'delivered', 'Berlin',      'Germany'),
  ( 8,  7, '2023-03-22', 'delivered', 'Paris',       'France'),
  ( 9,  8, '2023-04-01', 'delivered', 'Tokyo',       'Japan'),
  (10,  6, '2023-04-18', 'delivered', 'Rome',        'Italy'),
  (11,  7, '2023-05-05', 'delivered', 'Chicago',     'USA'),
  (12,  8, '2023-05-20', 'delivered', 'Amsterdam',   'Netherlands'),
  (13,  6, '2023-06-02', 'delivered', 'Toronto',     'Canada'),
  (14,  7, '2023-06-15', 'delivered', 'Warsaw',      'Poland'),
  (15,  8, '2023-07-01', 'delivered', 'Kyiv',        'Ukraine'),
  (16,  6, '2023-07-14', 'delivered', 'Barcelona',   'Spain'),
  ( 1,  7, '2023-07-28', 'delivered', 'New York',    'USA'),
  ( 2,  8, '2023-08-10', 'delivered', 'London',      'UK'),
  ( 3,  6, '2023-08-25', 'delivered', 'Madrid',      'Spain'),
  ( 4,  7, '2023-09-05', 'delivered', 'Seoul',       'Korea'),
  (17,  8, '2023-09-18', 'delivered', 'Mexico City', 'Mexico'),
  (18,  6, '2023-10-02', 'delivered', 'London',      'UK'),
  (19,  7, '2023-10-16', 'delivered', 'Sydney',      'Australia'),
  (20,  8, '2023-11-01', 'delivered', 'Buenos Aires','Argentina'),
  (21,  6, '2023-11-15', 'delivered', 'Dubai',       'UAE'),
  (22,  7, '2023-12-01', 'delivered', 'Singapore',   'Singapore'),
  (23,  8, '2023-12-15', 'delivered', 'New York',    'USA'),
  ( 5,  6, '2024-01-08', 'delivered', 'Toronto',     'Canada'),
  ( 6,  7, '2024-01-22', 'delivered', 'Sydney',      'Australia'),
  ( 7,  8, '2024-02-05', 'shipped',   'Berlin',      'Germany'),
  ( 8,  6, '2024-02-18', 'shipped',   'Paris',       'France'),
  ( 9,  7, '2024-03-01', 'processing','Tokyo',       'Japan'),
  (10,  8, '2024-03-10', 'processing','Rome',        'Italy'),
  (11,  6, '2024-03-20', 'pending',   'Chicago',     'USA'),
  ( 1,  7, '2024-04-01', 'pending',   'New York',    'USA'),
  (24,  8, '2024-01-15', 'delivered', 'Berlin',      'Germany'),
  (25,  6, '2024-01-28', 'delivered', 'Kyiv',        'Ukraine'),
  ( 2,  7, '2024-02-10', 'shipped',   'London',      'UK'),
  (12,  8, '2024-02-25', 'delivered', 'Amsterdam',   'Netherlands'),
  (13,  6, '2024-03-05', 'processing','Toronto',     'Canada'),
  ( 3, 7,  '2023-11-10', 'delivered', 'Madrid',      'Spain'),
  ( 5, 8,  '2023-11-22', 'delivered', 'Toronto',     'Canada'),
  ( 8, 6,  '2023-12-03', 'delivered', 'Paris',       'France'),
  (11, 7,  '2023-12-18', 'delivered', 'Chicago',     'USA'),
  (14, 8,  '2024-01-05', 'delivered', 'Warsaw',      'Poland'),
  (15, 6,  '2024-02-12', 'delivered', 'Kyiv',        'Ukraine'),
  (16, 7,  '2024-03-15', 'shipped',   'Barcelona',   'Spain'),
  (18, 8,  '2024-03-22', 'processing','London',      'UK'),
  (20, 6,  '2023-10-28', 'delivered', 'Buenos Aires','Argentina'),
  (22, 7,  '2024-01-18', 'delivered', 'Singapore',   'Singapore');

-- =============================================================================
-- order_items  (~81 rows)
-- =============================================================================
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount) VALUES
  -- order 1
  ( 1,  1, 1, 1299.00, 0.00),
  ( 1, 12, 1,  279.00, 5.00),
  -- order 2
  ( 2,  5, 1, 2499.00, 0.00),
  ( 2, 14, 2,   99.00, 0.00),
  -- order 3
  ( 3,  2, 2, 1099.00, 10.00),
  -- order 4
  ( 4,  9, 1, 1199.00, 0.00),
  ( 4, 13, 1,  149.00, 0.00),
  -- order 5
  ( 5,  6, 1, 1799.00, 0.00),
  ( 5, 15, 3,   49.00, 0.00),
  -- order 6
  ( 6, 20, 2,   59.00, 0.00),
  ( 6, 22, 1,  199.00, 0.00),
  -- order 7
  ( 7,  7, 1, 1599.00, 0.00),
  ( 7, 14, 1,   99.00, 5.00),
  -- order 8
  ( 8, 24, 1,  119.00, 0.00),
  ( 8, 26, 1,   99.00, 0.00),
  -- order 9
  ( 9,  3, 1,  799.00, 0.00),
  ( 9, 12, 2,  279.00, 10.00),
  -- order 10
  (10, 25, 1,  449.00, 0.00),
  (10, 27, 1,   79.00, 0.00),
  -- order 11
  (11, 16, 3,   29.00, 0.00),
  (11, 17, 2,   79.00, 0.00),
  -- order 12
  (12,  8, 1, 1099.00, 0.00),
  (12, 15, 2,   49.00, 0.00),
  -- order 13
  (13,  4, 1,  699.00, 0.00),
  (13, 18, 1,  299.00, 5.00),
  -- order 14
  (14, 10, 1,  849.00, 0.00),
  (14, 21, 2,   69.00, 0.00),
  -- order 15
  (15, 19, 1,  149.00, 0.00),
  (15, 23, 1,  129.00, 0.00),
  -- order 16
  (16,  1, 1, 1299.00, 0.00),
  (16, 12, 1,  279.00, 0.00),
  -- order 17
  (17,  5, 1, 2499.00, 5.00),
  -- order 18
  (18,  2, 1, 1099.00, 0.00),
  (18, 13, 2,  149.00, 0.00),
  -- order 19
  (19,  6, 1, 1799.00, 10.00),
  -- order 20
  (20, 11, 1,  499.00, 0.00),
  (20, 15, 5,   49.00, 0.00),
  -- order 21
  (21, 17, 2,   79.00, 0.00),
  (21, 19, 1,  149.00, 5.00),
  -- order 22
  (22,  3, 1,  799.00, 0.00),
  -- order 23
  (23, 28, 1,   45.00, 0.00),
  (23, 29, 1,  349.00, 0.00),
  -- order 24
  (24, 30, 2,   35.00, 0.00),
  (24, 25, 1,  449.00, 0.00),
  -- order 25
  (25,  9, 1, 1199.00, 0.00),
  -- order 26
  (26, 22, 1,  199.00, 0.00),
  (26, 20, 2,   59.00, 5.00),
  -- order 27
  (27,  7, 1, 1599.00, 0.00),
  -- order 28
  (28,  4, 1,  699.00, 0.00),
  (28, 14, 1,   99.00, 0.00),
  -- order 29
  (29,  8, 1, 1099.00, 0.00),
  -- order 30
  (30,  1, 1, 1299.00, 0.00),
  (30, 12, 1,  279.00, 0.00),
  -- order 31
  (31, 10, 1,  849.00, 0.00),
  -- order 32
  (32,  2, 1, 1099.00, 0.00),
  -- order 33
  (33,  5, 1, 2499.00, 0.00),
  -- order 34
  (34, 17, 3,   79.00, 0.00),
  -- order 35
  (35,  6, 1, 1799.00, 0.00),
  -- order 36
  (36,  3, 1,  799.00, 0.00),
  (36, 15, 2,   49.00, 0.00),
  -- order 37
  (37, 25, 1,  449.00, 0.00),
  (37, 26, 2,   99.00, 0.00),
  -- order 38
  (38, 11, 1,  499.00, 0.00),
  -- order 39
  (39,  1, 1, 1299.00, 5.00),
  (39, 13, 1,  149.00, 0.00),
  -- order 40
  (40,  7, 1, 1599.00, 0.00),
  -- order 41
  (41,  2, 1, 1099.00, 0.00),
  (41, 16, 2,   29.00, 0.00),
  -- order 42
  (42,  4, 1,  699.00, 0.00),
  -- order 43
  (43, 23, 1,  129.00, 0.00),
  (43, 21, 1,   69.00, 0.00),
  -- order 44
  (44, 18, 1,  299.00, 0.00),
  -- order 45
  (45,  9, 1, 1199.00, 0.00),
  (45, 12, 1,  279.00, 5.00),
  -- order 46
  (46,  5, 1, 2499.00, 0.00),
  -- order 47
  (47,  8, 1, 1099.00, 0.00),
  -- order 48
  (48,  3, 1,  799.00, 0.00),
  (48, 14, 2,   99.00, 0.00),
  -- order 49
  (49, 24, 2,  119.00, 0.00),
  (49, 27, 1,   79.00, 0.00),
  -- order 50
  (50, 10, 1,  849.00, 0.00);

-- =============================================================================
-- payments  (one payment per delivered order, partials for a few)
-- =============================================================================
INSERT INTO payments (order_id, payment_date, amount, payment_method) VALUES
  ( 1, '2023-01-06',  1553.05, 'credit_card'),
  ( 2, '2023-01-13',  2697.00, 'paypal'),
  ( 3, '2023-01-22',  1978.20, 'credit_card'),
  ( 4, '2023-02-04',  1348.00, 'debit_card'),
  ( 5, '2023-02-16',  1946.00, 'credit_card'),
  ( 6, '2023-03-01',   317.00, 'paypal'),
  ( 7, '2023-03-09',  1693.05, 'credit_card'),
  ( 8, '2023-03-23',   218.00, 'bank_transfer'),
  ( 9, '2023-04-02',  1327.20, 'credit_card'),
  (10, '2023-04-19',   528.00, 'paypal'),
  (11, '2023-05-06',   245.00, 'debit_card'),
  (12, '2023-05-21',  1197.00, 'credit_card'),
  (13, '2023-06-03',   983.05, 'credit_card'),
  (14, '2023-06-16',   987.00, 'paypal'),
  (15, '2023-07-02',   278.00, 'credit_card'),
  (16, '2023-07-15',  1578.00, 'credit_card'),
  (17, '2023-07-29',  2374.05, 'paypal'),
  (18, '2023-08-11',  1397.00, 'debit_card'),
  (19, '2023-08-26',  1619.10, 'credit_card'),
  (20, '2023-09-06',   744.00, 'paypal'),
  (21, '2023-09-19',   296.55, 'credit_card'),
  (22, '2023-10-03',   799.00, 'debit_card'),
  (23, '2023-10-17',   394.00, 'bank_transfer'),
  (24, '2023-11-02',   519.00, 'credit_card'),
  (25, '2023-11-16',  1199.00, 'paypal'),
  (26, '2023-12-02',   311.20, 'credit_card'),
  (27, '2023-12-16',  1599.00, 'debit_card'),
  (28, '2024-01-09',   798.00, 'credit_card'),
  (29, '2024-01-23',  1099.00, 'paypal'),
  (36, '2024-01-16',   897.00, 'credit_card'),
  (37, '2024-01-29',   647.00, 'bank_transfer'),
  (39, '2024-02-12',  1583.55, 'credit_card'),
  (41, '2023-11-11',  1157.00, 'paypal'),
  (42, '2023-11-23',   699.00, 'credit_card'),
  (43, '2023-12-04',   198.00, 'debit_card'),
  (44, '2023-12-19',   299.00, 'credit_card'),
  (45, '2024-01-06',  1448.05, 'credit_card'),
  (46, '2024-02-13',  2499.00, 'paypal'),
  (49, '2023-10-29',   317.00, 'bank_transfer'),
  (50, '2024-01-19',   849.00, 'credit_card');

-- =============================================================================
-- reviews  (30 rows)
-- =============================================================================
INSERT INTO reviews (product_id, customer_id, rating, review_text, review_date) VALUES
  ( 1,  1, 5, 'Amazing phone, worth every penny!',          '2023-01-20'),
  ( 5,  2, 5, 'Best laptop I ever owned.',                  '2023-01-28'),
  ( 2,  3, 4, 'Great value for the price.',                 '2023-02-05'),
  ( 9,  4, 4, 'Excellent display, smooth performance.',     '2023-02-20'),
  ( 6,  5, 5, 'Perfect for work and gaming.',               '2023-03-02'),
  (20,  6, 3, 'Nice dress but sizing runs small.',          '2023-03-15'),
  ( 7,  7, 5, 'Super fast and lightweight.',                '2023-03-25'),
  (24,  8, 4, 'Works perfectly, easy to use.',              '2023-04-08'),
  ( 3,  9, 4, 'Clean UI and great camera.',                 '2023-04-18'),
  (25, 10, 5, 'My kitchen staple! Love it.',                '2023-05-03'),
  (16, 11, 4, 'Comfortable and durable.',                   '2023-05-19'),
  ( 8, 12, 4, 'Solid laptop for the price.',                '2023-06-05'),
  ( 4, 13, 5, 'Incredible battery life.',                   '2023-06-18'),
  (10, 14, 3, 'Good tablet, a bit slow at times.',          '2023-07-04'),
  (19, 15, 4, 'Very comfy for long runs.',                  '2023-07-15'),
  ( 1, 16, 4, 'Great phone, love the camera.',              '2023-07-30'),
  ( 5, 17, 5, 'Blazing fast for video editing.',            '2023-08-14'),
  ( 2, 18, 5, 'Switched from iPhone, no regrets!',          '2023-08-28'),
  (17, 21, 4, 'Well-made jeans, true to size.',             '2023-09-20'),
  (22, 22, 5, 'Elegant blazer, perfect fit.',               '2023-12-10'),
  (12,  1, 5, 'Best earbuds I have used.',                  '2023-02-10'),
  (13,  3, 4, 'Good sound quality.',                        '2023-03-05'),
  (14,  5, 4, 'Smooth scrolling, comfortable grip.',        '2023-03-18'),
  (26, 23, 4, 'Cooks everything perfectly.',                '2023-10-20'),
  (29, 24, 5, 'Quiet mower, great battery life.',           '2024-02-01'),
  (28, 25, 4, 'Good quality hose, no leaks.',               '2024-02-15'),
  (30, 20, 5, 'Sharp blades, very comfortable.',            '2023-11-12'),
  (11, 12, 3, 'Decent tablet but slow sometimes.',          '2023-06-20'),
  (15,  2, 5, 'Excellent hub, all ports work great.',       '2023-02-05'),
  (18,  4, 4, 'Quality jacket, warm and stylish.',          '2023-03-01');
