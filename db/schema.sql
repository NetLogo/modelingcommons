--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: statinfo; Type: TYPE; Schema: public; Owner: nlcommons
--

CREATE TYPE public.statinfo AS (
	word text,
	ndoc integer,
	nentry integer
);


ALTER TYPE public.statinfo OWNER TO nlcommons;

--
-- Name: tokenout; Type: TYPE; Schema: public; Owner: nlcommons
--

CREATE TYPE public.tokenout AS (
	tokid integer,
	token text
);


ALTER TYPE public.tokenout OWNER TO nlcommons;

--
-- Name: tokentype; Type: TYPE; Schema: public; Owner: nlcommons
--

CREATE TYPE public.tokentype AS (
	tokid integer,
	alias text,
	descr text
);


ALTER TYPE public.tokentype OWNER TO nlcommons;

--
-- Name: tsdebug; Type: TYPE; Schema: public; Owner: nlcommons
--

CREATE TYPE public.tsdebug AS (
	ts_name text,
	tok_type text,
	description text,
	token text,
	dict_name text[]
);


ALTER TYPE public.tsdebug OWNER TO nlcommons;

--
-- Name: _get_parser_from_curcfg(); Type: FUNCTION; Schema: public; Owner: nlcommons
--

CREATE FUNCTION public._get_parser_from_curcfg() RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ select prs_name from pg_ts_cfg where oid = show_curcfg() $$;


ALTER FUNCTION public._get_parser_from_curcfg() OWNER TO nlcommons;

