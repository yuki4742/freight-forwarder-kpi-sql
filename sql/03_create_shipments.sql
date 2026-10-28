USE forwarder_kpi;

-- Shipments: one row per shipment (job)
CREATE TABLE shipments (
  -- Job
  job_number       VARCHAR(20)    NOT NULL PRIMARY KEY,
  branch           CHAR(3)        NOT NULL,   -- SEA / PDX / ANC
  department       CHAR(3)        NOT NULL,   -- FES / FIS / FEA / FIA
  job_opened_date  DATE           NOT NULL,
  customer_code    VARCHAR(12)    NOT NULL,
  customer_name    VARCHAR(100)   NOT NULL,

  -- Transport type
  direction        VARCHAR(10)    NOT NULL,   -- Import / Export
  trans            VARCHAR(5)     NOT NULL,   -- SEA / AIR
  mode             VARCHAR(5)     NOT NULL,   -- FCL / LCL / LSE

  -- Route (UN/LOCODE and ISO country code)
  origin           CHAR(5)        NOT NULL,
  orig_ctry        CHAR(2)        NOT NULL,
  destination      CHAR(5)        NOT NULL,
  dest_ctry        CHAR(2)        NOT NULL,

  -- Carrier
  carrier_code     VARCHAR(12)    NOT NULL,
  carrier_name     VARCHAR(100)   NOT NULL,

  -- Containers (FCL only, otherwise NULL)
  container_type   VARCHAR(5)     NULL,
  container_count  INT            NULL,
  teu              INT            NULL,

  -- Weight and volume
  weight           DECIMAL(12,3)  NOT NULL,
  weight_uq        VARCHAR(3)     NOT NULL,
  volume           DECIMAL(12,3)  NOT NULL,
  volume_uq        VARCHAR(3)     NOT NULL,
  chargeable       DECIMAL(12,3)  NOT NULL,
  chargeable_uq    VARCHAR(3)     NOT NULL,

  -- Schedule: estimated vs. actual
  etd              DATE           NOT NULL,
  atd              DATE           NULL,       -- NULL = not yet departed
  eta              DATE           NOT NULL,
  ata              DATE           NULL        -- NULL = still in transit
);

DESCRIBE shipments;
