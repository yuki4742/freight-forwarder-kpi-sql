USE forwarder_kpi;

-- Charge lines: one row per AR / AP / JC transaction line
CREATE TABLE charge_lines (
  line_id                    INT            NOT NULL PRIMARY KEY,

  -- Counterparty: debtor (AR), creditor (AP) or N/A (JC)
  creditor_debtor            VARCHAR(12)    NOT NULL,
  creditor_debtor_full_name  VARCHAR(100)   NOT NULL,

  -- Ledger and transaction type
  ledger                     CHAR(2)        NOT NULL,   -- AR / AP / JC
  type                       CHAR(3)        NOT NULL,   -- INV / CRD / JRJ

  -- Branch and department the line is posted to
  branch                     CHAR(3)        NOT NULL,
  department                 CHAR(3)        NOT NULL,

  -- Transaction details
  transaction_num            VARCHAR(20)    NOT NULL,
  transaction_date           DATETIME       NOT NULL,
  post_date                  DATETIME       NOT NULL,
  charge_code                VARCHAR(6)     NOT NULL,
  currency                   CHAR(3)        NOT NULL,
  local_amount               DECIMAL(12,2)  NOT NULL,

  -- Shipment the line belongs to
  job_number                 VARCHAR(20)    NOT NULL,

  -- Index to speed up joins on job_number
  INDEX idx_job (job_number),

  -- Foreign keys: every line must belong to an existing shipment and charge code
  CONSTRAINT fk_lines_job  FOREIGN KEY (job_number)  REFERENCES shipments (job_number),
  CONSTRAINT fk_lines_code FOREIGN KEY (charge_code) REFERENCES charge_codes (charge_code)
);

SHOW TABLES;
