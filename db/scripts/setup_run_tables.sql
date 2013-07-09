BEGIN;

DROP TABLE IF EXISTS Model_Runs;

CREATE TABLE Model_Runs (
    logged_at TIMESTAMP,
    ip_address TEXT,
    node_id INTEGER,
    person_id INTEGER
);

CREATE INDEX ON Model_Runs(logged_at);
CREATE INDEX ON Model_Runs(ip_address);
CREATE INDEX ON Model_Runs(node_id);
CREATE INDEX ON Model_Runs(person_id);

INSERT INTO Model_Runs
  (logged_at, ip_address, node_id, person_id)
SELECT logged_at, ip_address, node_id, person_id
     FROM Logged_Actions
    WHERE controller = 'browse'
      AND action = 'model_contents'
      AND node_id IS NOT NULL
      AND is_searchbot = 'false'
;

COMMIT;
