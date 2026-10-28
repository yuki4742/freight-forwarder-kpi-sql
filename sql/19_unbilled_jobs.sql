USE forwarder_kpi;

-- Unbilled-job candidates: jobs with carrier/vendor costs (AP) but no customer invoice (AR),
-- more than 30 days after the billing trigger as of the data extraction date (2026-10-20).
-- Recent jobs without AR are normal work in progress and are excluded by the 30-day rule.
-- In-transit imports (ata is NULL) return NULL days and are excluded automatically.
-- Step 1: unbilled_jobs      - jobs with AP lines but no AR lines (HAVING)
-- Step 2: aged_unbilled_jobs - join shipments and calculate days since billing trigger
-- Final:  keep jobs older than 30 days, oldest first
WITH unbilled_jobs AS (
  SELECT
    job_number,
    SUM(CASE WHEN ledger = 'AP' THEN 1 ELSE 0 END) AS ap_lines,
    SUM(CASE WHEN ledger = 'AR' THEN 1 ELSE 0 END) AS ar_lines,
    SUM(CASE WHEN ledger = 'AP' THEN amount ELSE 0 END) AS ap_total_amount
  FROM charge_lines
  GROUP BY job_number
  HAVING SUM(CASE WHEN ledger = 'AP' THEN 1 ELSE 0 END) > 0
     AND SUM(CASE WHEN ledger = 'AR' THEN 1 ELSE 0 END) = 0
),
aged_unbilled_jobs AS (
  SELECT
    uj.job_number,
    s.branch,
    s.direction,
    CASE WHEN s.direction = 'Export' THEN s.atd ELSE s.ata END AS atd_ata,
    DATEDIFF('2026-10-20',
             CASE WHEN s.direction = 'Export' THEN s.atd ELSE s.ata END) AS days_since_trigger,
    uj.ap_lines,
    uj.ar_lines,
    uj.ap_total_amount
  FROM unbilled_jobs AS uj
  JOIN shipments AS s ON s.job_number = uj.job_number
)
SELECT *
FROM aged_unbilled_jobs
WHERE days_since_trigger > 30
ORDER BY days_since_trigger DESC;
