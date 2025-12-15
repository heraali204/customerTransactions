SELECT COUNT(*) AS clean_rows FROM clean.transactions;
SELECT COUNT(*) AS dedup_rows FROM clean.transactions_dedup;

SELECT
  SUM((transaction_id_norm IS NULL)::int) AS missing_tx_id,
  SUM((customer_id_norm IS NULL)::int)    AS missing_customer_id,
  SUM((currency_clean IS NULL)::int)      AS missing_currency,
  SUM((amount_clean IS NULL)::int)        AS unparsed_amount,
  SUM((order_date_clean IS NULL)::int)    AS unparsed_order_date,
  SUM(flag_bad_amount::int)              AS bad_amount_format,
  SUM(flag_bad_order_date::int)          AS bad_date_format
FROM clean.transactions;
