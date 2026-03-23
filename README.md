# my-sql — SQL Learning Repository

A fully self-contained SQL learning database for practising:

- **Aggregation & GROUP BY**
- **Subqueries & CTE (Common Table Expressions)**
- **Window Functions**
- **Stored Procedures** (T-SQL)
- **Transactions** (T-SQL)
- **Indexes** (T-SQL — clustered, nonclustered, columnstore, filtered, covering)

The repository contains two parallel sets of scripts:
- `sql/` — **MySQL** dialect
- `tsql/` — **SQL Server / T-SQL** dialect (same schema and data, T-SQL syntax)

---

## 📂 File Structure

### MySQL (`sql/`)

| File | Description |
|------|-------------|
| `sql/01_ddl_schema.sql` | DDL — `CREATE TABLE` statements for all 9 tables |
| `sql/02_dml_data.sql`   | Seed data — `INSERT` statements (25 customers, 30 products, 50 orders, …) |
| `sql/03_aggregation_group_by.sql` | ~20 annotated examples of aggregation and GROUP BY |
| `sql/04_subqueries_cte.sql`       | ~20 annotated examples of subqueries and CTEs |
| `sql/05_window_functions.sql`     | ~20 annotated examples of window functions |

### SQL Server / T-SQL (`tsql/`)

| File | Description |
|------|-------------|
| `tsql/01_ddl_schema.sql` | DDL — T-SQL `CREATE TABLE` (`IDENTITY`, `NVARCHAR`, `CHECK` constraints) |
| `tsql/02_dml_data.sql`   | Seed data — `SET IDENTITY_INSERT ON/OFF` + `INSERT` statements |
| `tsql/03_aggregation_group_by.sql` | Aggregation & GROUP BY — T-SQL syntax (`TOP`, `GROUPING SETS`, `CUBE`) |
| `tsql/04_subqueries_cte.sql`       | Subqueries & CTEs — T-SQL syntax (recursive CTE without `RECURSIVE` keyword, `REPLICATE`, `FORMAT`) |
| `tsql/05_window_functions.sql`     | Window functions — T-SQL syntax (inline `OVER()`, no named `WINDOW` clause) |
| `tsql/06_stored_procedures.sql`    | Stored Procedures — `CREATE OR ALTER PROCEDURE`, `@params`, `OUTPUT`, `TRY-CATCH`, `RAISERROR`, `THROW` |
| `tsql/07_transactions.sql`         | Transactions — `BEGIN TRAN`, `COMMIT`, `ROLLBACK`, `SAVE TRAN`, `@@TRANCOUNT`, `XACT_ABORT`, isolation levels |
| `tsql/08_indexes.sql`              | Indexes — clustered, nonclustered, unique, composite, covering (`INCLUDE`), filtered, columnstore, `FILLFACTOR`, fragmentation |

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

## 🚀 Quick Start — MySQL

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

## 🚀 Quick Start — SQL Server / T-SQL

```sql
-- 1. Create a fresh database
CREATE DATABASE shop;
GO
USE shop;
GO

-- 2. Create tables (run in SSMS or sqlcmd)
:r tsql\01_ddl_schema.sql
:r tsql\02_dml_data.sql

-- 3. Start learning!
:r tsql\03_aggregation_group_by.sql
:r tsql\04_subqueries_cte.sql
:r tsql\05_window_functions.sql
:r tsql\06_stored_procedures.sql
:r tsql\07_transactions.sql
:r tsql\08_indexes.sql
```

Or using `sqlcmd`:

```bash
sqlcmd -S localhost -d shop -i tsql\01_ddl_schema.sql
sqlcmd -S localhost -d shop -i tsql\02_dml_data.sql
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
| 7 | `ORDER BY` aggregate result, `TOP` (T-SQL) / `LIMIT` (MySQL) |
| 8 | `COUNT(DISTINCT …)` |
| 9 | Multi-table aggregation with `JOIN` |
| 10 | `ROLLUP`, `CUBE`, `GROUPING SETS` (T-SQL) / `WITH ROLLUP` (MySQL) |

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
| 11 | Named `WINDOW` clause (MySQL) / inline `OVER()` (T-SQL) |
| 12 | Combined analytical report — all techniques together |

### 06 — Stored Procedures *(T-SQL only)*

| # | Topic |
|---|-------|
| 1 | Basic procedure — no parameters, `SET NOCOUNT ON` |
| 2 | Input parameters, optional filter (`= NULL` default) |
| 3 | `OUTPUT` parameter to return a scalar value |
| 4 | Default parameter values |
| 5 | Procedure with recursive CTE inside |
| 6 | Procedure using a `#temp` table |
| 7 | `TRY-CATCH` error handling + `RAISERROR` / `THROW` |
| 8 | Nested procedure call (`EXEC` inside a procedure) |
| 9 | Procedure with an embedded transaction |
| 10 | `CREATE OR ALTER PROCEDURE` — idempotent definition |

