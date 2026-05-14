CREATE DATABASE IF NOT EXISTS retail;
USE retail;
DROP TABLE IF EXISTS online_retail;

CREATE TABLE online_retail (
	invoice_no VARCHAR(20),
    stockcode VARCHAR(20),
    description VARCHAR(300),
    quantity INT,
    invoice_date DATETIME,
    unitprice DECIMAL(10,2),
    customer_id INT,
    country VARCHAR(30)
);

CREATE INDEX idx_customer_date ON online_retail (customer_id, invoice_date);
CREATE INDEX idx_invoice_no    ON online_retail (invoice_no);