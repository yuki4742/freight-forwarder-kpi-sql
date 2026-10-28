USE forwarder_kpi;

-- Quick look at each table after loading

-- Charge code master
SELECT * FROM charge_codes;

-- Shipments: optional columns should show NULL for non-FCL / in-transit jobs
SELECT job_number, mode, container_type, teu, ata
FROM shipments
LIMIT 5;

-- Charge lines
SELECT *
FROM charge_lines
LIMIT 5;
