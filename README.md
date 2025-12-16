# 🧹 Messy Business Transactions & Data Cleaning with SQL (PostgreSQL)

## Overview
This project demonstrates how to audit, clean, and prepare highly messy transactional data for reliable analysis using PostgreSQL.
The focus is not on dashboards, but on data quality, defensive SQL, and reproducible cleaning pipelines, mirroring how data is handled in real production environments.

## Dataset
The dataset consists of two raw CSV files:
- customers_raw.csv
- transactions_raw.csv

The raw data intentionally contains:
- duplicate transaction IDs
- orphan transactions (missing customers)
- malformed and inconsistent dates
- non-numeric monetary values
- inconsistent currency formats
- contradictory refund and status fields

## Workflow

### 1️⃣ Raw Ingestion

Raw CSV files are loaded into a raw schema without modification to preserve original data.

### 2️⃣ Data Audit

Before cleaning, a comprehensive audit was performed to measure data quality issues, including:
- Duplicate transaction IDs
- Orphan transactions
- Inconsistent currency representations
- Malformed monetary values
- Multiple date formats and invalid dates
- Contradictions between transaction status and refund indicators

Audit queries are stored in 02_audit.sql, and findings are summarized in notes/audit_findings.md.

### 3️⃣ Cleaning Strategy

Cleaning decisions were made based on audit results, following these principles:
- Never silently drop data
- Parse values only when safe
- Retain raw columns for traceability
- Add normalized fields and quality flags
- Deduplicate without data loss

### 4️⃣ Clean Layer (clean schema)

##### clean.transactions
A cleaned table that:
- normalizes IDs, currency, status, and refund fields
- parses dates and amounts using defensive logic
- flags malformed values instead of deleting rows

##### clean.transactions_dedup
A deduplicated version of transactions:
- keeps exactly one row per transaction ID
- selects the “best” row using a quality score (parsed date, amount, currency)

This ensures stable and reproducible results.

### 5️⃣ Sanity Checks

Post-cleaning validation queries confirm:
- row counts
- number of unresolved issues
- impact of deduplication

These checks live in 04_sanity_checks.sql.

## Key Outcomes
- Raw transactions: 2261 rows
- Deduplicated transactions: 2201 rows
- Large portions of data were intentionally flagged but preserved, reflecting real-world constraints
- Final datasets are safe for downstream analytics (e.g. revenue trends, DAU/MAU)

## Tools Used
- PostgreSQL
- AWS RDS as Infrastructure
- pgAdmin
- SQL (CTEs, window functions, regex, defensive casting)
