BEGIN;

DROP TABLE IF EXISTS model_collaborator_countries;
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
                         WHERE C.node_id = N.id)) as people

     FROM nodes N ;


DROP TABLE IF EXISTS model_collaborator_declared_countries;
CREATE TABLE model_collaborator_declared_countries
AS SELECT N.id as node_id,
          (SELECT array(SELECT DISTINCT COALESCE(country_name, 

                                    (SELECT
                                             array_to_string(regexp_matches(IP.location, 'country_name: ([\w ]+)'), '')
                                        FROM logged_actions LA, ip_locations IP
                                       WHERE IP.ip_address = LA.ip_address
                                         AND IP.location IS NOT NULL
                                         AND LA.person_id = P.id
                                    ORDER BY LA.id
                                       LIMIT 1))
                                   FROM Collaborations C, People P
                                  WHERE N.id = C.node_id
                                    AND C.person_id = P.id)) as countries,
          (SELECT array(SELECT C.person_id 
                          FROM Collaborations C 
                         WHERE C.node_id = N.id)) as people

     FROM nodes N ;

DROP TABLE IF EXISTS model_viewer_declared_countries;
CREATE TABLE model_viewer_declared_countries
AS SELECT N.id as node_id,
          (SELECT COUNT(*) 
             FROM model_views MV
            WHERE MV.node_id = N.id) as people,
          (SELECT array(SELECT DISTINCT array_to_string(regexp_matches(IP.location, 
                                                                       'country_code: (\w+)'), '')
                                   FROM logged_actions LA, ip_locations IP
                                  WHERE N.id = LA.node_id
                                    AND LA.action = 'one_model'
                                    AND LA.ip_address = IP.ip_address
                                    AND IP.location IS NOT NULL)) as countries
    FROM Nodes N;

CREATE OR REPLACE VIEW viewers_vs_collaborators_view AS
SELECT VIEWERS.node_id,
       VIEWERS.people as number_of_viewers,
       array_length(COLLABORATORS.people, 1) as number_of_collaborators,
       array_length(VIEWERS.countries, 1) as number_of_view_countries,
       array_length(COLLABORATORS.countries, 1) as number_of_collaborator_countries,

       VIEWERS.people / array_length(COLLABORATORS.people, 1)::float as viewer_people_factor,
       array_length(VIEWERS.countries, 1) / array_length(COLLABORATORS.countries, 1)::float as viewer_countries_factor

  FROM model_viewer_declared_countries VIEWERS,
       model_collaborator_declared_countries COLLABORATORS
 WHERE COLLABORATORS.node_id = VIEWERS.node_id
   AND array_length(COLLABORATORS.people, 1) > 1;

-- Discussing countries

DROP TABLE IF EXISTS model_poster_declared_countries CASCADE;
CREATE TABLE model_poster_declared_countries
AS SELECT N.id as node_id,
          N.group_id, N.visibility_id, N.changeability_id,
          (SELECT array(SELECT DISTINCT COALESCE(PE.country_name, 

                                    (SELECT
                                             array_to_string(regexp_matches(IP.location, 'country_name: ([\w ]+)'), '')
                                        FROM logged_actions LA, ip_locations IP
                                       WHERE IP.ip_address = LA.ip_address
                                         AND IP.location IS NOT NULL
                                         AND LA.person_id = PE.id
                                    ORDER BY LA.id
                                       LIMIT 1))
                                   FROM Postings PO, People PE
                                  WHERE N.id = PO.node_id
                                    AND PO.deleted_at IS NULL
                                    AND PO.person_id = PE.id)) as countries,
          (SELECT array(SELECT PO.person_id 
                          FROM Postings PO 
                         WHERE PO.node_id = N.id)) as people
     FROM nodes N 
    WHERE N.id IN (SELECT node_id FROM Postings WHERE deleted_at IS NULL);

CREATE OR REPLACE VIEW posting_countries_and_people_view
AS
  SELECT node_id, countries, people, group_id, 
         (SELECT short_form from Permission_Settings WHERE id = visibility_id) as read_permission,
         (SELECT short_form from Permission_Settings WHERE id = changeability_id) as write_permission,
         array_length(countries, 1) as number_of_countries, 
         array_length(people, 1) as number_of_people  
    FROM model_poster_declared_countries  
ORDER BY number_of_countries;