### 07 — Transactions *(T-SQL only)*

| # | Topic |
|---|-------|
| 1 | `BEGIN TRANSACTION` / `COMMIT` |
| 2 | `ROLLBACK` on a business-rule violation |
| 3 | `@@TRANCOUNT` — nesting counter |
| 4 | `SAVE TRANSACTION` — named savepoints (partial rollback) |
| 5 | `SET XACT_ABORT ON` — automatic rollback on error |
| 6 | `TRY-CATCH` wrapping a transaction |
| 7 | Named transactions |
| 8 | Isolation levels (`READ UNCOMMITTED`, `REPEATABLE READ`, `SNAPSHOT`) |
| 9 | `SET IMPLICIT_TRANSACTIONS ON` |
| 10 | `sys.dm_tran_active_transactions` — inspect open transactions |

### 08 — Indexes *(T-SQL only)*

| # | Topic |
|---|-------|
| 1 | Clustered index — concept and syntax |
| 2 | Nonclustered index — basic single-column |
| 3 | Unique index |
| 4 | Composite (multi-column) index — column order matters |
| 5 | Covering index — `INCLUDE` columns for index-only scans |
| 6 | Filtered index — partial index with `WHERE` predicate |
| 7 | Nonclustered columnstore index |
| 8 | Clustered columnstore index (fact-table / DWH use case) |
| 9 | Index options: `FILLFACTOR`, `PAD_INDEX`, `ONLINE`, `SORT_IN_TEMPDB` |
| 10 | `sys.indexes` / `sys.index_columns` — index metadata |
| 11 | `sys.dm_db_index_usage_stats` — usage statistics |
| 12 | `sys.dm_db_index_physical_stats` — fragmentation + dynamic maintenance |

---

## 🔄 MySQL vs T-SQL Quick Reference

| Feature | MySQL | T-SQL (SQL Server) |
|---------|-------|-------------------|
| Auto-increment | `AUTO_INCREMENT` | `IDENTITY(1,1)` |
| ENUM type | `ENUM('a','b')` | `NVARCHAR(n)` + `CHECK (col IN (...))` |
| String concat | `CONCAT(a,b)` | `a + b` or `CONCAT(a,b)` |
| Limit rows | `LIMIT n` | `TOP n` or `OFFSET 0 ROWS FETCH NEXT n ROWS ONLY` |
| Date format | `DATE_FORMAT(d, '%Y-%m')` | `FORMAT(d, 'yyyy-MM')` |
| Repeat string | `REPEAT(s, n)` | `REPLICATE(s, n)` |
| Recursive CTE | `WITH RECURSIVE cte AS (…)` | `WITH cte AS (…)` (no `RECURSIVE` keyword) |
| Named window | `WINDOW w AS (…)` | Not supported — inline `OVER(…)` required |
| Rollup syntax | `GROUP BY a, b WITH ROLLUP` | `GROUP BY ROLLUP(a, b)` |
| Cube / grouping sets | — | `GROUP BY CUBE(a,b)` / `GROUP BY GROUPING SETS(…)` |
| Stored procedure | `DELIMITER // … CREATE PROCEDURE …` | `CREATE [OR ALTER] PROCEDURE … AS BEGIN…END` |
| Transaction save | `SAVEPOINT name` | `SAVE TRANSACTION name` |

---

## 💡 Learning Tips

1. Run `01_ddl_schema.sql` and `02_dml_data.sql` once to set up your environment.
2. Open each topic file and run queries **one block at a time** — every query is preceded by a comment explaining what it demonstrates.
3. Experiment: modify `WHERE`, `HAVING`, `PARTITION BY` conditions to build intuition.
4. The **recursive CTEs** (section 04, queries 11–12) require MySQL 8.0+ / SQL Server 2005+.
5. All **window functions** require MySQL 8.0+ / SQL Server 2012+.
6. For T-SQL files, use **SQL Server Management Studio (SSMS)** or **Azure Data Studio** for the best experience.
7. T-SQL `06_stored_procedures.sql`, `07_transactions.sql`, and `08_indexes.sql` cover SQL Server-specific features with no MySQL equivalents.