--
-- Name: get_password_from_email(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_password_from_email(email character varying) RETURNS TABLE(id integer, first_name character varying, last_name character varying, password character varying, salt character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
SELECT
  id, first_name, last_name, password, salt
    FROM
        people
    WHERE
         email_address = email;
END; $$;


ALTER FUNCTION public.get_password_from_email(email character varying) OWNER TO postgres;

--
-- Name: ts_debug(text); Type: FUNCTION; Schema: public; Owner: nlcommons
--

CREATE FUNCTION public.ts_debug(text) RETURNS SETOF public.tsdebug
    LANGUAGE sql STRICT
    AS $_$
select
        m.ts_name,
        t.alias as tok_type,
        t.descr as description,
        p.token,
        m.dict_name,
        strip(to_tsvector(p.token)) as tsvector
from
        parse( _get_parser_from_curcfg(), $1 ) as p,
        token_type() as t,
        pg_ts_cfgmap as m,
        pg_ts_cfg as c
where
        t.tokid=p.tokid and
        t.alias = m.tok_alias and
        m.ts_name=c.ts_name and
        c.oid=show_curcfg()
$_$;


ALTER FUNCTION public.ts_debug(text) OWNER TO nlcommons;

--
-- Name: wow(text); Type: FUNCTION; Schema: public; Owner: nlcommons
--

CREATE FUNCTION public.wow(text) RETURNS text
    LANGUAGE sql
    AS $_$select $1 || ' copyright'; $_$;


ALTER FUNCTION public.wow(text) OWNER TO nlcommons;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: attachments; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.attachments (
    id integer NOT NULL,
    node_id integer NOT NULL,
    person_id integer NOT NULL,
    description character varying(255) NOT NULL,
    contents bytea NOT NULL,
    filename character varying(255) NOT NULL,
    content_type character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.attachments OWNER TO nlcommons;

--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.attachments_id_seq OWNER TO nlcommons;

--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.attachments_id_seq OWNED BY public.attachments.id;


--
-- Name: nodes; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.nodes (
    id integer NOT NULL,
    parent_id integer,
    name text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    visibility_id integer DEFAULT 1 NOT NULL,
    changeability_id integer DEFAULT 1 NOT NULL,
    group_id integer,
    wants_help boolean DEFAULT false NOT NULL
);


ALTER TABLE public.nodes OWNER TO nlcommons;

--
-- Name: ccl_model_creations_per_month; Type: VIEW; Schema: public; Owner: nlcommons
--

CREATE VIEW public.ccl_model_creations_per_month AS
 SELECT to_char(nodes.created_at, 'YY MM'::text) AS yearmonth,
    count(*) AS count
   FROM public.nodes
  WHERE (nodes.group_id = 2)
  GROUP BY to_char(nodes.created_at, 'YY MM'::text)
  ORDER BY to_char(nodes.created_at, 'YY MM'::text);


ALTER TABLE public.ccl_model_creations_per_month OWNER TO nlcommons;

--
-- Name: collaborations; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.collaborations (
    id integer NOT NULL,
    person_id integer,
    node_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    collaborator_type_id integer
);


ALTER TABLE public.collaborations OWNER TO nlcommons;

--
-- Name: collaborations_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.collaborations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.collaborations_id_seq OWNER TO nlcommons;

--
-- Name: collaborations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.collaborations_id_seq OWNED BY public.collaborations.id;


--
-- Name: collaborator_types; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.collaborator_types (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.collaborator_types OWNER TO nlcommons;

--
-- Name: collaborator_types_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.collaborator_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.collaborator_types_id_seq OWNER TO nlcommons;

--
-- Name: collaborator_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.collaborator_types_id_seq OWNED BY public.collaborator_types.id;


--
-- Name: logged_actions; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.logged_actions (
    id integer NOT NULL,
    person_id integer,
    logged_at timestamp without time zone,
    message text,
    ip_address character varying(255),
    browser_info text,
    url text,
    params text NOT NULL,
    session text,
    cookies text,
    flash text,
    referrer text,
    node_id integer,
    controller text,
    action text,
    is_searchbot boolean DEFAULT false NOT NULL
);


ALTER TABLE public.logged_actions OWNER TO nlcommons;

--
-- Name: people; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.people (
    id integer NOT NULL,
    email_address character varying(255),
    first_name character varying(255),
    last_name character varying(255),
    password character varying(255),
    administrator boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    avatar_file_name text,
    avatar_content_type character varying(255),
    avatar_file_size integer,
    avatar_updated_at timestamp without time zone,
    salt character varying(255),
    registration_consent boolean DEFAULT false,
    sex character varying(255),
    birthdate date,
    country_name character varying(255),
    send_site_updates boolean DEFAULT true,
    send_model_updates boolean DEFAULT true,
    send_tag_updates boolean DEFAULT true,
    url character varying(255),
    biography text,
    show_email_address boolean DEFAULT false
);


ALTER TABLE public.people OWNER TO nlcommons;

--
-- Name: versions; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.versions (
    id integer NOT NULL,
    node_id integer NOT NULL,
    person_id integer NOT NULL,
    description text NOT NULL,
    contents text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.versions OWNER TO nlcommons;

--
-- Name: create_view_models_view; Type: VIEW; Schema: public; Owner: nlcommons
--

CREATE VIEW public.create_view_models_view AS
 SELECT p.id,
    ( SELECT min(v.created_at) AS min
           FROM public.versions v
          WHERE (v.person_id = p.id)) AS earliest_version_creation,
    ( SELECT min(l.logged_at) AS min
           FROM public.logged_actions l
          WHERE (((p.id = l.person_id) AND (l.controller = 'browse'::text)) AND (l.action = 'one_model'::text))) AS earliest_view_model
   FROM public.people p
  ORDER BY p.id;


ALTER TABLE public.create_view_models_view OWNER TO nlcommons;

--
-- Name: email_recommendations; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.email_recommendations (
    id integer NOT NULL,
    person_id integer,
    recipient_email_address character varying(255),
    node_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.email_recommendations OWNER TO nlcommons;

--
-- Name: email_recommendations_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.email_recommendations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.email_recommendations_id_seq OWNER TO nlcommons;

--
-- Name: email_recommendations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.email_recommendations_id_seq OWNED BY public.email_recommendations.id;


--
-- Name: foobar; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.foobar (
    id integer NOT NULL,
    ip_address text,
    new_inet inet
);


ALTER TABLE public.foobar OWNER TO nlcommons;

--
-- Name: foobar_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.foobar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.foobar_id_seq OWNER TO nlcommons;

--
-- Name: foobar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.foobar_id_seq OWNED BY public.foobar.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.groups (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.groups OWNER TO nlcommons;

--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.groups_id_seq OWNER TO nlcommons;

--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: hits_and_days_view; Type: VIEW; Schema: public; Owner: nlcommons
--

CREATE VIEW public.hits_and_days_view AS
 SELECT count(*) AS count,
    (logged_actions.logged_at)::date AS logged_at,
    date_part('dow'::text, (logged_actions.logged_at)::date) AS date_part
   FROM public.logged_actions
  WHERE (logged_actions.is_searchbot = false)
  GROUP BY (logged_actions.logged_at)::date
  ORDER BY (logged_actions.logged_at)::date;


ALTER TABLE public.hits_and_days_view OWNER TO nlcommons;

--
-- Name: hits_and_months_view; Type: VIEW; Schema: public; Owner: nlcommons
--

CREATE VIEW public.hits_and_months_view AS
 SELECT count(*) AS count,
    ((date_part('year'::text, (logged_actions.logged_at)::date) || '-'::text) || date_part('month'::text, (logged_actions.logged_at)::date))
   FROM public.logged_actions
  WHERE (logged_actions.is_searchbot = false)
  GROUP BY ((date_part('year'::text, (logged_actions.logged_at)::date) || '-'::text) || date_part('month'::text, (logged_actions.logged_at)::date))
  ORDER BY ((date_part('year'::text, (logged_actions.logged_at)::date) || '-'::text) || date_part('month'::text, (logged_actions.logged_at)::date));


ALTER TABLE public.hits_and_months_view OWNER TO nlcommons;

--
-- Name: ip_locations; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.ip_locations (
    id integer NOT NULL,
    ip_address character varying(255),
    location text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.ip_locations OWNER TO nlcommons;

--
-- Name: ip_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.ip_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ip_locations_id_seq OWNER TO nlcommons;

--
-- Name: ip_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.ip_locations_id_seq OWNED BY public.ip_locations.id;


--
-- Name: logged_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.logged_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.logged_actions_id_seq OWNER TO nlcommons;

--
-- Name: logged_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.logged_actions_id_seq OWNED BY public.logged_actions.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.memberships (
    id integer NOT NULL,
    person_id integer,
    group_id integer,
    is_administrator boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    status text DEFAULT 'pending'::text NOT NULL
);


ALTER TABLE public.memberships OWNER TO nlcommons;

--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.memberships_id_seq OWNER TO nlcommons;

--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.memberships_id_seq OWNED BY public.memberships.id;


--
-- Name: model_collaborator_countries; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.model_collaborator_countries (
    id integer,
    countries text[]
);


ALTER TABLE public.model_collaborator_countries OWNER TO nlcommons;

--
-- Name: model_downloads; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.model_downloads (
    logged_at timestamp without time zone,
    ip_address text,
    node_id integer,
    person_id integer
);


ALTER TABLE public.model_downloads OWNER TO nlcommons;

--
-- Name: model_runs; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.model_runs (
    logged_at timestamp without time zone,
    ip_address text,
    node_id integer,
    person_id integer
);


ALTER TABLE public.model_runs OWNER TO nlcommons;

--
-- Name: model_view_counts; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.model_view_counts (
    count bigint,
    node_id integer
);


ALTER TABLE public.model_view_counts OWNER TO nlcommons;

--
-- Name: model_view_download_countries; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.model_view_download_countries (
    node_id integer,
    country_codes text[]
);


ALTER TABLE public.model_view_download_countries OWNER TO nlcommons;

--
-- Name: model_views; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.model_views (
    logged_at timestamp without time zone,
    ip_address text,
    node_id integer,
    person_id integer
);


ALTER TABLE public.model_views OWNER TO nlcommons;

--
-- Name: month_year_referrers; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.month_year_referrers (
    to_char text,
    referrer text,
    controller text,
    action text
);


ALTER TABLE public.month_year_referrers OWNER TO nlcommons;

--
-- Name: news_items; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.news_items (
    id integer NOT NULL,
    title character varying(255),
    body text,
    person_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.news_items OWNER TO nlcommons;

--
-- Name: news_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.news_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.news_items_id_seq OWNER TO nlcommons;

--
-- Name: news_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.news_items_id_seq OWNED BY public.news_items.id;


--
-- Name: node_projects; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.node_projects (
    id integer NOT NULL,
    project_id integer,
    node_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.node_projects OWNER TO nlcommons;

--
-- Name: node_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.node_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.node_projects_id_seq OWNER TO nlcommons;

--
-- Name: node_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.node_projects_id_seq OWNED BY public.node_projects.id;


--
-- Name: nodes_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.nodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.nodes_id_seq OWNER TO nlcommons;

--
-- Name: nodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.nodes_id_seq OWNED BY public.nodes.id;


--
-- Name: non_ccl_model_creations_per_month; Type: VIEW; Schema: public; Owner: nlcommons
--

CREATE VIEW public.non_ccl_model_creations_per_month AS
 SELECT to_char(nodes.created_at, 'YY MM'::text) AS yearmonth,
    count(*) AS count
   FROM public.nodes
  WHERE (nodes.group_id <> 2)
  GROUP BY to_char(nodes.created_at, 'YY MM'::text)
  ORDER BY to_char(nodes.created_at, 'YY MM'::text);


ALTER TABLE public.non_ccl_model_creations_per_month OWNER TO nlcommons;

--
-- Name: non_member_collaborations; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.non_member_collaborations (
    id integer NOT NULL,
    non_member_collaborator_id integer,
    node_id integer,
    collaborator_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    person_id integer NOT NULL
);


ALTER TABLE public.non_member_collaborations OWNER TO nlcommons;

--
-- Name: non_member_collaborations_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.non_member_collaborations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.non_member_collaborations_id_seq OWNER TO nlcommons;

--
-- Name: non_member_collaborations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.non_member_collaborations_id_seq OWNED BY public.non_member_collaborations.id;


--
-- Name: non_member_collaborators; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.non_member_collaborators (
    id integer NOT NULL,
    email character varying(255),
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.non_member_collaborators OWNER TO nlcommons;

--
-- Name: non_member_collaborators_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.non_member_collaborators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.non_member_collaborators_id_seq OWNER TO nlcommons;

--
-- Name: non_member_collaborators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.non_member_collaborators_id_seq OWNED BY public.non_member_collaborators.id;


--
-- Name: people_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.people_id_seq OWNER TO nlcommons;

--
-- Name: people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.people_id_seq OWNED BY public.people.id;


--
-- Name: permission_settings; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.permission_settings (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    short_form character varying(255)
);


ALTER TABLE public.permission_settings OWNER TO nlcommons;

--
-- Name: permission_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.permission_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.permission_settings_id_seq OWNER TO nlcommons;

--
-- Name: permission_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.permission_settings_id_seq OWNED BY public.permission_settings.id;


--
-- Name: permissions_changed_log_view; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.permissions_changed_log_view (
    count bigint,
    id text
);


ALTER TABLE public.permissions_changed_log_view OWNER TO nlcommons;

SET default_with_oids = true;

--
-- Name: pg_ts_cfg; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.pg_ts_cfg (
    ts_name text NOT NULL,
    prs_name text NOT NULL,
    locale text
);


ALTER TABLE public.pg_ts_cfg OWNER TO nlcommons;

--
-- Name: pg_ts_cfgmap; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.pg_ts_cfgmap (
    ts_name text NOT NULL,
    tok_alias text NOT NULL,
    dict_name text[]
);


ALTER TABLE public.pg_ts_cfgmap OWNER TO nlcommons;

--
-- Name: pg_ts_dict; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.pg_ts_dict (
    dict_name text NOT NULL,
    dict_init regprocedure,
    dict_initoption text,
    dict_lexize regprocedure NOT NULL,
    dict_comment text
);


ALTER TABLE public.pg_ts_dict OWNER TO nlcommons;

--
-- Name: pg_ts_parser; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.pg_ts_parser (
    prs_name text NOT NULL,
    prs_start regprocedure NOT NULL,
    prs_nexttoken regprocedure NOT NULL,
    prs_end regprocedure NOT NULL,
    prs_headline regprocedure NOT NULL,
    prs_lextype regprocedure NOT NULL,
    prs_comment text
);


ALTER TABLE public.pg_ts_parser OWNER TO nlcommons;

--
-- Name: popular_pages_view; Type: VIEW; Schema: public; Owner: nlcommons
--

CREATE VIEW public.popular_pages_view AS
 SELECT count(*) AS count,
    logged_actions.controller,
    logged_actions.action
   FROM public.logged_actions
  WHERE (logged_actions.is_searchbot = false)
  GROUP BY logged_actions.controller, logged_actions.action
  ORDER BY count(*) DESC;


ALTER TABLE public.popular_pages_view OWNER TO nlcommons;

SET default_with_oids = false;

--
-- Name: postings; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.postings (
    id integer NOT NULL,
    person_id integer,
    node_id integer,
    title character varying(255),
    body text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    parent_id integer,
    is_question boolean DEFAULT false NOT NULL,
    deleted_at timestamp without time zone,
    answered_at timestamp without time zone
);


ALTER TABLE public.postings OWNER TO nlcommons;

--
-- Name: posting_count_view; Type: VIEW; Schema: public; Owner: nlcommons
--

CREATE VIEW public.posting_count_view AS
 SELECT count(*) AS count,
    postings.node_id
   FROM public.postings
  WHERE (postings.deleted_at IS NULL)
  GROUP BY postings.node_id
 HAVING (count(*) > 2)
  ORDER BY count(*) DESC;


ALTER TABLE public.posting_count_view OWNER TO nlcommons;

--
-- Name: postings_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.postings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.postings_id_seq OWNER TO nlcommons;

--
-- Name: postings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.postings_id_seq OWNED BY public.postings.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.projects (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    person_id integer,
    group_id integer,
    visibility_id integer,
    changeability_id integer
);


ALTER TABLE public.projects OWNER TO nlcommons;

--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.projects_id_seq OWNER TO nlcommons;

--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: recommendations; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.recommendations (
    id integer NOT NULL,
    node_id integer,
    person_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.recommendations OWNER TO nlcommons;

--
-- Name: recommendations_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.recommendations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.recommendations_id_seq OWNER TO nlcommons;

--
-- Name: recommendations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.recommendations_id_seq OWNED BY public.recommendations.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO nlcommons;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.sessions (
    id integer NOT NULL,
    session_id text NOT NULL,
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.sessions OWNER TO nlcommons;

--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sessions_id_seq OWNER TO nlcommons;

--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: spam_warnings; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.spam_warnings (
    id integer NOT NULL,
    person_id integer,
    node_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.spam_warnings OWNER TO nlcommons;

--
-- Name: spam_warnings_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.spam_warnings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.spam_warnings_id_seq OWNER TO nlcommons;

--
-- Name: spam_warnings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.spam_warnings_id_seq OWNED BY public.spam_warnings.id;


--
-- Name: tagged_nodes; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.tagged_nodes (
    id integer NOT NULL,
    node_id integer,
    tag_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    person_id integer,
    comment text
);


ALTER TABLE public.tagged_nodes OWNER TO nlcommons;

--
-- Name: tagged_models_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.tagged_models_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tagged_models_id_seq OWNER TO nlcommons;

--
-- Name: tagged_models_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.tagged_models_id_seq OWNED BY public.tagged_nodes.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.tags (
    id integer NOT NULL,
    name character varying(255),
    person_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.tags OWNER TO nlcommons;

--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tags_id_seq OWNER TO nlcommons;

--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: test_tsquery; Type: TABLE; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE TABLE public.test_tsquery (
    txtkeyword text,
    txtsample text
);


ALTER TABLE public.test_tsquery OWNER TO nlcommons;

--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: nlcommons
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.versions_id_seq OWNER TO nlcommons;

--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nlcommons
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.attachments ALTER COLUMN id SET DEFAULT nextval('public.attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.collaborations ALTER COLUMN id SET DEFAULT nextval('public.collaborations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.collaborator_types ALTER COLUMN id SET DEFAULT nextval('public.collaborator_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.email_recommendations ALTER COLUMN id SET DEFAULT nextval('public.email_recommendations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.foobar ALTER COLUMN id SET DEFAULT nextval('public.foobar_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.ip_locations ALTER COLUMN id SET DEFAULT nextval('public.ip_locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.logged_actions ALTER COLUMN id SET DEFAULT nextval('public.logged_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.memberships ALTER COLUMN id SET DEFAULT nextval('public.memberships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.news_items ALTER COLUMN id SET DEFAULT nextval('public.news_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.node_projects ALTER COLUMN id SET DEFAULT nextval('public.node_projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.nodes ALTER COLUMN id SET DEFAULT nextval('public.nodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.non_member_collaborations ALTER COLUMN id SET DEFAULT nextval('public.non_member_collaborations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.non_member_collaborators ALTER COLUMN id SET DEFAULT nextval('public.non_member_collaborators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.people ALTER COLUMN id SET DEFAULT nextval('public.people_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.permission_settings ALTER COLUMN id SET DEFAULT nextval('public.permission_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.postings ALTER COLUMN id SET DEFAULT nextval('public.postings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.recommendations ALTER COLUMN id SET DEFAULT nextval('public.recommendations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.spam_warnings ALTER COLUMN id SET DEFAULT nextval('public.spam_warnings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.tagged_nodes ALTER COLUMN id SET DEFAULT nextval('public.tagged_models_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: collaborations_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.collaborations
    ADD CONSTRAINT collaborations_pkey PRIMARY KEY (id);


--
-- Name: collaborator_types_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.collaborator_types
    ADD CONSTRAINT collaborator_types_pkey PRIMARY KEY (id);


--
-- Name: email_recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.email_recommendations
    ADD CONSTRAINT email_recommendations_pkey PRIMARY KEY (id);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: ip_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.ip_locations
    ADD CONSTRAINT ip_locations_pkey PRIMARY KEY (id);


--
-- Name: logged_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.logged_actions
    ADD CONSTRAINT logged_actions_pkey PRIMARY KEY (id);


--
-- Name: memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: news_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.news_items
    ADD CONSTRAINT news_items_pkey PRIMARY KEY (id);


--
-- Name: node_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.node_projects
    ADD CONSTRAINT node_projects_pkey PRIMARY KEY (id);


--
-- Name: nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.nodes
    ADD CONSTRAINT nodes_pkey PRIMARY KEY (id);


--
-- Name: non_member_collaborations_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.non_member_collaborations
    ADD CONSTRAINT non_member_collaborations_pkey PRIMARY KEY (id);


--
-- Name: non_member_collaborators_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.non_member_collaborators
    ADD CONSTRAINT non_member_collaborators_pkey PRIMARY KEY (id);


--
-- Name: people_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: permission_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.permission_settings
    ADD CONSTRAINT permission_settings_pkey PRIMARY KEY (id);


--
-- Name: pg_ts_cfg_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.pg_ts_cfg
    ADD CONSTRAINT pg_ts_cfg_pkey PRIMARY KEY (ts_name);


--
-- Name: pg_ts_cfgmap_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.pg_ts_cfgmap
    ADD CONSTRAINT pg_ts_cfgmap_pkey PRIMARY KEY (ts_name, tok_alias);


--
-- Name: pg_ts_dict_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.pg_ts_dict
    ADD CONSTRAINT pg_ts_dict_pkey PRIMARY KEY (dict_name);


--
-- Name: pg_ts_parser_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.pg_ts_parser
    ADD CONSTRAINT pg_ts_parser_pkey PRIMARY KEY (prs_name);


--
-- Name: postings_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.postings
    ADD CONSTRAINT postings_pkey PRIMARY KEY (id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT recommendations_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: spam_warnings_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.spam_warnings
    ADD CONSTRAINT spam_warnings_pkey PRIMARY KEY (id);


--
-- Name: tagged_models_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.tagged_nodes
    ADD CONSTRAINT tagged_models_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: nlcommons; Tablespace:
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: index_attachments_on_node_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_attachments_on_node_id ON public.attachments USING btree (node_id);


--
-- Name: index_attachments_on_person_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_attachments_on_person_id ON public.attachments USING btree (person_id);


--
-- Name: index_attachments_on_type; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_attachments_on_type ON public.attachments USING btree (content_type);


--
-- Name: index_email_recommendations_on_node_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_email_recommendations_on_node_id ON public.email_recommendations USING btree (node_id);


--
-- Name: index_email_recommendations_on_person_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_email_recommendations_on_person_id ON public.email_recommendations USING btree (person_id);


--
-- Name: index_ip_locations_on_ip_address; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE UNIQUE INDEX index_ip_locations_on_ip_address ON public.ip_locations USING btree (ip_address);


--
-- Name: index_logged_actions_on_action; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_logged_actions_on_action ON public.logged_actions USING btree (action);


--
-- Name: index_logged_actions_on_controller; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_logged_actions_on_controller ON public.logged_actions USING btree (controller);


--
-- Name: index_logged_actions_on_ip_address; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_logged_actions_on_ip_address ON public.logged_actions USING btree (ip_address);


--
-- Name: index_logged_actions_on_is_searchbot; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_logged_actions_on_is_searchbot ON public.logged_actions USING btree (is_searchbot);


--
-- Name: index_logged_actions_on_node_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_logged_actions_on_node_id ON public.logged_actions USING btree (node_id);


--
-- Name: index_logged_actions_on_person_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_logged_actions_on_person_id ON public.logged_actions USING btree (person_id);


--
-- Name: index_logged_actions_on_referrer; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_logged_actions_on_referrer ON public.logged_actions USING btree (referrer);


--
-- Name: index_logged_actions_on_url; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_logged_actions_on_url ON public.logged_actions USING btree (url);


--
-- Name: index_memberships_on_group_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_memberships_on_group_id ON public.memberships USING btree (group_id);


--
-- Name: index_memberships_on_person_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_memberships_on_person_id ON public.memberships USING btree (person_id);


--
-- Name: index_memberships_on_person_id_and_group_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE UNIQUE INDEX index_memberships_on_person_id_and_group_id ON public.memberships USING btree (person_id, group_id);


--
-- Name: index_news_items_on_created_at; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_news_items_on_created_at ON public.news_items USING btree (created_at);


--
-- Name: index_news_items_on_person_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_news_items_on_person_id ON public.news_items USING btree (person_id);


--
-- Name: index_news_items_on_title; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_news_items_on_title ON public.news_items USING btree (title);


--
-- Name: index_node_projects_on_node_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_node_projects_on_node_id ON public.node_projects USING btree (node_id);


--
-- Name: index_node_projects_on_project_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_node_projects_on_project_id ON public.node_projects USING btree (project_id);


--
-- Name: index_nodes_on_changeability_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_nodes_on_changeability_id ON public.nodes USING btree (changeability_id);


--
-- Name: index_nodes_on_created_at; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_nodes_on_created_at ON public.nodes USING btree (created_at);


--
-- Name: index_nodes_on_group_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_nodes_on_group_id ON public.nodes USING btree (group_id);


--
-- Name: index_nodes_on_name; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_nodes_on_name ON public.nodes USING btree (name);


--
-- Name: index_nodes_on_parent_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_nodes_on_parent_id ON public.nodes USING btree (parent_id);


--
-- Name: index_nodes_on_visibility_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_nodes_on_visibility_id ON public.nodes USING btree (visibility_id);


--
-- Name: index_nodes_on_wants_help; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_nodes_on_wants_help ON public.nodes USING btree (wants_help);


--
-- Name: index_non_member_collaborations_on_collaborator_type_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_non_member_collaborations_on_collaborator_type_id ON public.non_member_collaborations USING btree (collaborator_type_id);


--
-- Name: index_non_member_collaborations_on_node_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_non_member_collaborations_on_node_id ON public.non_member_collaborations USING btree (node_id);


--
-- Name: index_non_member_collaborations_on_non_member_collaborator_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_non_member_collaborations_on_non_member_collaborator_id ON public.non_member_collaborations USING btree (non_member_collaborator_id);


--
-- Name: index_non_member_collaborators_on_email; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE UNIQUE INDEX index_non_member_collaborators_on_email ON public.non_member_collaborators USING btree (email);


--
-- Name: index_non_member_collaborators_on_name; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_non_member_collaborators_on_name ON public.non_member_collaborators USING btree (name);


--
-- Name: index_people_on_email_address; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_people_on_email_address ON public.people USING btree (email_address);


--
-- Name: index_people_on_first_name; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_people_on_first_name ON public.people USING btree (first_name);


--
-- Name: index_people_on_last_name; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_people_on_last_name ON public.people USING btree (last_name);


--
-- Name: index_people_on_registration_consent; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_people_on_registration_consent ON public.people USING btree (registration_consent);


--
-- Name: index_permission_settings_on_name; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_permission_settings_on_name ON public.permission_settings USING btree (name);


--
-- Name: index_postings_on_body; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_postings_on_body ON public.postings USING btree (body);


--
-- Name: index_postings_on_created_at; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_postings_on_created_at ON public.postings USING btree (created_at);


--
-- Name: index_postings_on_nlmodel_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_postings_on_nlmodel_id ON public.postings USING btree (node_id);


--
-- Name: index_postings_on_parent_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_postings_on_parent_id ON public.postings USING btree (parent_id);


--
-- Name: index_postings_on_person_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_postings_on_person_id ON public.postings USING btree (person_id);


--
-- Name: index_postings_on_title; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_postings_on_title ON public.postings USING btree (title);


--
-- Name: index_postings_on_updated_at; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_postings_on_updated_at ON public.postings USING btree (updated_at);


--
-- Name: index_projects_on_changeability_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_projects_on_changeability_id ON public.projects USING btree (changeability_id);


--
-- Name: index_projects_on_group_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_projects_on_group_id ON public.projects USING btree (group_id);


--
-- Name: index_projects_on_person_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_projects_on_person_id ON public.projects USING btree (person_id);


--
-- Name: index_projects_on_visibility_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_projects_on_visibility_id ON public.projects USING btree (visibility_id);


--
-- Name: index_recommendations_on_node_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_recommendations_on_node_id ON public.recommendations USING btree (node_id);


--
-- Name: index_recommendations_on_person_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_recommendations_on_person_id ON public.recommendations USING btree (person_id);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_sessions_on_session_id ON public.sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_sessions_on_updated_at ON public.sessions USING btree (updated_at);


--
-- Name: index_spam_warnings_on_node_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_spam_warnings_on_node_id ON public.spam_warnings USING btree (node_id);


--
-- Name: index_spam_warnings_on_person_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_spam_warnings_on_person_id ON public.spam_warnings USING btree (person_id);


--
-- Name: index_tagged_nodes_on_created_at; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_tagged_nodes_on_created_at ON public.tagged_nodes USING btree (created_at);


--
-- Name: index_tagged_nodes_on_node_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_tagged_nodes_on_node_id ON public.tagged_nodes USING btree (node_id);


--
-- Name: index_tagged_nodes_on_person_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_tagged_nodes_on_person_id ON public.tagged_nodes USING btree (person_id);


--
-- Name: index_tagged_nodes_on_tag_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_tagged_nodes_on_tag_id ON public.tagged_nodes USING btree (tag_id);


--
-- Name: index_tagged_nodes_on_updated_at; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_tagged_nodes_on_updated_at ON public.tagged_nodes USING btree (updated_at);


--
-- Name: index_tags_on_created_at; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_tags_on_created_at ON public.tags USING btree (created_at);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_tags_on_name ON public.tags USING btree (name);


--
-- Name: index_tags_on_person_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_tags_on_person_id ON public.tags USING btree (person_id);


--
-- Name: index_tags_on_updated_at; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_tags_on_updated_at ON public.tags USING btree (updated_at);


--
-- Name: index_versions_on_node_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_versions_on_node_id ON public.versions USING btree (node_id);


--
-- Name: index_versions_on_person_id; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX index_versions_on_person_id ON public.versions USING btree (person_id);


--
-- Name: logged_actions_logged_at; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX logged_actions_logged_at ON public.logged_actions USING btree (logged_at);


--
-- Name: logged_actions_not_null_node_id_idx; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX logged_actions_not_null_node_id_idx ON public.logged_actions USING btree (node_id) WHERE (node_id IS NOT NULL);


--
-- Name: logged_actions_null_node_id_idx; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX logged_actions_null_node_id_idx ON public.logged_actions USING btree (node_id) WHERE (node_id IS NULL);


--
-- Name: model_downloads_ip_address_idx; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX model_downloads_ip_address_idx ON public.model_downloads USING btree (ip_address);


--
-- Name: model_downloads_logged_at_idx; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX model_downloads_logged_at_idx ON public.model_downloads USING btree (logged_at);


--
-- Name: model_downloads_node_id_idx; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX model_downloads_node_id_idx ON public.model_downloads USING btree (node_id);


--
-- Name: model_downloads_person_id_idx; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX model_downloads_person_id_idx ON public.model_downloads USING btree (person_id);


--
-- Name: model_runs_ip_address_idx; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX model_runs_ip_address_idx ON public.model_runs USING btree (ip_address);


--
-- Name: model_runs_logged_at_idx; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX model_runs_logged_at_idx ON public.model_runs USING btree (logged_at);


--
-- Name: model_runs_node_id_idx; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX model_runs_node_id_idx ON public.model_runs USING btree (node_id);


--
-- Name: model_runs_person_id_idx; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX model_runs_person_id_idx ON public.model_runs USING btree (person_id);


--
-- Name: model_views_ip_address_idx; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX model_views_ip_address_idx ON public.model_views USING btree (ip_address);


--
-- Name: model_views_logged_at_idx; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX model_views_logged_at_idx ON public.model_views USING btree (logged_at);


--
-- Name: model_views_node_id_idx; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX model_views_node_id_idx ON public.model_views USING btree (node_id);


--
-- Name: model_views_person_id_idx; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX model_views_person_id_idx ON public.model_views USING btree (person_id);


--
-- Name: new_model_view_counts_count_idx1; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX new_model_view_counts_count_idx1 ON public.model_view_counts USING btree (count);


--
-- Name: new_model_view_counts_node_id_idx1; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX new_model_view_counts_node_id_idx1 ON public.model_view_counts USING btree (node_id);


--
-- Name: node_id_not_null; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX node_id_not_null ON public.logged_actions USING btree (node_id) WHERE (node_id IS NOT NULL);


--
-- Name: tagged_nodes_node_id_tag_id_person_id_idx; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE UNIQUE INDEX tagged_nodes_node_id_tag_id_person_id_idx ON public.tagged_nodes USING btree (node_id, tag_id, person_id);


--
-- Name: tags_lower_idx; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE UNIQUE INDEX tags_lower_idx ON public.tags USING btree (lower((name)::text));


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: version_contents_idx; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX version_contents_idx ON public.versions USING gin (to_tsvector('english'::regconfig, contents)) WITH (fastupdate=off);


--
-- Name: version_description_idx; Type: INDEX; Schema: public; Owner: nlcommons; Tablespace:
--

CREATE INDEX version_description_idx ON public.versions USING gin (to_tsvector('english'::regconfig, description));


--
-- Name: permissions_changed_log_view _RETURN; Type: RULE; Schema: public; Owner: nlcommons
--

CREATE RULE "_RETURN" AS
    ON SELECT TO public.permissions_changed_log_view DO INSTEAD  SELECT count(*) AS count,
    "substring"(logged_actions.params, 'id"?:\s*"(\d+)'::text) AS id
   FROM public.logged_actions
  WHERE ((logged_actions.action = 'set_permissions'::text) AND (logged_actions.person_id <> 1))
  GROUP BY logged_actions.id
  ORDER BY "substring"(logged_actions.params, 'id"?:\s*"(\d+)'::text) DESC;


--
-- Name: node_changeability_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.nodes
    ADD CONSTRAINT node_changeability_fkey FOREIGN KEY (changeability_id) REFERENCES public.permission_settings(id);


--
-- Name: node_parent_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.nodes
    ADD CONSTRAINT node_parent_fkey FOREIGN KEY (parent_id) REFERENCES public.nodes(id);


--
-- Name: node_visibility_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.nodes
    ADD CONSTRAINT node_visibility_fkey FOREIGN KEY (visibility_id) REFERENCES public.permission_settings(id);


--
-- Name: posting_node_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.postings
    ADD CONSTRAINT posting_node_fkey FOREIGN KEY (node_id) REFERENCES public.nodes(id);


--
-- Name: posting_parent_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.postings
    ADD CONSTRAINT posting_parent_fkey FOREIGN KEY (parent_id) REFERENCES public.nodes(id);


--
-- Name: posting_versions_person_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.postings
    ADD CONSTRAINT posting_versions_person_fkey FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: tag_creator_person_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tag_creator_person_fkey FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: tag_node_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.tagged_nodes
    ADD CONSTRAINT tag_node_fkey FOREIGN KEY (node_id) REFERENCES public.nodes(id);


--
-- Name: tag_person_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.tagged_nodes
    ADD CONSTRAINT tag_person_fkey FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: tag_tag_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nlcommons
--

ALTER TABLE ONLY public.tagged_nodes
    ADD CONSTRAINT tag_tag_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

