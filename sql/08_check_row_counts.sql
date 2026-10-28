USE forwarder_kpi;

-- Check the loaded row counts
-- Expected: charge_codes = 14, shipments = 590, charge_lines = 4,844
SELECT 'charge_codes' AS table_name, COUNT(*) AS row_count FROM charge_codes
UNION ALL SELECT 'shipments', COUNT(*) FROM shipments
UNION ALL SELECT 'charge_lines', COUNT(*) FROM charge_lines;
