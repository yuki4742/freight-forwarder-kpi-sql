USE forwarder_kpi;

-- Average days from billing trigger to first AR invoice, by branch
-- Billing trigger = actual departure (export) or actual arrival (import)
-- Step 1: first_invoice      - first AR invoice date per job
-- Step 2: shipment_invoicing - join shipments and pick the trigger date
-- Step 3: invoice_days       - days from trigger to first invoice
-- Final:  aggregate by branch
WITH first_invoice AS (
  SELECT
    job_number,
    MIN(doc_date) AS first_invoice_date
  FROM charge_lines
  WHERE ledger = 'AR' AND doc_type = 'INV'
  GROUP BY job_number
),
shipment_invoicing AS (
  SELECT
    s.job_number,
    s.branch,
    CASE WHEN s.direction = 'Export' THEN s.atd ELSE s.ata END AS atd_ata,
    fi.first_invoice_date
  FROM shipments AS s
  JOIN first_invoice AS fi ON fi.job_number = s.job_number
),
invoice_days AS (
  SELECT
    job_number,
    branch,
    DATEDIFF(first_invoice_date, atd_ata) AS days_to_invoice
  FROM shipment_invoicing
)
SELECT
  branch,
  COUNT(job_number) AS jobs,
  ROUND(AVG(days_to_invoice), 1) AS avg_days_to_invoice,
  MIN(days_to_invoice) AS min_days,
  MAX(days_to_invoice) AS max_days
FROM invoice_days
GROUP BY branch
ORDER BY avg_days_to_invoice DESC;