DROP TABLE IF EXISTS Person_Interests CASCADE;
CREATE TABLE Person_Interests AS
SELECT P.id as person_id,
      (SELECT array(SELECT DISTINCT tn.tag_id 
         FROM model_views mv, tagged_nodes tn
        WHERE tn.node_id = mv.node_id
          AND mv.person_id = P.id)) as tag_ids,
      (SELECT array(SELECT DISTINCT MV.node_id
                      FROM Model_Views MV
                     WHERE MV.person_id = P.id)) as node_ids,
      (SELECT P.ID IN (SELECT person_id FROM collaborations)) as is_collaborator
  FROM People P 

;
DELETE FROM Person_Interests WHERE array_length(tag_ids, 1) IS NULL;

-- Now I know what people's interests are, and I know if they're collaborators
-- Now, for each model, we want all of the interests for all of the collaborators

CREATE OR REPLACE VIEW Collaborators_Aggregate_Tags_View
AS
SELECT DISTINCT C.node_id,
       (SELECT (ARRAY(SELECT DISTINCT unnest(PI.tag_ids)
          FROM Person_Interests PI 
         WHERE PI.person_id IN (SELECT C2.person_id FROM collaborations C2 WHERE C2.node_id = C.node_id)))) as tag_ids
  FROM Collaborations C
 WHERE C.node_id IN (SELECT node_id 
                       FROM viewers_vs_collaborators_view
                      WHERE number_of_collaborators > 1);

CREATE OR REPLACE VIEW Collaborators_Tag_Numbers
AS
SELECT *, 
       COALESCE(array_length(tag_ids, 1), 0) as number_of_interests
  FROM collaborators_aggregate_tags_view ;

CREATE OR REPLACE VIEW Viewers_Aggregate_Tags_View
AS
SELECT DISTINCT MV.node_id,
       (SELECT (ARRAY(SELECT DISTINCT unnest(PI.tag_ids)
          FROM Person_Interests PI 
         WHERE PI.person_id IN (SELECT MV2.person_id FROM Model_Views MV2 WHERE MV.node_id = MV2.node_id)))) as tag_ids
  FROM Model_Views MV
 WHERE MV.node_id IN (SELECT node_id 
                       FROM viewers_vs_collaborators_view
                      WHERE number_of_collaborators > 1);

CREATE OR REPLACE VIEW Viewers_Tag_Numbers
AS
SELECT *, 
       COALESCE(array_length(tag_ids, 1), 0) as number_of_interests
  FROM viewers_aggregate_tags_view ;


CREATE OR REPLACE VIEW viewer_and_collaborator_tag_summary_view
AS
SELECT VTN.node_id, 

       CTN.tag_ids as collaborator_tag_ids, 
       coalesce(array_length(CTN.tag_ids,1), 0) as collaborator_tag_length, 
       (SELECT COUNT(*) 
          FROM Collaborations C
         WHERE C.node_id = VTN.node_id) as number_of_collaborators,

       VTN.tag_ids as viewer_tag_ids, 
       coalesce(array_length(VTN.tag_ids, 1), 0) as viewer_tag_length,
       (SELECT COUNT(DISTINCT MV.person_id) 
          FROM Model_Views MV
         WHERE MV.node_id = VTN.node_id) as number_of_viewers

  FROM collaborators_tag_numbers CTN, viewers_tag_numbers VTN
 WHERE CTN.node_id = VTN.node_id;


SELECT *, 
       collaborator_tag_length / number_of_collaborators::float as tag_collaborator_ratio, 
       viewer_tag_length / number_of_viewers::float as tag_viewer_ratio
  FROM viewer_and_collaborator_tag_summary_view
 WHERE number_of_collaborators > 0 
   AND number_of_viewers > 0;

CREATE OR REPLACE VIEW multi_person_collaborations_view 
      AS
  SELECT count(*) AS number_of_collaborators, 
        node_id from collaborations 
GROUP BY node_id 
  HAVING count(*) > 1;


CREATE OR REPLACE VIEW models_per_collaborator_view
    AS
SELECT COUNT(*) as number_of_models, 
       node_id
  FROM collaborations 
 WHERE node_id IN (SELECT node_id
                     FROM multi_person_collaborations_view ) 
GROUP BY node_id;


-- for each tag that any of a model's collaborators have viewed, how
-- many of the collaborators have viewed the tag? For example, if
-- there are three collaborators on model M, then what proportion of
-- those three have seen tags T1 and T2 on other models?

