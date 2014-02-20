CREATE TABLE model_collaborator_countries 
AS SELECT N.id, 
          (SELECT array(SELECT DISTINCT array_to_string(regexp_matches(IP.location, 
                                                                       'country_code: (\w+)'), '')
                                   FROM Collaborations C, logged_actions LA, ip_locations IP
                                  WHERE N.id = C.node_id
                                    AND C.person_id = LA.person_id
                                    AND LA.ip_address = IP.ip_address)) as countries,
          (SELECT array(SELECT C.person_id 
                          FROM Collaborations C 
                         WHERE C.node_id = N.node_id)) as people

     FROM nodes N ;


CREATE TABLE model_collaborator_declared_countries
AS SELECT N.id, 
          (SELECT array(SELECT DISTINCT country_name
                                   FROM Collaborations C, People P
                                  WHERE N.id = C.node_id
                                    AND C.person_id = P.id)) as countries,
          (SELECT array(SELECT C.person_id 
                          FROM Collaborations C 
                         WHERE C.node_id = N.id)) as people

     FROM nodes N ;
