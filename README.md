# SQL Cohort Retention (MySQL) — Online Retail Dataset

## Project Overview
This project builds a SQL analytics pipeline in **MySQL** using a transactions dataset (“Online Retail”). 
The main aim of this project is **Cohort-Retention Analysis** meaning how many customers return to purchase again after their first purchase.

So far, the project covers:
1. Loading raw data into MySQL (as-is, from CSV)
2. Cleaning the data into an analysis-ready layer
3. Creating a clean view that can be safely used for analytics

---

## Goal
After the dataset is cleaned and standardized, we will run cohort queries to answer questions like:
- How many customers return in month 1, month 2, month 3 after their first purchase?
- What is the month-over-month retention rate of customers?
- How does repeat purchasing behavior change over time?

---

## Tech Stack
- MySQL Server
- MySQL Workbench
- Git + GitHub
- Excel/CSV for initial dataset preparation

---

## Dataset
This project uses the **Online Retail** transactional dataset.

The dataset represents customer purchases as invoice line-items. That means:
- One invoice/order can appear in multiple rows (each row is a product line item)
- A customer can have many invoices over time

Important columns used in this project:
- `invoice_no` (invoice identifier; cancellations often start with `C`)
- `invoice_date` (timestamp of purchase)
- `customer_id` (customer identifier)
- `quantity`
- `unitprice`
- `country`

---

## Data Import (Online Retail CSV → MySQL)

### Source file
- CSV file: `online_retail_data.csv`
- Rows imported into MySQL: **541,909**

### Why we didn’t use Workbench wizard
MySQL Workbench “Table Data Import Wizard” was extremely slow/laggy for ~540k rows and resulted in partial imports, so we used the MySQL command-line client instead.

### Step 1 — Create a raw table (all columns as text)
We first created a staging table with `VARCHAR` columns to avoid type/format import errors:

```sql
CREATE TABLE online_retail_raw (
  invoice_no   VARCHAR(20),
  stockcode    VARCHAR(20),
  description  VARCHAR(255),
  quantity     VARCHAR(20),
  invoice_date VARCHAR(50),
  unitprice    VARCHAR(20),
  customer_id  VARCHAR(50),
  country      VARCHAR(100)
);
```

### Step 2 — Enable `LOCAL INFILE`
The CLI import uses `LOAD DATA LOCAL INFILE`. We enabled it on the MySQL server:

```sql
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';
```

### Step 3 — Import using MySQL CLI (Windows CMD)
1) Create an import script file, for example:  
`C:\Users\Downloads\import_online_retail.sql`

```sql
USE retail;

TRUNCATE TABLE online_retail_raw;

LOAD DATA LOCAL INFILE 'C:/Users/Downloads/online_retail_data.csv'
INTO TABLE online_retail_raw
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(invoice_no, stockcode, description, quantity, invoice_date, unitprice, customer_id, country);

SELECT COUNT(*) AS raw_rows FROM online_retail_raw;
SHOW WARNINGS;
```

2) Open **Command Prompt (cmd)** and run:

```bat
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" --local-infile=1 -u root -h 127.0.0.1 -P 3306 -p < "C:\Users\Downloads\import_online_retail.sql"
```

3) Verify the load:

```sql
SELECT COUNT(*) AS raw_rows FROM online_retail_raw;
```

### Cleaning output
After cleaning and filtering (positive qty/price, non-cancelled invoices, valid dates, and non-null customers):
- `online_retail_clean`: **541,909**
- `v_sales_clean`: **397,880**

## Repository Structure (so far)
- `sql/01_schema.sql`  
  Creates the database and the raw staging table used for importing the CSV.
- `sql/02_cleaning.sql`  
  Creates a typed clean table and an analysis-ready view used for analytics.

---

## Data Pipeline (current state)

### 1) Raw Layer: `online_retail_raw`
**Why raw columns are `VARCHAR`:**  
CSV/Excel imports often contain blanks, mixed formats, and values like `17850.0` for customer IDs. Importing into strict numeric/datetime columns can fail.  
So we first load everything into a raw table as text, then clean it with SQL.

 Raw rows loaded: **541,909**

---

### 2) Clean Layer: `online_retail_clean` (typed table)
We create a new table with correct data types:
- `quantity` → `INT`
- `invoice_date` → `DATETIME`
- `unitprice` → `DECIMAL(10,2)`
- `customer_id` → `INT`

During cleaning we also:
- Trim whitespace (`TRIM`)
- Convert empty strings to `NULL` (`NULLIF`)
- Convert only valid numeric strings using `REGEXP` + `CAST`
- Convert customer IDs like `17850.0` to `17850` (Excel artifact)

 Clean rows created: **541,909**

Indexes added for performance:
- `(customer_id, invoice_date)`
- `(invoice_no)`

---

### 3) Analysis View: `v_sales_clean`
`v_sales_clean` is the dataset used for analytics. It filters out invalid/unusable rows and adds a revenue column.

Filters applied:
- `customer_id IS NOT NULL` (required for retention/cohorts)
- `invoice_date IS NOT NULL`
- `quantity > 0`
- `unitprice > 0`
- `invoice_no NOT LIKE 'C%'` (exclude cancellations)

Computed column:
- `line_revenue = quantity * unitprice`

 Valid sales rows in `v_sales_clean`: **397,880**

---

## How to Run (so far)

### Step 1 — Create schema & raw table
Run:
- `sql/01_schema.sql`

### Step 2 — Import CSV into raw table
- Follow the steps to import data mentioned above

### Step 3 — Clean and create analysis view
Run:
- `sql/02_cleaning.sql`

### Quick validation queries
```sql
SELECT COUNT(*) AS raw_rows FROM online_retail_raw;
SELECT COUNT(*) AS clean_rows FROM online_retail_clean;
SELECT COUNT(*) AS valid_sales_rows FROM v_sales_clean;
```

---
