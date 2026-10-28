USE forwarder_kpi;

-- Delay-related costs vs. amounts billed to customers, by trade lane
-- Delay-related charges (demurrage, detention, storage, truck waiting)
-- are identified by charge_codes.charge_group = 'Delay-related'.
-- recovery_pct = delay amount billed (AR) / delay cost (AP)
-- recovery_pct is NULL for lanes with no delay costs (division by zero).
-- Step 1: summary - join charge lines, shipments and charge codes; aggregate by lane
-- Final:  recovery rate
WITH summary AS (
  SELECT
    s.origin,
    s.destination,
    s.load_type,
    SUM(CASE WHEN c.ledger = 'AR' AND cc.charge_group = 'Delay-related'
             THEN c.amount ELSE 0 END) AS delay_revenue,
    SUM(CASE WHEN c.ledger = 'AP' AND cc.charge_group = 'Delay-related'
             THEN c.amount ELSE 0 END) AS delay_cost
  FROM charge_lines AS c
  JOIN shipments AS s
    ON c.job_number = s.job_number
  JOIN charge_codes AS cc
    ON c.charge_code = cc.charge_code
  GROUP BY s.origin, s.destination, s.load_type
)
SELECT
  origin,
  destination,
  load_type,
  delay_revenue,
  delay_cost,
  ROUND(delay_revenue / delay_cost * 100, 1) AS recovery_pct
FROM summary
ORDER BY delay_cost DESC;
