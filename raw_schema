CREATE SCHEMA IF NOT EXISTS raw;

CREATE TABLE IF NOT EXISTS raw.customers (
  customer_id        TEXT,
  full_name          TEXT,
  email              TEXT,
  phone              TEXT,
  country            TEXT,
  signup_date_raw    TEXT,
  marketing_opt_in   TEXT,
  source             TEXT
);

CREATE TABLE IF NOT EXISTS raw.transactions (
  transaction_id     TEXT,
  customer_id        TEXT,
  order_date_raw     TEXT,
  amount_raw         TEXT,
  currency           TEXT,
  payment_method     TEXT,
  status             TEXT,
  refund_raw         TEXT
);
