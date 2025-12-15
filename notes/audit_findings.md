# Audit Findings

## Transaction Table (`raw.transactions`)

### Row Counts
- Total raw transactions: 2261

### Key Issues Identified

#### 1. Duplicate Transactions
- 60 duplicate transaction ID groups detected
- Deduplication required before analysis

#### 2. Orphan Transactions
- 89 transactions reference missing or empty customer IDs

#### 3. Date Quality
- Multiple date formats detected:
  - YYYY-MM-DD
  - DD/MM/YYYY
  - MM/DD/YYYY
- Invalid date values present (e.g. month = 00, non-date strings)
- 1573 transactions could not be safely parsed into a valid date

#### 4. Amount Quality
- Non-numeric values detected (currency symbols, text, malformed numbers)
- 697 transactions could not be parsed into numeric amounts
- 216 rows contain clearly invalid amount formats

#### 5. Currency Inconsistencies
- Mixed casing and symbols (e.g. `usd`, `USD`, `د.إ`)
- Invalid placeholder values (e.g. `currency`)
- 435 transactions missing a usable currency value

#### 6. Status and Refund Conflicts
- Multiple representations of refund state (`true`, `yes`, `full`, `partial`, etc.)
- Logical contradictions between transaction status and refund indicators
- Required normalization and consistency checks

## Customer Table (`raw.customers`)

### Signup Date Quality
- Signup dates show minor inconsistencies
- Overall cleaner than transaction dates
- No critical blockers for cleaning

## Audit Conclusion
Transaction data contains significant quality issues across multiple dimensions.
Cleaning must be defensive, auditable, and avoid silent data loss.

Transactions were prioritized for cleaning over customers due to direct impact on revenue and time-based metrics.
