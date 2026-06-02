# snowflake-data-quality-project

## 🍁 Snowflake Data Quality Management System
### Sales & Orders Domain — Canadian Alcoholic Beverages Brand

## 📌 Project Overview
This project demonstrates a production-grade, end-to-end Data Quality Management System built entirely in Snowflake SQL — covering data ingestion, profiling, rule definition, metric logging, dashboard visualisation, and automated scheduling.
The scenario simulates a real-world challenge:

A leading Canadian alcoholic beverages brand receives raw sales and order data from multiple regional distributors. The data arrives unvalidated — containing nulls, duplicates, invalid formats, orphan records, and calculation errors. This system detects, tags, scores, and monitors all of it automatically.


## 🏗️ Architecture
┌─────────────────────────────────────────┐
│  Layer 1 — Raw Ingestion                │
│  RAW_CUSTOMERS · RAW_PRODUCTS · RAW_ORDERS │
│  rows with seeded real-world errors │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│  Layer 2 — Data Profiling               │
│  Nulls · Duplicates · Cardinality       │
│  Ranges · Patterns · Orphan FK checks   │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│  Layer 3 — DQ Rules Engine (Views)      │
│  VW_CUSTOMER_DQ · VW_PRODUCT_DQ         │
│  VW_ORDER_DQ — row-level PASS/FAIL tags │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│  Layer 4 — Metrics Store                │
│  DQ_METRICS_LOG — scored per run        │
│  SP_CALCULATE_DQ_METRICS stored proc    │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│  Layer 5 — Dashboard + Automation       │
│  Snowflake Dashboard tiles              │
│  TASK_NIGHTLY_DQ_METRICS (CRON 2AM UTC) │
└─────────────────────────────────────────┘

## 📁 Repository Structure

```
snowflake-data-quality-project/
│
├── README.md
│
├── sql/
│   ├── 01_DDL.sql                  ← Create RAW_CUSTOMERS, RAW_PRODUCTS, RAW_ORDERS
│   ├── 02_Insert.sql               ← Seed data with intentional quality errors
│   ├── 03_Data_Profiling.sql       ← Null counts, duplicates, ranges, patterns, FK checks
│   ├── 04_Data_Quality_Rules.sql   ← DQ views with row-level PASS / FAIL flags
│   ├── 05_Metrics.sql              ← DQ_METRICS_LOG table + stored procedure
│   ├── 06_Dashboard_Queries.sql    ← Snowflake dashboard tile queries
│   └── 07_Tasks.sql                ← Nightly automation via Snowflake Tasks
│
├── docs/
│   └── architecture_diagram.png   ← End-to-end pipeline architecture visual
│
└── assets/
    └── dashboard_screenshot.png   ← Snowflake dashboard screenshot (optional)
```

## 🧱 Data Model
## Schema Reference

### `RAW_CUSTOMERS`

| Column | Type | Notes |
|---|---|---|
| `CUSTOMER_ID` | VARCHAR | **PK** — errors: duplicates, nulls |
| `FIRST_NAME` | VARCHAR | Errors: nulls, blanks |
| `LAST_NAME` | VARCHAR | Errors: nulls, blanks |
| `EMAIL` | VARCHAR | Errors: invalid format, nulls |
| `PHONE` | VARCHAR | Errors: non-standard format |
| `PROVINCE` | VARCHAR | Errors: invalid province codes |
| `DATE_OF_BIRTH` | VARCHAR | Errors: future dates |
| `ANNUAL_SPEND_CAD` | VARCHAR | Errors: negative values, non-numeric |

---

### `RAW_PRODUCTS`

| Column | Type | Notes |
|---|---|---|
| `PRODUCT_ID` | VARCHAR | **PK** — errors: duplicates |
| `PRODUCT_NAME` | VARCHAR | Errors: nulls, blanks |
| `CATEGORY` | VARCHAR | Errors: invalid categories |
| `UNIT_PRICE_CAD` | VARCHAR | Errors: zero, negative |
| `ALCOHOL_PCT` | VARCHAR | Errors: > 100, negative |
| `IS_ACTIVE` | VARCHAR | Errors: values outside `Y/N` |

---

### `RAW_ORDERS`

| Column | Type | Notes |
|---|---|---|
| `ORDER_ID` | VARCHAR | **PK** |
| `CUSTOMER_ID` | VARCHAR | **FK** → `RAW_CUSTOMERS` — errors: orphans |
| `PRODUCT_ID` | VARCHAR | **FK** → `RAW_PRODUCTS` — errors: orphans |
| `ORDER_DATE` | VARCHAR | Errors: nulls, future dates |
| `QUANTITY` | VARCHAR | Errors: negative, zero |
| `TOTAL_AMOUNT_CAD` | VARCHAR | Errors: mismatch with `qty × price` |
| `STATUS` | VARCHAR | Errors: values outside allowed list |
| `CHANNEL` | VARCHAR | Errors: values outside allowed list |

---

## Data Quality Dimensions

| Dimension | Description | Tables Checked |
|---|---|---|
| **Completeness** | Required fields are not null or blank | All 3 |
| **Validity** | Values conform to format, type, and range rules | All 3 |
| **Uniqueness** | Primary key columns contain no duplicates | Customers, Products |
| **Referential Integrity** | FK values exist in parent tables | Orders |
| **Timeliness** | Dates are not in the future or impossibly old | Customers, Orders |

## ⚙️ How to Run This Project
Prerequisites
A Snowflake account (free trial works)

Access to a Snowflake Worksheet

## Execution Order
## Setup

Run the SQL files in order, one at a time.

| Step | File | Description |
|------|------|-------------|
| 1 | `01_DDL.sql` | Create the database, schema, and 3 raw tables |
| 2 | `02_Insert.sql` | Load ~1,000 rows with seeded errors |
| 3 | `03_Data_Profiling.sql` | Run profiling queries — review the output before proceeding |
| 4 | `04_Data_Quality_Rules.sql` | Create the 3 DQ views (rules engine) with row-level PASS / FAIL flags |
| 5 | `05_Metrics.sql` | Create `DQ_METRICS_LOG` table and stored procedure, then call it manually once |
| 6 | `06_Dashboard_Queries.sql` | Run in Snowflake Dashboards — one query per tile |
| 7 | `07_Tasks.sql` | Create and resume the nightly automation task |

> **Step 5 note:** After running `05_Metrics.sql`, execute the procedure once to populate the log:
> ```sql
> CALL SP_CALCULATE_DQ_METRICS();
> ```
