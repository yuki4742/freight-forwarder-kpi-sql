USE forwarder_kpi;

-- Carrier comparison on the Shanghai (CNSHA) -> Tacoma (USTIW) FCL lane
-- Schedule KPIs come from shipments (one row per job) and financial KPIs from
-- charge_lines (one row per charge line). Each is aggregated to carrier level
-- first and then joined, so shipment counts are not inflated by the join.
-- Step 1: schedule - jobs, arrived and on-time counts by carrier
-- Step 2: money    - revenue, cost, job journals and delay costs by carrier
-- Final:  join on carrier and calculate rates
WITH schedule AS (
  SELECT
    carrier_name,
    COUNT(*)   AS jobs,
    COUNT(ata) AS arrived,                                -- COUNT(column) ignores NULL (in transit)
    SUM(ata <= DATE_ADD(eta, INTERVAL 1 DAY)) AS on_time  -- comparison returns 1 / 0 / NULL
  FROM shipments
  WHERE origin = 'CNSHA' AND destination = 'USTIW' AND mode = 'FCL'
  GROUP BY carrier_name
),
money AS (
  SELECT
    s.carrier_name,
    SUM(CASE WHEN c.ledger = 'AR' THEN c.local_amount ELSE 0 END) AS revenue,
    SUM(CASE WHEN c.ledger = 'AP' THEN c.local_amount ELSE 0 END) AS cost,
    SUM(CASE WHEN c.ledger = 'JC' THEN c.local_amount ELSE 0 END) AS revenue_journal,
    SUM(CASE WHEN c.ledger = 'AP' AND cc.charge_group = 'Delay-related'
             THEN c.local_amount ELSE 0 END) AS delay_cost
  FROM charge_lines AS c
  JOIN shipments AS s ON c.job_number = s.job_number
  JOIN charge_codes AS cc ON c.charge_code = cc.charge_code
  WHERE s.origin = 'CNSHA' AND s.destination = 'USTIW' AND s.mode = 'FCL'
  GROUP BY s.carrier_name
)
SELECT
  sc.carrier_name,
  sc.jobs,
  ROUND(sc.on_time / sc.arrived * 100, 1) AS on_time_pct,
  m.revenue,
  m.revenue - m.cost + m.revenue_journal AS gross_profit,
  ROUND((m.revenue - m.cost + m.revenue_journal) / m.revenue * 100, 1) AS gross_margin_pct,
  m.delay_cost
FROM schedule AS sc
JOIN money AS m ON sc.carrier_name = m.carrier_name
ORDER BY on_time_pct ASC;


-- Supplementary check: totals by counterparty (customers on AR, vendors on AP) on the same lane
WITH summary AS (
  SELECT
    s.origin,
    s.destination,
    s.mode,
    c.ledger,
    c.creditor_debtor,
    c.local_amount
  FROM charge_lines AS c
  JOIN shipments AS s
    ON c.job_number = s.job_number
)
SELECT
  origin,
  destination,
  ledger,
  creditor_debtor,
  SUM(local_amount) AS total_amount
FROM summary
WHERE origin = 'CNSHA' AND destination = 'USTIW' AND mode = 'FCL'
GROUP BY origin, destination, ledger, creditor_debtor
ORDER BY creditor_debtor, ledger;
