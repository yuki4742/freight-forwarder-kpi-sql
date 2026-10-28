USE forwarder_kpi;

-- Shipments: one row per shipment (job)
CREATE TABLE shipments (
  -- Job
  job_number           VARCHAR(20)    NOT NULL PRIMARY KEY,
  job_opened_date      DATE           NOT NULL,
  branch               CHAR(3)        NOT NULL,   -- SEA / PDX / ANC
  department           VARCHAR(10)    NOT NULL,   -- SEA_EXP / SEA_IMP / AIR_EXP / AIR_IMP

  -- Transport type
  direction            VARCHAR(10)    NOT NULL,   -- Import / Export
  transport            VARCHAR(5)     NOT NULL,   -- SEA / AIR
  load_type            VARCHAR(5)     NOT NULL,   -- FCL / LCL / LOOSE

  -- Customer and carrier
  customer_code        VARCHAR(10)    NOT NULL,
  customer_name        VARCHAR(100)   NOT NULL,
  carrier_code         VARCHAR(10)    NOT NULL,
  carrier_name         VARCHAR(100)   NOT NULL,

  -- Route (UN/LOCODE and ISO country code)
  origin               CHAR(5)        NOT NULL,
  origin_country       CHAR(2)        NOT NULL,
  destination          CHAR(5)        NOT NULL,
  destination_country  CHAR(2)        NOT NULL,

  -- Schedule: estimated vs. actual
  etd                  DATE           NOT NULL,
  atd                  DATE           NULL,       -- NULL = not yet departed
  eta                  DATE           NOT NULL,
  ata                  DATE           NULL,       -- NULL = still in transit

  -- Containers (FCL only, otherwise NULL)
  container_type       VARCHAR(5)     NULL,
  container_count      INT            NULL,
  teu                  INT            NULL,

  -- Weight and volume
  weight               DECIMAL(12,3)  NOT NULL,
  weight_unit          VARCHAR(3)     NOT NULL,
  volume               DECIMAL(12,3)  NOT NULL,
  volume_unit          VARCHAR(3)     NOT NULL,
  chargeable_qty       DECIMAL(12,3)  NOT NULL,
  chargeable_unit      VARCHAR(3)     NOT NULL
);

DESCRIBE shipments;
