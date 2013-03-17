BEGIN;

DROP TABLE IF EXISTS Model_Views;

CREATE TABLE Model_Views (
    logged_at TIMESTAMP,
    ip_address TEXT,
    node_id INTEGER,
    person_id INTEGER
);

CREATE INDEX ON Model_Views(logged_at);
CREATE INDEX ON Model_Views(ip_address);
CREATE INDEX ON Model_Views(node_id);
CREATE INDEX ON Model_Views(person_id);

INSERT INTO Model_Views
  (logged_at, ip_address, node_id, person_id)
SELECT logged_at, ip_address, node_id, person_id
     FROM Logged_Actions
    WHERE controller = 'browse'
      AND action = 'one_model'
      AND is_searchbot = 'false'
;

DROP TABLE IF EXISTS Model_Downloads;

CREATE TABLE Model_Downloads (
    logged_at TIMESTAMP,
    ip_address TEXT,
    node_id INTEGER,
    person_id INTEGER
);

CREATE INDEX ON Model_Downloads(logged_at);
CREATE INDEX ON Model_Downloads(ip_address);
CREATE INDEX ON Model_Downloads(node_id);
CREATE INDEX ON Model_Downloads(person_id);

INSERT INTO Model_Views
  (logged_at, ip_address, node_id, person_id)
SELECT logged_at, ip_address, node_id, person_id
     FROM Logged_Actions
    WHERE controller = 'browse'
      AND action = 'download_model'
      AND is_searchbot = 'false'
;

COMMIT;
