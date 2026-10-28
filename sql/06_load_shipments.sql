USE forwarder_kpi;

-- Load shipments.csv
-- Replace /path/to/data/ with the absolute path of the data folder.
-- Empty strings in optional columns are converted to NULL with NULLIF,
-- so that "not arrived yet" is stored as NULL rather than 0000-00-00.
LOAD DATA LOCAL INFILE '/path/to/data/shipments.csv'
INTO TABLE shipments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(job_number, branch, department, job_opened_date, customer_code, customer_name,
 direction, trans, mode, origin, orig_ctry, destination, dest_ctry,
 carrier_code, carrier_name, @container_type, @container_count, @teu,
 weight, weight_uq, volume, volume_uq, chargeable, chargeable_uq,
 etd, @atd, eta, @ata)
SET container_type  = NULLIF(@container_type, ''),
    container_count = NULLIF(@container_count, ''),
    teu             = NULLIF(@teu, ''),
    atd             = NULLIF(@atd, ''),
    ata             = NULLIF(@ata, '');
