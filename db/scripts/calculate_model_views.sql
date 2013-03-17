BEGIN;

DROP TABLE IF EXISTS Model_Views;

CREATE TABLE Model_Views AS
SELECT logged_at, ip_address, node_id, person_id
  FROM Logged_Actions
 WHERE controller = 'browse' 
   AND action = 'one_model' 
   AND is_searchbot = 'false'
;

DROP TABLE IF EXISTS Model_Downloads;

CREATE TABLE Model_Downloads AS
SELECT logged_at, ip_address, node_id, person_id
  FROM Logged_Actions
 WHERE controller = 'browse' 
   AND action = 'download_model' 
   AND is_searchbot = 'false'
;

COMMIT;

