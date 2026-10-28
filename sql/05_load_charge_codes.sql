USE forwarder_kpi;

-- Load charge_codes.csv
-- Replace /path/to/data/ with the absolute path of the data folder.
LOAD DATA LOCAL INFILE '/path/to/data/charge_codes.csv'
INTO TABLE charge_codes
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(charge_code, description, charge_group);
