# my-sql — SQL Learning Repository

A fully self-contained MySQL learning database for practising:

- **Aggregation & GROUP BY**
- **Subqueries & CTE (Common Table Expressions)**
- **Window Functions**

---

## 📂 File Structure

| File | Description |
|------|-------------|
| `sql/01_ddl_schema.sql` | DDL — `CREATE TABLE` statements for all 9 tables |
| `sql/02_dml_data.sql`   | Seed data — `INSERT` statements (25 customers, 30 products, 50 orders, …) |
| `sql/03_aggregation_group_by.sql` | ~20 annotated examples of aggregation and GROUP BY |
| `sql/04_subqueries_cte.sql`       | ~20 annotated examples of subqueries and CTEs |
| `sql/05_window_functions.sql`     | ~20 annotated examples of window functions |

---

## 🗄️ Database Schema

```
departments ──< employees (self-ref manager_id)

categories (self-ref parent_category_id)
     │
  products ──< order_items >── orders ──< customers
                                  │
                              payments
products ──< reviews >── customers
```

### Table overview

| Table | Rows | Key columns |
|-------|------|-------------|
| `departments` | 8 | `department_id`, `budget` |
| `employees` | 20 | `salary`, `department_id`, `manager_id` (self-ref) |
| `categories` | 12 | `parent_category_id` (self-ref, 2-level tree) |
| `products` | 30 | `price`, `cost`, `stock_quantity`, `category_id` |
| `customers` | 25 | `country`, `city`, `registration_date` |
| `orders` | 50 | `status`, `order_date`, `customer_id`, `employee_id` |
| `order_items` | ~90 | `quantity`, `unit_price`, `discount` |
| `payments` | 40 | `amount`, `payment_method` |
| `reviews` | 30 | `rating` (1–5) |

---

## 🚀 Quick Start

```sql
-- 1. Create a fresh database
CREATE DATABASE IF NOT EXISTS shop;
USE shop;

-- 2. Create tables
SOURCE sql/01_ddl_schema.sql;

-- 3. Load seed data
SOURCE sql/02_dml_data.sql;

-- 4. Start learning!
SOURCE sql/03_aggregation_group_by.sql;
SOURCE sql/04_subqueries_cte.sql;
SOURCE sql/05_window_functions.sql;
```

Or using the `mysql` CLI:

```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS shop; USE shop;"
mysql -u root -p shop < sql/01_ddl_schema.sql
mysql -u root -p shop < sql/02_dml_data.sql
```

---

## 📚 Topics Covered

### 03 — Aggregation & GROUP BY

| # | Topic |
|---|-------|
| 1 | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX` on full table |
| 2 | `GROUP BY` single column |
| 3 | `GROUP BY` multiple columns (year + month, country + status) |
| 4 | `HAVING` — filter on aggregated values |
| 5 | Expressions inside aggregates (gross vs net revenue, profit margin) |
| 6 | Conditional aggregation — `CASE` inside `SUM` / `COUNT` |
| 7 | `ORDER BY` aggregate result, `LIMIT` |
| 8 | `COUNT(DISTINCT …)` |
| 9 | Multi-table aggregation with `JOIN` |
| 10 | `GROUP BY … WITH ROLLUP` — sub-totals and grand totals |

### 04 — Subqueries & CTE

| # | Topic |
|---|-------|
| 1 | Scalar subquery in `SELECT` |
| 2 | Scalar subquery in `WHERE` |
| 3 | Correlated subquery (references outer query row) |
| 4 | Subquery in `FROM` — derived table / inline view |
| 5 | `EXISTS` / `NOT EXISTS` — semi-join and anti-join |
| 6 | `IN` / `NOT IN` with subquery |
| 7 | `ALL` / `ANY` comparisons |
| 8 | Basic CTE (`WITH` clause) |
| 9 | Multiple CTEs chained together |
| 10 | CTE for DRY aggregation (compute once, use multiple times) |
| 11 | Recursive CTE — employee org hierarchy tree |
| 12 | Recursive CTE — category tree path |

### 05 — Window Functions

| # | Topic |
|---|-------|
| 1 | `ROW_NUMBER` — unique sequential row number |
| 2 | `RANK` / `DENSE_RANK` — rankings with / without gaps |
| 3 | `NTILE` — buckets / quartiles / terciles |
| 4 | Aggregate window functions (`SUM`, `AVG`, `COUNT`, `MIN`, `MAX OVER`) |
| 5 | Running total — cumulative `SUM` with `ROWS UNBOUNDED PRECEDING` |
| 6 | Moving average — sliding window frame |
| 7 | `LAG` / `LEAD` — access previous / next rows |
| 8 | `FIRST_VALUE` / `LAST_VALUE` — boundary values in frame |
| 9 | `PERCENT_RANK` / `CUME_DIST` — relative position |
| 10 | Partitioned windows — analytics within groups |
| 11 | Named `WINDOW` clause — define once, reuse many times |
| 12 | Combined analytical report — all techniques together |

---

## 💡 Learning Tips

1. Run `01_ddl_schema.sql` and `02_dml_data.sql` once to set up your environment.
2. Open each topic file and run queries **one block at a time** — every query is preceded by a comment explaining what it demonstrates.
3. Experiment: modify `WHERE`, `HAVING`, `PARTITION BY` conditions to build intuition.
4. The **recursive CTEs** (section 04, queries 11–12) require MySQL 8.0+.
5. All **window functions** require MySQL 8.0+.
