USE forwarder_kpi;

-- Revenue (AR) by branch
-- Credit notes (AR CRD) are negative, so they are included to get net revenue.
SELECT
  branch,
  SUM(amount) AS revenue
FROM charge_lines
WHERE ledger = 'AR'
GROUP BY branch
ORDER BY revenue DESC;
