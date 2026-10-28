USE forwarder_kpi;

-- Revenue, cost, journals and gross profit by branch
-- Gross profit = SUM(AR) - SUM(AP) + SUM(JNL)
-- Job journals (JNL) only move profit between branches and net to zero company-wide.
SELECT
  branch,
  SUM(CASE WHEN ledger = 'AR' THEN amount ELSE 0 END) AS revenue,
  SUM(CASE WHEN ledger = 'AP' THEN amount ELSE 0 END) AS cost,
  SUM(CASE WHEN ledger = 'JNL' THEN amount ELSE 0 END) AS revenue_journal,
  SUM(CASE WHEN ledger = 'AR' THEN amount ELSE 0 END)
  - SUM(CASE WHEN ledger = 'AP' THEN amount ELSE 0 END)
  + SUM(CASE WHEN ledger = 'JNL' THEN amount ELSE 0 END) AS gross_profit
FROM charge_lines
GROUP BY branch
ORDER BY gross_profit DESC;
