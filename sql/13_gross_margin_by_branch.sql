USE forwarder_kpi;

-- Gross margin % by branch
-- Step 1: summary - revenue, cost and job journals by branch
-- Final:  gross profit and gross margin %
WITH summary AS (
  SELECT
    branch,
    SUM(CASE WHEN ledger = 'AR' THEN local_amount ELSE 0 END) AS revenue,
    SUM(CASE WHEN ledger = 'AP' THEN local_amount ELSE 0 END) AS cost,
    SUM(CASE WHEN ledger = 'JC' THEN local_amount ELSE 0 END) AS revenue_journal
  FROM charge_lines
  GROUP BY branch
)
SELECT
  branch,
  revenue,
  cost,
  revenue_journal,
  revenue - cost + revenue_journal AS gross_profit,
  ROUND((revenue - cost + revenue_journal) / revenue * 100, 1) AS gross_margin_pct
FROM summary
ORDER BY gross_margin_pct DESC;
