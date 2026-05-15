USE retail;

DROP TABLE IF EXISTS online_retail_clean;

-- creating a new table to change datatypes
CREATE TABLE online_retail_clean (
  invoice_no   VARCHAR(20),
  stockcode    VARCHAR(20),
  description  VARCHAR(255),
  quantity     INT,
  invoice_date DATETIME,
  unitprice    DECIMAL(10,2),
  customer_id  INT,
  country      VARCHAR(100)
);

-- inserting the cleaned data 
INSERT INTO online_retail_clean (
  invoice_no,
  stockcode,
  description,
  quantity,
  invoice_date,
  unitprice,
  customer_id,
  country
)
SELECT
  NULLIF(TRIM(invoice_no), '') AS invoice_no,
  NULLIF(TRIM(stockcode), '') AS stockcode,
  NULLIF(TRIM(description), '') AS description,

  -- quantity: keep numeric; else NULL
  CASE
    WHEN TRIM(quantity) REGEXP '^-?[0-9]+$' THEN CAST(TRIM(quantity) AS SIGNED)
    ELSE NULL
  END AS quantity,

  -- invoice_date is already like 2010-12-01 8:26:00, convert from string safely
  CASE
    WHEN TRIM(invoice_date) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}' THEN CAST(TRIM(invoice_date) AS DATETIME)
    ELSE NULL
  END AS invoice_date,

  -- unitprice: keep numeric; else NULL
  CASE
    WHEN TRIM(unitprice) REGEXP '^-?[0-9]+(\\.[0-9]+)?$' THEN CAST(TRIM(unitprice) AS DECIMAL(10,2))
    ELSE NULL
  END AS unitprice,

  -- customer_id: convert "17850.0" -> 17850 ; blanks -> NULL
  CASE
    WHEN customer_id IS NULL OR TRIM(customer_id) = '' THEN NULL
    WHEN TRIM(customer_id) REGEXP '^[0-9]+(\\.[0-9]+)?$'
      THEN CAST(FLOOR(CAST(TRIM(customer_id) AS DECIMAL(18,2))) AS UNSIGNED)
    ELSE NULL
  END AS customer_id,

  NULLIF(TRIM(country), '') AS country
FROM online_retail;

-- adding indexes
CREATE INDEX idx_clean_customer_date ON online_retail_clean (customer_id, invoice_date);
CREATE INDEX idx_clean_invoice_no    ON online_retail_clean (invoice_no);

-- creating view
CREATE OR REPLACE VIEW v_sales_clean AS
SELECT
  invoice_no,
  stockcode,
  description,
  quantity,
  invoice_date,
  unitprice,
  customer_id,
  country,
  (quantity * unitprice) AS line_revenue
FROM online_retail_clean
WHERE customer_id IS NOT NULL
  AND invoice_date IS NOT NULL
  AND quantity > 0
  AND unitprice > 0
  AND invoice_no NOT LIKE 'C%';

SELECT COUNT(*) AS valid_sales_rows FROM v_sales_clean;