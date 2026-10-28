USE forwarder_kpi;

-- Shipments, revenue, gross profit and gross margin % by trade lane
-- Trade lane = origin + destination + mode
-- Shipment attributes repeat on every charge line after the join,
-- so shipments are counted with COUNT(DISTINCT job_number).
-- Step 1: summary - join charge lines to shipments and aggregate by lane
-- Final:  gross profit and gross margin %
WITH summary AS (
  SELECT
    s.origin,
    s.destination,
    s.mode,
    COUNT(DISTINCT s.job_number) AS jobs,
    SUM(CASE WHEN c.ledger = 'AR' THEN c.local_amount ELSE 0 END) AS revenue,
    SUM(CASE WHEN c.ledger = 'AP' THEN c.local_amount ELSE 0 END) AS cost,
    SUM(CASE WHEN c.ledger = 'JC' THEN c.local_amount ELSE 0 END) AS revenue_journal
  FROM charge_lines AS c
  JOIN shipments AS s
    ON c.job_number = s.job_number
  GROUP BY s.origin, s.destination, s.mode
)
SELECT
  origin,
  destination,
  mode,
  jobs,
  revenue,
  revenue - cost + revenue_journal AS gross_profit,
  ROUND((revenue - cost + revenue_journal) / revenue * 100, 1) AS gross_margin_pct
FROM summary
ORDER BY revenue DESC;