CREATE OR REPLACE VIEW
multi_collaborators_for_node_and_tag
AS
SELECT MPCV.node_id, 
       VCTSV.number_of_collaborators, 
       unnest(VCTSV.collaborator_tag_ids) as tag_id,
       (SELECT array(select person_id 
                       FROM Collaborations C
                      WHERE C.node_id = MPCV.node_id)) as collaborators
  FROM multi_person_collaborations_view MPCV, 
       viewer_and_collaborator_tag_summary_view VCTSV 
 WHERE VCTSV.node_id = MPCV.node_id
;

WITH
separate_collaborators_nodes_and_tags AS
  (SELECT node_id, 
         number_of_collaborators,
         tag_id,
         UNNEST(collaborators) as person_id
     FROM multi_collaborators_for_node_and_tag),

collaborators_by_tag AS 
   (
    SELECT DISTINCT SCNT.node_id, SCNT.tag_id, SCNT.person_id
      FROM Model_Views MV, separate_collaborators_nodes_and_tags SCNT
     WHERE MV.node_id = SCNT.node_id 
      AND MV.person_id = MV.person_id)

SELECT * FROM collaborators_by_tag
;


-- Take each model, and get its collaborators.
-- For each collaborator, get his or her interests (via views)
-- Then we can calculate the proportion of collaborators who shared a tag

CREATE OR REPLACE VIEW model_and_collaborators_and_interests
AS
WITH 
  all_nodes_and_collaborators AS
  (SELECT id as node_id, ARRAY(SELECT C.person_id
                                 FROM Collaborations C
                                WHERE C.node_id = N.id) as collaborators

     FROM Nodes N),

  multi_person_nodes_and_collaborators AS
  (SELECT node_id, collaborators
     FROM all_nodes_and_collaborators
    WHERE array_length(collaborators, 1) > 1),

  unwound_collaborators AS
  (SELECT node_id, collaborators,
          UNNEST(collaborators) as person_id
     FROM multi_person_nodes_and_collaborators),

  collaborators_and_interests AS
  (SELECT UC.node_id,
          UC.person_id,
          UC.collaborators,
          array_remove(UC.collaborators, UC.person_id) as other_collaborators,
          PI.tag_ids as person_tag_ids,
          ARRAY(SELECT UNNEST(PI.tag_ids)
                  FROM Person_Interests PI
                 WHERE PI.person_id = ANY(UC.collaborators)
                   AND PI.person_id <> UC.person_id) as other_person_tag_ids
     FROM unwound_collaborators UC, person_interests PI
    WHERE UC.person_id = PI.person_id
 ORDER BY node_id, person_id),

  node_person_interest_overlap AS
  (SELECT node_id, person_id, collaborators, 
       other_collaborators, person_tag_ids, 
       other_person_tag_ids,
       (SELECT ARRAY(SELECT UNNEST(person_tag_ids)
                     INTERSECT
                     SELECT UNNEST(other_person_tag_ids))) as interests_shared_by_others
  FROM collaborators_and_interests),

  collaborator_tag_sharing_stats AS
    (SELECT node_id, person_id, collaborators, 
            array_length(collaborators, 1) as number_of_collaborators, 
            other_collaborators, person_tag_ids, 
	   other_person_tag_ids, interests_shared_by_others,
	   array_length(interests_shared_by_others, 1)::float / array_length(person_tag_ids, 1) as proportion_of_my_interests_shared_by_others
      FROM node_person_interest_overlap),

   final_summary AS (
  select node_id, 
         avg(proportion_of_my_interests_shared_by_others) as average_proportion_of_interests_shared_by_others from collaborator_tag_sharing_stats group by node_id)

SELECT * FROM final_summary 
    ;

-- -- Timing of collaborations
-- WITH  all_nodes_and_collaborators AS
--   (SELECT id as node_id, ARRAY(SELECT C.person_id
--                                  FROM Collaborations C
--                                 WHERE C.node_id = N.id) as collaborators

--      FROM Nodes N),

--   multi_person_nodes_and_collaborators AS
--   (SELECT node_id, collaborators
--      FROM all_nodes_and_collaborators
--     WHERE array_length(collaborators, 1) > 1),



--   all_nodes_and_collaborators AS
--   (SELECT id as node_id, ARRAY(SELECT C.person_id
--                                  FROM Collaborations C
--                                 WHERE C.node_id = N.id) as collaborators

--      FROM Nodes N),


-- Now we need to do something similar, but for each pair of users.
-- How many interests are shared among our people?
-- And is a shared set of interests likely to lead to collaboration?

