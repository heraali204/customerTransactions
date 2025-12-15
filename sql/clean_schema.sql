CREATE SCHEMA IF NOT EXISTS clean;

DROP TABLE IF EXISTS clean.transactions;

CREATE TABLE clean.transactions AS SELECT t.*,

--cleaned fields
NULLIF(TRIM(t.transaction_id), '') AS transaction_id_norm,
NULLIF(TRIM(t.customer_id), '') AS customer_id_norm,

CASE
WHEN t.currency IS NULL OR TRIM(t.currency) = '' THEN NULL
WHEN TRIM(t.currency) IN ('د.إ') THEN 'AED'
WHEN LOWER(TRIM(t.currency)) IN ('aed') THEN 'AED'
WHEN LOWER(TRIM(t.currency)) IN ('usd','us$') THEN 'USD'
WHEN UPPER(TRIM(t.currency)) IN ('AED', 'USD', 'GBP', 'EUR', 'PKR') THEN UPPER(TRIM(t.currency))
WHEN LOWER(TRIM(t.currency)) = 'currency' THEN NULL
ELSE UPPER(TRIM(t.currency))
END AS currency_clean,

CASE
WHEN t.amount_raw IS NULL OR TRIM(t.amount_raw) = '' THEN NULL
WHEN REGEXP_REPLACE(TRIM(t.amount_raw), '[^0-9\.\-]', '', 'g') ~ '^-?\d+(\.\d+)?$'
THEN REGEXP_REPLACE(TRIM(t.amount_raw), '[^0-9\.\-]', '', 'g')::numeric
ELSE NULL
END AS amount_clean,

CASE
WHEN t.order_date_raw ~ '^\d{4}-\d{2}-\d{2}$'
AND split_part(t.order_date_raw, '-', 2)::int BETWEEN 1 AND 12
AND split_part(t.order_date_raw, '-', 3)::int BETWEEN 1 AND 31
THEN t.order_date_raw::date
WHEN t.order_date_raw ~ '^\d{2}/\d{2}/\d{4}$'
AND split_part(t.order_date_raw, '/', 1)::int BETWEEN 13 AND 31
THEN to_date(t.order_date_raw, 'DD/MM/YYYY')
WHEN t.order_date_raw ~ '^\d{2}/\d{2}/\d{4}$'
AND split_part(t.order_date_raw, '/', 1)::int BETWEEN 1 AND 12
THEN to_date(t.order_date_raw, 'MM/DD/YYYY')
ELSE NULL
END AS order_date_clean,

LOWER(NULLIF(TRIM(t.status), '')) AS status_clean,

CASE
WHEN t.refund_raw IS NULL OR TRIM(t.refund_raw) = '' THEN NULL
WHEN LOWER(TRIM(t.refund_raw)) IN ('true','t','1','yes','y','refund','full') THEN 'refunded'
WHEN LOWER(TRIM(t.refund_raw)) IN ('partial') THEN 'partial_refund'
WHEN LOWER(TRIM(t.refund_raw)) IN ('false','f','0','no','n','-') THEN 'not_refunded'
ELSE 'unknown'
END AS refund_clean,

--flags
(t.order_date_raw IS NOT NULL AND
TRIM(t.order_date_raw) <> '' AND
NOT (t.order_date_raw ~ '^\d{4}-\d{2}-\d{2}$'
OR t.order_date_raw ~ '^\d{2}/\d{2}/\d{4}$')) AS flag_bad_order_date,

(t.amount_raw IS NOT NULL AND TRIM(t.amount_raw) <> '' AND
NOT (REGEXP_REPLACE(TRIM(t.amount_raw), '[^0-9\.\-]', '', 'g') ~ '^-?\d+(\.\d+)?$')) 
AS flag_bad_amount

FROM raw.transactions t;
