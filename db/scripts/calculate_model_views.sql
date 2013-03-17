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

COMMIT;

