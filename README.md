# Freight Forwarder KPI Analysis (SQL)

Business KPI analysis of a **fictional Seattle-based freight forwarder** (branches: Seattle, Portland, Anchorage), built with MySQL.
The project links shipment data and accounting transactions (AR / AP / job journals) by job number to answer one business question:

> **Why is our highest-revenue trade lane the least profitable?**

All data is synthetic. Every company, customer, carrier and vendor name is fictional. See [`data/README.md`](data/README.md) for the data dictionary.

---

## Key findings

### 1. Shanghai → Tacoma FCL: #1 in revenue, last in margin

| Metric | Shanghai → Tacoma FCL | Company overall |
|---|---|---|
| Shipments | 125 (21% of all jobs) | 590 |
| Revenue | $728K (29% of total) | $2.51M |
| Gross margin | **4.6%** (lowest of 20 lanes) | 14.2% |
| On-time arrival | **47.5%** (lowest of 20 lanes) | – |

### 2. Root cause: delay costs that are not passed on to the customer

- Delay-related costs (demurrage, detention, storage, truck waiting) on this lane: **$112K**, more than 10x the next-highest lane.
- Only **19.9%** of these costs were billed back to the customer, versus ~100% on other Asia lanes.
- The unrecovered amount (~$90K) is larger than the lane's entire gross profit ($33K).

### 3. The cause is concentrated in one carrier

| Carrier | Shipments | On-time | Gross margin | Delay costs |
|---|---|---|---|---|
| Pacific Crest Line | 39 | 84.6% | 13.1% | $8.7K |
| Jade Current Line | 86 | **30.1%** | **0.0%** | **$103.6K** |

Jade Current Line carries about 70% of the lane's volume but generates over 90% of its delay costs, leaving almost no profit.

### 4. Billing health

- **Invoice lag:** Portland takes **8.4 days** on average from departure/arrival to first invoice, vs. 2.0 days in Seattle and 1.7 days in Anchorage.
- **Unbilled jobs:** 5 jobs have carrier costs (~$18.8K in total) but no customer invoice more than 30 days after the billing trigger. The oldest has been open for over 300 days.

### 5. Seasonality

- Volume dips in **February** (Lunar New Year) and peaks in **August**.
- Anchorage air exports (seafood) are concentrated in **June–September**.
- September revenue looks low only because many of those jobs were not yet invoiced on the data extraction date (2026-10-20) — recent months should be read as work in progress.

## Recommendations

1. **Shift Shanghai → Tacoma volume to Pacific Crest Line** and review Jade Current Line's service performance.
2. **Add delay-cost recovery clauses** (demurrage / detention pass-through) at the next contract renewal with the lane's key customers.
3. **Standardize Portland's invoicing process** on Seattle's, and set an invoice-lag target (e.g., within 3 days).
4. **Run the unbilled-job check monthly** before job closing.

---

## Repository structure

```
├── data/
│   ├── README.md               Data dictionary
│   ├── charge_codes.csv
│   ├── shipments.csv
│   └── charge_lines.csv
└── sql/
    ├── 00_enable_local_infile.sql
    ├── 01_create_database.sql
    ├── 02_create_charge_codes.sql
    ├── 03_create_shipments.sql
    ├── 04_create_charge_lines.sql
    ├── 05_load_charge_codes.sql
    ├── 06_load_shipments.sql
    ├── 07_load_charge_lines.sql
    ├── 08_check_row_counts.sql
    ├── 09_preview_tables.sql
    ├── 10_shipments_by_branch.sql
    ├── 11_revenue_by_branch.sql
    ├── 12_gross_profit_by_branch.sql
    ├── 13_gross_margin_by_branch.sql
    ├── 14_gross_margin_by_lane.sql
    ├── 15_delay_cost_by_lane.sql
    ├── 16_on_time_rate_by_lane.sql
    ├── 17_carrier_comparison_shanghai_tacoma.sql
    ├── 18_invoice_lag_by_branch.sql
    ├── 19_unbilled_jobs.sql
    └── 20_monthly_trend.sql
```

## Analysis queries

| File | Question | Techniques |
|---|---|---|
| 10 | Shipments by branch | `GROUP BY`, `COUNT` |
| 11 | Revenue by branch | `WHERE`, `SUM` |
| 12 | Revenue, cost and gross profit by branch | Conditional aggregation (`CASE WHEN`) |
| 13 | Gross margin % by branch | CTE (`WITH`), `ROUND` |
| 14 | Gross margin by trade lane | `JOIN`, `COUNT(DISTINCT)` |
| 15 | Delay costs and recovery rate by lane | 3-table `JOIN` |
| 16 | On-time arrival rate by lane | Date logic (`DATE_ADD`), multi-step CTE |
| 17 | Carrier comparison on Shanghai → Tacoma | Aggregating at different grains before joining |
| 18 | Days from departure/arrival to first invoice | `MIN`, `DATEDIFF`, `AVG` |
| 19 | Unbilled jobs (cost without revenue) | `HAVING` |
| 20 | Monthly volume and revenue trend | `DATE_FORMAT` |

## Definitions

- **Gross profit** = SUM(AR) − SUM(AP) + SUM(job journals). Credit notes are included as negative amounts.
- **Trade lane** = origin + destination + mode.
- **On-time** = sea: `ata <= eta + 1 day`; air: `ata <= eta`. Only arrived shipments are counted.
- **Billing trigger** = actual departure (export) or actual arrival (import).

## How to run

1. Install MySQL 8.0+.
2. Run `sql/00` to `sql/04` to create the database and tables.
3. In `sql/05` to `sql/07`, replace `/path/to/data/` with the absolute path of the `data` folder, then run them from the MySQL command-line client:
   ```bash
   mysql --local-infile=1 -u root -p forwarder_kpi
   ```
4. Run `sql/08` to confirm the row counts (14 / 590 / 4,844), and `sql/09` to preview the tables.
5. Run any analysis query from `sql/10` onward.

## Tools

MySQL 8 · MySQL Workbench · Tableau (dashboard in progress)
