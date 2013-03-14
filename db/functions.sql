BEGIN;

CREATE OR REPLACE FUNCTION nodes_visible_to_anonymous_users() RETURNS SETOF Nodes
AS 
$body$
DECLARE
    node Nodes%rowtype;
BEGIN
    FOR node IN SELECT * FROM Nodes ORDER BY name ASC LOOP
        IF node.visibility_id = 1 THEN
            RETURN NEXT node;
        END IF;
    END LOOP;
END;
$body$ LANGUAGE plpgsql;

COMMIT;
