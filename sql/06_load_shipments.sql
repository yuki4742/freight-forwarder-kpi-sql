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
(job_number, job_opened_date, branch, department, direction, transport, load_type,
 customer_code, customer_name, carrier_code, carrier_name,
 origin, origin_country, destination, destination_country,
 etd, @atd, eta, @ata, @container_type, @container_count, @teu,
 weight, weight_unit, volume, volume_unit, chargeable_qty, chargeable_unit)
SET atd             = NULLIF(@atd, ''),
    ata             = NULLIF(@ata, ''),
    container_type  = NULLIF(@container_type, ''),
    container_count = NULLIF(@container_count, ''),
    teu             = NULLIF(@teu, '');
