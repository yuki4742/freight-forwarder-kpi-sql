USE forwarder_kpi;

-- Charge lines: one row per AR / AP / journal line
CREATE TABLE charge_lines (
  line_id            INT            NOT NULL PRIMARY KEY,

  -- Shipment the line belongs to
  job_number         VARCHAR(20)    NOT NULL,

  -- Ledger and document
  ledger             CHAR(3)        NOT NULL,   -- AR / AP / JNL
  doc_type           CHAR(3)        NOT NULL,   -- INV / CRD / JNL
  doc_number         VARCHAR(20)    NOT NULL,
  doc_date           DATETIME       NOT NULL,
  posted_at          DATETIME       NOT NULL,

  -- Branch and department the line is posted to
  branch             CHAR(3)        NOT NULL,
  department         VARCHAR(10)    NOT NULL,

  -- Counterparty: customer (AR), carrier or vendor (AP), N/A (JNL)
  counterparty_code  VARCHAR(10)    NOT NULL,
  counterparty_name  VARCHAR(100)   NOT NULL,

  -- Charge and amount
  charge_code        VARCHAR(6)     NOT NULL,
  currency           CHAR(3)        NOT NULL,
  amount             DECIMAL(12,2)  NOT NULL,

  -- Index to speed up joins on job_number
  INDEX idx_job (job_number),

  -- Foreign keys: every line must belong to an existing shipment and charge code
  CONSTRAINT fk_lines_job  FOREIGN KEY (job_number)  REFERENCES shipments (job_number),
  CONSTRAINT fk_lines_code FOREIGN KEY (charge_code) REFERENCES charge_codes (charge_code)
);

SHOW TABLES;
