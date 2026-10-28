USE forwarder_kpi;

-- Load charge_lines.csv (after shipments and charge_codes, because of the foreign keys)
-- Replace /path/to/data/ with the absolute path of the data folder.
LOAD DATA LOCAL INFILE '/path/to/data/charge_lines.csv'
INTO TABLE charge_lines
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(line_id, job_number, ledger, doc_type, doc_number, doc_date, posted_at,
 branch, department, counterparty_code, counterparty_name, charge_code, currency, amount);
