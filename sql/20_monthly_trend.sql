USE forwarder_kpi;

-- Monthly shipment count (total and Anchorage) and revenue, by job opened month
-- Note: the latest months include jobs not yet invoiced on the extraction date (2026-10-20),
-- so their revenue is understated.
-- Step 1: monthly_jobs    - shipments and Anchorage shipments by month
-- Step 2: monthly_revenue - AR revenue by job opened month
-- Final:  join on month
WITH monthly_jobs AS (
  SELECT
    DATE_FORMAT(job_opened_date, '%Y-%m') AS month,
    COUNT(*) AS jobs,
    SUM(branch = 'ANC') AS anc_jobs
  FROM shipments
  GROUP BY DATE_FORMAT(job_opened_date, '%Y-%m')
),
monthly_revenue AS (
  SELECT
    DATE_FORMAT(s.job_opened_date, '%Y-%m') AS month,
    SUM(CASE WHEN cl.ledger = 'AR' THEN cl.local_amount ELSE 0 END) AS revenue
  FROM charge_lines AS cl
  JOIN shipments AS s ON s.job_number = cl.job_number
  GROUP BY DATE_FORMAT(s.job_opened_date, '%Y-%m')
)
SELECT
  mr.month,
  mj.jobs,
  mj.anc_jobs,
  mr.revenue
FROM monthly_revenue AS mr
JOIN monthly_jobs AS mj ON mj.month = mr.month
ORDER BY mr.month ASC;
