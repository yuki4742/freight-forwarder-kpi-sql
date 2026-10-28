USE forwarder_kpi;

-- Shipment count by branch
SELECT
  branch,
  COUNT(*) AS jobs
FROM shipments
GROUP BY branch
ORDER BY jobs DESC;
