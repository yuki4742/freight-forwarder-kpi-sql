# Freight Forwarder KPI Dataset (Synthetic)

A synthetic dataset for a **fictional freight forwarder headquartered in Seattle, WA**, built for a business KPI analysis (profitability, schedule reliability, and billing health).

> **Disclaimer:** All data is synthetic and was created for this project. It is not derived from any real company's data or from any commercial software. Field names and codes are generic industry terms. Every company, customer, carrier and vendor name is fictional, and any resemblance to real organizations is coincidental.

## At a glance

| Item | Value |
|---|---|
| Period (job opened) | 2025-10-01 to 2026-09-30 |
| Data extraction date (as-of) | 2026-10-20 |
| Branches | SEA (Seattle), PDX (Portland), ANC (Anchorage) |
| Shipments | 590 |
| Charge lines | 4,844 |
| Currency | USD only |

## Files

| File | Grain | Description |
|---|---|---|
| `shipments.csv` | 1 row per shipment (job) | Shipment profile, customer, carrier, route, and schedule (planned vs. actual) |
| `charge_lines.csv` | 1 row per charge line | Customer invoices and credit notes (AR), carrier and vendor bills (AP), and inter-branch journals (JNL) |
| `charge_codes.csv` | 1 row per charge code | Charge code list with a reporting group |

## Data model

```
shipments (1) ──< charge_lines (many) >── (1) charge_codes
   job_number          job_number / charge_code      charge_code
```

`charge_lines` is at a finer grain than `shipments`. When the two are joined, shipment-level measures (shipment count, weight, TEU) repeat on every charge line. Count shipments with `COUNT(DISTINCT job_number)`, and aggregate shipment measures before joining (or use Tableau relationships instead of a physical join).

## shipments.csv

| Column | Type | Description |
|---|---|---|
| job_number | text (PK) | Shipment job number, `SHP-YYMM-####` |
| job_opened_date | date | Date the job was opened |
| branch | text | Handling branch: SEA / PDX / ANC |
| department | text | SEA_EXP, SEA_IMP, AIR_EXP, AIR_IMP |
| direction | text | Import / Export |
| transport | text | SEA / AIR |
| load_type | text | FCL (full container), LCL (less than container), LOOSE (air cargo) |
| customer_code / customer_name | text | Customer, `CUST###` |
| carrier_code / carrier_name | text | Ocean carrier, airline, or LCL consolidator, `CARR###` |
| origin / destination | text | UN/LOCODE (e.g., CNSHA Shanghai, USTIW Tacoma) |
| origin_country / destination_country | text | ISO country code |
| etd / atd | date | Estimated / actual time of departure |
| eta / ata | date | Estimated / actual time of arrival. Empty `ata` = still in transit on the as-of date |
| container_type | text | 20GP / 40HC (FCL only, otherwise empty) |
| container_count | integer | Number of containers (FCL only) |
| teu | integer | Twenty-foot equivalent units (FCL only) |
| weight, weight_unit | number, text | Gross weight in KG |
| volume, volume_unit | number, text | Volume in M3 |
| chargeable_qty, chargeable_unit | number, text | Chargeable quantity: KG for air, M3 for sea |

## charge_lines.csv

| Column | Type | Description |
|---|---|---|
| line_id | integer (PK) | Charge line ID |
| job_number | text (FK) | Shipment the line belongs to |
| ledger | text | AR (receivables), AP (payables), JNL (inter-branch journal) |
| doc_type | text | INV (invoice / bill), CRD (credit note), JNL (journal) |
| doc_number | text | Document number: `INV-`, `CN-` (AR), `BILL-`, `BILLCN-` (AP), `JNL-` |
| doc_date / posted_at | datetime | Document date and posting date |
| branch / department | text | Branch and department the line is posted to |
| counterparty_code / counterparty_name | text | Customer (AR, `CUST###`), carrier or vendor (AP, `CARR###` / `VEND###`), or `N/A` (JNL) |
| charge_code | text | See `charge_codes.csv` |
| currency | text | USD |
| amount | number | Amount in USD (sign convention below) |

### Sign convention

| Ledger / doc_type | Sign of `amount` |
|---|---|
| AR INV | positive (revenue) |
| AR CRD | negative (reduces revenue) |
| AP INV | positive (cost) |
| AP CRD | negative (reduces cost) |
| JNL JNL | debit = negative, credit = positive. Each journal nets to zero within a job; it only moves profit between branches |

**Gross profit = SUM(AR) − SUM(AP) + SUM(JNL)**

## charge_codes.csv

| charge_code | description | charge_group |
|---|---|---|
| FRT | Freight | Freight |
| FSC | Fuel Surcharge | Surcharge |
| SSC | Security Surcharge | Surcharge |
| OHAN | Origin Handling | Origin |
| ODOC | Origin Documentation | Origin |
| OPIC | Origin Pickup | Origin |
| DHAN | Destination Handling | Destination |
| DDOC | Destination Documentation | Destination |
| DDEL | Destination Delivery | Destination |
| CUS | Customs Clearance | Customs |
| DEM | Demurrage | Delay-related |
| DET | Detention | Delay-related |
| STOR | Terminal Storage | Delay-related |
| WAIT | Truck Waiting Time | Delay-related |

## Notes for analysis

- **Completed shipments:** filter on `ata IS NOT NULL` for schedule KPIs. Recent shipments may not be fully invoiced yet (AR or AP still pending), which is normal work in progress.
- **Timing of lines:** AR is invoiced after departure (export) or arrival (import). Carrier, trucker, and delay-related costs are billed later, so a job's figures can change after its first invoice.
- **Suggested on-time definition:** sea `ata <= eta + 1 day`, air `ata <= eta`.
- **Location codes:** USSEA Seattle, USTIW Tacoma, USPDX Portland, USANC Anchorage, CNSHA Shanghai, CNNGB Ningbo, CNPVG Shanghai Pudong (air), VNSGN Ho Chi Minh City, KRPUS Busan, KRICN Incheon (air), JPTYO Tokyo, JPYOK Yokohama, JPUKB Kobe, JPNRT Narita (air), TWKHH Kaohsiung, TWTPE Taipei (air).

## Loading into MySQL

See [How to run](../README.md#how-to-run) in the main README and the scripts in [`sql/`](../sql).
