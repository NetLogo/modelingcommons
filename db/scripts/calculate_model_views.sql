BEGIN;

INSERT INTO Model_Views
  (logged_at, ip_address, node_id, person_id)
SELECT logged_at, ip_address, node_id, person_id
     FROM Logged_Actions
    WHERE controller = 'browse'
      AND action = 'one_model'
      AND is_searchbot = 'false'
      AND logged_at > (SELECT max(logged_at) FROM Model_Views)
;

INSERT INTO Model_Downloads
  (logged_at, ip_address, node_id, person_id)
SELECT logged_at, ip_address, node_id, person_id
     FROM Logged_Actions
    WHERE controller = 'browse'
      AND action = 'download_model'
      AND is_searchbot = 'false'
      AND logged_at > (SELECT max(logged_at) FROM Model_Views)
;

CREATE TABLE New_Model_View_Counts
AS
  SELECT COUNT(DISTINCT ip_address) as count, node_id
    FROM Model_Views
GROUP BY node_id;

CREATE INDEX ON New_Model_View_Counts(node_id);
CREATE INDEX ON New_Model_View_Counts(count);
DROP TABLE IF EXISTS Old_Model_View_Counts;
ALTER TABLE Model_View_Counts RENAME TO Old_Model_View_Counts;
ALTER TABLE New_Model_View_Counts RENAME TO Model_View_Counts;
DROP TABLE IF EXISTS Old_Model_View_Counts;

COMMIT;

