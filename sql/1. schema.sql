-- Creating a database retail and a table online_retail for raw data
CREATE DATABASE IF NOT EXISTS retail;
USE retail;

DROP TABLE IF EXISTS online_retail;

CREATE TABLE online_retail (
  invoice_no   VARCHAR(20),
  stockcode    VARCHAR(20),
  description  VARCHAR(255),
  quantity     VARCHAR(20),
  invoice_date VARCHAR(50),
  unitprice    VARCHAR(20),
  customer_id  VARCHAR(50),
  country      VARCHAR(100)
);


