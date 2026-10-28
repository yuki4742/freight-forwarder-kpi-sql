USE forwarder_kpi;

-- Charge code master (lookup table)
CREATE TABLE charge_codes (
  charge_code   VARCHAR(6)   NOT NULL PRIMARY KEY,
  description   VARCHAR(50)  NOT NULL,
  charge_group  VARCHAR(20)  NOT NULL   -- e.g. Freight, Origin, Delay-related
);

DESCRIBE charge_codes;
