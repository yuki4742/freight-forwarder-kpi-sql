USE forwarder_kpi;

-- On-time arrival rate by trade lane (arrived shipments only)
-- On-time definition: sea = ata <= eta + 1 day, air = ata <= eta
-- Step 1: arrived_shipments - arrived shipments with the sea on-time limit (eta + 1 day)
-- Step 2: lane_summary      - arrived and on-time counts by lane
-- Final:  on-time rate, lowest first
WITH arrived_shipments AS (
  SELECT
    job_number,
    origin,
    destination,
    trans,
    mode,
    eta,
    ata,
    DATE_ADD(eta, INTERVAL 1 DAY) AS sea_limit
  FROM shipments
  WHERE ata IS NOT NULL
),
lane_summary AS (
  SELECT
    origin,
    destination,
    mode,
    COUNT(*) AS arrived,
    SUM(CASE WHEN (trans = 'SEA' AND ata <= sea_limit)
               OR (trans = 'AIR' AND ata <= eta)
             THEN 1 ELSE 0 END) AS on_time
  FROM arrived_shipments
  GROUP BY origin, destination, mode
)
SELECT
  origin,
  destination,
  mode,
  arrived,
  on_time,
  ROUND(on_time / arrived * 100, 1) AS on_time_pct
FROM lane_summary
ORDER BY on_time_pct ASC;
