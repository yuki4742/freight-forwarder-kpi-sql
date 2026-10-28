USE forwarder_kpi;

-- Revenue, cost, job journals and gross profit by branch
-- Gross profit = SUM(AR) - SUM(AP) + SUM(JC)
-- Job journals (JC) only move profit between branches and net to zero company-wide.
SELECT
  branch,
  SUM(CASE WHEN ledger = 'AR' THEN local_amount ELSE 0 END) AS revenue,
  SUM(CASE WHEN ledger = 'AP' THEN local_amount ELSE 0 END) AS cost,
  SUM(CASE WHEN ledger = 'JC' THEN local_amount ELSE 0 END) AS revenue_journal,
  SUM(CASE WHEN ledger = 'AR' THEN local_amount ELSE 0 END)
  - SUM(CASE WHEN ledger = 'AP' THEN local_amount ELSE 0 END)
  + SUM(CASE WHEN ledger = 'JC' THEN local_amount ELSE 0 END) AS gross_profit
FROM charge_lines
GROUP BY branch
ORDER BY gross_profit DESC;
