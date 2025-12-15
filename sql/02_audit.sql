/*
Data Quality Audit
Purpose: Identify integrity issues in raw business data
Database: PostgreSQL (AWS RDS)
*/

-- Create audit schema
CREATE SCHEMA IF NOT EXISTS audit;

--1) Row counts
CREATE OR REPLACE VIEW audit.row_counts AS
SELECT 'raw.customers' AS table_name, COUNT(*) AS n FROM raw.customers
UNION ALL
SELECT 'raw.transactions' AS table_name, COUNT(*) AS n from raw.transactions;

--2) Duplicate transaction IDs
CREATE OR REPLACE VIEW audit.dup_transactions_by_id AS
SELECT TRIM(transaction_id) AS transaction_id_norm, COUNT(*) AS n FROM raw.transactions
WHERE transaction_id IS NOT NULL AND TRIM(transaction_id) <> ''
GROUP BY 1
HAVING COUNT(*) > 1
ORDER BY n DESC;

--3) Orphan transactions (no matching customer_id)
CREATE OR REPLACE VIEW audit.orphan_transactions AS
SELECT t.* FROM raw.transactions t
LEFT JOIN raw.customers c ON TRIM(t.customer_id) = TRIM(c.customer_id)
WHERE t.customer_id IS NULL
OR TRIM(t.customer_id) = '' 
OR c.customer_id IS NULL;

--4) Currency mess
CREATE OR REPLACE VIEW audit.currency_counts AS
SELECT COALESCE(currency, '<NULL>') AS currency_raw, COUNT(*) AS n
FROM raw.transactions
GROUP BY 1
ORDER BY n DESC;

--5A) order_date_raw values
CREATE OR REPLACE VIEW audit.order_date_raw_top AS
SELECT COALESCE(order_date_raw, '<NULL>') AS order_date_raw, COUNT(*) AS n
FROM raw.transactions
GROUP BY 1
ORDER BY n DESC
LIMIT 25;

--5B) signup_date_raw values
CREATE OR REPLACE VIEW audit.signup_date_raw_inventory AS
SELECT COALESCE(signup_date_raw, '<NULL>') AS signup_date_raw,
COUNT(*) AS n
FROM raw.customers
GROUP BY 1
ORDER BY n DESC
LIMIT 25;

--6) Refund and Status contradictions
CREATE OR REPLACE VIEW audit.status_refund_inventory AS
SELECT COALESCE(status, '<NULL>') AS status,
COALESCE(refund_raw, '<NULL') AS refund_raw,
COUNT(*) AS n
FROM raw.transactions
GROUP BY 1,2
ORDER BY n DESC;