-- The end result will need to be an adjacency matrix, in which the
-- rows and columns are the person IDs, and the cells contain the
-- proportion of shared interests.


CREATE OR REPLACE VIEW shared_interests_view 
AS
WITH 

  people_by_people AS
  (SELECT P1.id as person1_id, P2.id AS person2_id
     FROM People P1, People P2
    WHERE P1.id in (SELECT person_id FROM Collaborations)
      AND P2.id in (SELECT person_id FROM Collaborations)
 ORDER BY P1, P2),

  pp_with_interests AS
  (SELECT PP.person1_id, PI1.tag_ids as person1_interests,
          PP.person2_id, PI2.tag_ids as person2_interests
     FROM people_by_people PP, Person_Interests PI1, Person_Interests PI2
    WHERE PP.person1_id = PI1.person_id
      AND PP.person2_id = PI2.person_id),

  pp_with_interest_overlap AS
  (SELECT person1_id, person1_interests, 
          array_length(person1_interests, 1) as person1_interests_length,
          person2_id, person2_interests,
          array_length(person2_interests, 1) as person2_interests_length,
          (SELECT ARRAY(SELECT UNNEST(person1_interests)
                        INTERSECT
                        SELECT UNNEST(person2_interests))) as interests_intersection,
          (SELECT ARRAY(SELECT UNNEST(person1_interests)
                        UNION
                        SELECT UNNEST(person2_interests))) as interests_union
     FROM pp_with_interests),

  shared_interest_lengths AS
  (SELECT person1_id, person1_interests, person1_interests_length,
          person2_id, person2_interests, person2_interests_length,
          interests_intersection, 
          array_length(interests_intersection, 1) as interests_intersection_length,
          interests_union, 
          array_length(interests_union, 1) as interests_union_length
     FROM pp_with_interest_overlap),

  shared_interest_calculation AS
  (SELECT person1_id, person1_interests, person1_interests_length,
          person2_id, person2_interests, person2_interests_length,
          interests_intersection, interests_intersection_length,
          interests_union, interests_union_length,
          (interests_union_length::float / interests_intersection_length) as jaccard_similarity
     FROM shared_interest_lengths)

SELECT * FROM shared_interest_calculation
ORDER BY person1_id, person2_id ;


-- Get all models and people for models with two collaborators or more
-- How long since they joined the Modeling Commons?


CREATE OR REPLACE VIEW posters_to_ccl_nodes
AS
WITH non_ccl_nodes AS
    (SELECT id as node_id
       FROM Nodes
      WHERE group_id <> 2),

    author_collaborators AS
    (SELECT V.node_id, V.person_id as collaborator_id,
            V.created_at as collaborated_at
       FROM Versions V
      WHERE V.node_id in (SELECT node_id FROM multi_person_collaborations_view)
        AND V.node_id NOT IN (SELECT node_id FROM non_ccl_nodes)
        AND V.node_id IN (SELECT id FROM Nodes) 
        AND V.person_id IN (SELECT id FROM People) 
        AND V.person_id <> (SELECT V2.person_id 
                              FROM Versions V2 
                             WHERE V2.node_id = V.node_id
                          ORDER BY V2.created_at
                             LIMIT 1)),

    non_author_collaborators AS
    (SELECT NMC.node_id, NMC.non_member_collaborator_id as collaborator_id,
	   NMC.created_at as collaborated_at
      FROM Non_Member_Collaborations NMC, Nodes N
     WHERE N.id = NMC.node_id
       AND NMC.node_id NOT IN (SELECT node_id FROM non_ccl_nodes)),

    all_nodes_and_collaborators AS
    (SELECT node_id, 'member' as member_or_not, collaborator_id, collaborated_at FROM author_collaborators
     UNION
     SELECT node_id, 'nonmember' as member_or_not, collaborator_id, collaborated_at FROM non_author_collaborators),

  nodes_and_collaborators_and_join_delay AS
    (SELECT ANC.node_id, ANC.member_or_not, 
            ANC.collaborator_id, ANC.collaborated_at, N.created_at, 
            (ANC.collaborated_at - N.created_at) as time_until_collaborated,
            extract(epoch from ANC.collaborated_at - N.created_at) as seconds_until_collaborated,
            extract(dow from ANC.collaborated_at) as day_of_joining
     FROM all_nodes_and_collaborators ANC, Nodes N
    WHERE ANC.node_id = N.id
      AND ANC.collaborated_at >= '2013-jul-1'
 ORDER BY node_id, member_or_not)

SELECT count(*), day_of_joining 
  FROM nodes_and_collaborators_and_join_delay 
GROUP BY day_of_joining
;




CREATE OR REPLACE VIEW posters_to_non_ccl_nodes
AS
WITH non_ccl_nodes AS
    (SELECT id as node_id, 
            created_at as node_created_at
       FROM Nodes
      WHERE group_id <> 2),

    node_posters AS
    (SELECT P.node_id, P.person_id, P.created_at as posted_at, NCN.node_created_at
       FROM Postings P, non_ccl_nodes NCN
      WHERE P.node_id = NCN.node_id
        AND P.deleted_at IS NULL)

SELECT * FROM node_posters
ORDER BY node_id, posted_at
;


-- Postings and people
CREATE OR REPLACE VIEW postings_and_people
AS
WITH
  undeleted_postings AS
    (SELECT id as posting_id, person_id, node_id, created_at as posting_created_at, is_question
     FROM Postings
     WHERE deleted_at IS NULL),

  postings_and_people AS
    (SELECT PO.posting_id, PO.person_id, PO.node_id, PO.posting_created_at, PO.is_question,
           PE.created_at as person_created_at
      FROM undeleted_postings PO, People PE
     WHERE PO.person_id = PE.id),

  ccl_models AS
    (SELECT id
       FROM Nodes
      WHERE group_id = 2),

  ccl_people AS
    (SELECT P.id
       FROM People P, Memberships M
      WHERE P.id = M.person_id
        AND M.group_id = 2),

  multi_posting_nodes AS
    (SELECT COUNT(*), node_id 
       FROM undeleted_postings 
   GROUP BY node_id
     HAVING count(*) > 1)

SELECT PP.posting_id, PP.person_id, PP.node_id, PP.posting_created_at,
       extract(epoch from posting_created_at - person_created_at) as secs_to_first_posting
       FROM postings_and_people PP
      WHERE PP.posting_id = (SELECT P.id 
                               FROM Postings P
                              WHERE P.person_id = PP.person_id
                                AND P.node_id = PP.node_id
                           ORDER BY P.created_at
                              LIMIT 1)
        AND PP.person_id NOT IN (SELECT id FROM People WHERE administrator = 'true')
   ORDER BY secs_to_first_posting

;

-- Did people post on their own models, or only on other people's models?
CREATE OR REPLACE VIEW post_on_own_or_other_models_view
AS
WITH
  undeleted_postings AS
    (SELECT id as posting_id, person_id, node_id, created_at as posting_created_at, is_question
     FROM Postings
     WHERE deleted_at IS NULL),

  postings_and_people AS
    (SELECT PO.posting_id, PO.person_id, PO.node_id, PO.posting_created_at, PO.is_question,
           PE.created_at as person_created_at
      FROM undeleted_postings PO, People PE
     WHERE PO.person_id = PE.id),

  postings_and_first_collaborations AS

    (SELECT PP.posting_id, PP.person_id, PP.node_id, PP.posting_created_at, PP.person_created_at,
           (SELECT C.created_at as collaboration_created_at
              FROM Collaborations C
             WHERE C.person_id = PP.person_id
          ORDER BY C.created_at
             LIMIT 1) as first_collaborated_at
      FROM postings_and_people PP
     WHERE PP.person_id NOT IN (SELECT C.person_id
                                  FROM Collaborations C
                                 WHERE C.node_id = PP.node_id)
       AND PP.person_id NOT IN (SELECT id FROM People WHERE administrator = 'true')),

  postings_and_collaboration_vs_posting AS
  (SELECT *,
	   extract(epoch from (PC.first_collaborated_at - PC.posting_created_at)) as collaboration_discussion_difference
     FROM postings_and_first_collaborations PC
    WHERE PC.first_collaborated_at is not null)

SELECT * from postings_and_collaboration_vs_posting
 WHERE collaboration_discussion_difference < 0
;

-- Did they collaborate before they posted?  Or post before they collaborated?

-- [local]/nlcommons_development=# select distinct  C.person_id, C.created_at as collaboration_created_at, P.created_at as posting_created_at, P.created_at - C.created_at from collaborations C, postings P where P.person_id = C.person_id and P.id = (SELECT id from postings where person_id = P.person_id order by created_at limit 1) order by person_id;

COMMIT;
