--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


SET search_path = public, pg_catalog;

--
-- Name: statinfo; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE statinfo AS (
	word text,
	ndoc integer,
	nentry integer
);


--
-- Name: tokenout; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE tokenout AS (
	tokid integer,
	token text
);


--
-- Name: tokentype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE tokentype AS (
	tokid integer,
	alias text,
	descr text
);


--
-- Name: tsdebug; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE tsdebug AS (
	ts_name text,
	tok_type text,
	description text,
	token text,
	dict_name text[]
);


--
-- Name: _get_parser_from_curcfg(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION _get_parser_from_curcfg() RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ select prs_name from pg_ts_cfg where oid = show_curcfg() $$;


--
-- Name: ts_debug(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ts_debug(text) RETURNS SETOF tsdebug
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


--
-- Name: wow(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION wow(text) RETURNS text
    LANGUAGE sql
    AS $_$select $1 || ' copyright'; $_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: attachments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE attachments (
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


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE attachments_id_seq OWNED BY attachments.id;


--
-- Name: nodes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nodes (
    id integer NOT NULL,
    parent_id integer,
    name text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    visibility_id integer DEFAULT 1 NOT NULL,
    changeability_id integer DEFAULT 1 NOT NULL,
    group_id integer
);


--
-- Name: ccl_model_creations_per_month; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW ccl_model_creations_per_month AS
    SELECT to_char(nodes.created_at, 'YY MM'::text) AS yearmonth, count(*) AS count FROM nodes WHERE (nodes.group_id = 2) GROUP BY to_char(nodes.created_at, 'YY MM'::text) ORDER BY to_char(nodes.created_at, 'YY MM'::text);


--
-- Name: collaborations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE collaborations (
    id integer NOT NULL,
    person_id integer,
    node_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    collaborator_type_id integer
);


--
-- Name: collaborations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE collaborations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collaborations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE collaborations_id_seq OWNED BY collaborations.id;


--
-- Name: collaborator_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE collaborator_types (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: collaborator_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE collaborator_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collaborator_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE collaborator_types_id_seq OWNED BY collaborator_types.id;


--
-- Name: email_recommendations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE email_recommendations (
    id integer NOT NULL,
    person_id integer,
    recipient_email_address character varying(255),
    node_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: email_recommendations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE email_recommendations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_recommendations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE email_recommendations_id_seq OWNED BY email_recommendations.id;


--
-- Name: foobar; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE foobar (
    id integer NOT NULL,
    ip_address text,
    new_inet inet
);


--
-- Name: foobar_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE foobar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: foobar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE foobar_id_seq OWNED BY foobar.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groups (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE groups_id_seq OWNED BY groups.id;


--
-- Name: logged_actions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE logged_actions (
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


--
-- Name: logged_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE logged_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logged_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE logged_actions_id_seq OWNED BY logged_actions.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE memberships (
    id integer NOT NULL,
    person_id integer,
    group_id integer,
    is_administrator boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    status text DEFAULT 'pending'::text NOT NULL
);


--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE memberships_id_seq OWNED BY memberships.id;


--
-- Name: model_downloads; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE model_downloads (
    logged_at timestamp without time zone,
    ip_address text,
    node_id integer,
    person_id integer
);


--
-- Name: model_view_counts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE model_view_counts (
    count bigint,
    node_id integer
);


--
-- Name: model_views; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE model_views (
    logged_at timestamp without time zone,
    ip_address text,
    node_id integer,
    person_id integer
);


--
-- Name: news_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE news_items (
    id integer NOT NULL,
    title character varying(255),
    body text,
    person_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: news_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE news_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: news_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE news_items_id_seq OWNED BY news_items.id;


--
-- Name: node_projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE node_projects (
    id integer NOT NULL,
    project_id integer,
    node_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: node_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE node_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: node_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE node_projects_id_seq OWNED BY node_projects.id;


--
-- Name: nodes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nodes_id_seq OWNED BY nodes.id;


--
-- Name: non_ccl_model_creations_per_month; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW non_ccl_model_creations_per_month AS
    SELECT to_char(nodes.created_at, 'YY MM'::text) AS yearmonth, count(*) AS count FROM nodes WHERE (nodes.group_id <> 2) GROUP BY to_char(nodes.created_at, 'YY MM'::text) ORDER BY to_char(nodes.created_at, 'YY MM'::text);


--
-- Name: non_member_collaborations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE non_member_collaborations (
    id integer NOT NULL,
    non_member_collaborator_id integer,
    node_id integer,
    collaborator_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: non_member_collaborations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE non_member_collaborations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: non_member_collaborations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE non_member_collaborations_id_seq OWNED BY non_member_collaborations.id;


--
-- Name: non_member_collaborators; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE non_member_collaborators (
    id integer NOT NULL,
    email character varying(255),
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: non_member_collaborators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE non_member_collaborators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: non_member_collaborators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE non_member_collaborators_id_seq OWNED BY non_member_collaborators.id;


--
-- Name: people; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE people (
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


--
-- Name: people_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE people_id_seq OWNED BY people.id;


--
-- Name: permission_settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE permission_settings (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    short_form character varying(255)
);


--
-- Name: permission_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE permission_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permission_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE permission_settings_id_seq OWNED BY permission_settings.id;


SET default_with_oids = true;

--
-- Name: pg_ts_cfg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pg_ts_cfg (
    ts_name text NOT NULL,
    prs_name text NOT NULL,
    locale text
);


--
-- Name: pg_ts_cfgmap; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pg_ts_cfgmap (
    ts_name text NOT NULL,
    tok_alias text NOT NULL,
    dict_name text[]
);


--
-- Name: pg_ts_dict; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pg_ts_dict (
    dict_name text NOT NULL,
    dict_init regprocedure,
    dict_initoption text,
    dict_lexize regprocedure NOT NULL,
    dict_comment text
);


--
-- Name: pg_ts_parser; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pg_ts_parser (
    prs_name text NOT NULL,
    prs_start regprocedure NOT NULL,
    prs_nexttoken regprocedure NOT NULL,
    prs_end regprocedure NOT NULL,
    prs_headline regprocedure NOT NULL,
    prs_lextype regprocedure NOT NULL,
    prs_comment text
);


SET default_with_oids = false;

--
-- Name: postings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE postings (
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


--
-- Name: postings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE postings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: postings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE postings_id_seq OWNED BY postings.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE projects (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    person_id integer,
    group_id integer,
    visibility_id integer,
    changeability_id integer
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: recommendations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE recommendations (
    id integer NOT NULL,
    node_id integer,
    person_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: recommendations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE recommendations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recommendations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE recommendations_id_seq OWNED BY recommendations.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sessions (
    id integer NOT NULL,
    session_id text NOT NULL,
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;


--
-- Name: spam_warnings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE spam_warnings (
    id integer NOT NULL,
    person_id integer,
    node_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: spam_warnings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE spam_warnings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: spam_warnings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE spam_warnings_id_seq OWNED BY spam_warnings.id;


--
-- Name: tagged_nodes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tagged_nodes (
    id integer NOT NULL,
    node_id integer,
    tag_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    person_id integer,
    comment text
);


--
-- Name: tagged_models_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tagged_models_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tagged_models_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tagged_models_id_seq OWNED BY tagged_nodes.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255),
    person_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: test_tsquery; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE test_tsquery (
    txtkeyword text,
    txtsample text
);


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE versions (
    id integer NOT NULL,
    node_id integer NOT NULL,
    person_id integer NOT NULL,
    description text NOT NULL,
    contents text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY attachments ALTER COLUMN id SET DEFAULT nextval('attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY collaborations ALTER COLUMN id SET DEFAULT nextval('collaborations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY collaborator_types ALTER COLUMN id SET DEFAULT nextval('collaborator_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_recommendations ALTER COLUMN id SET DEFAULT nextval('email_recommendations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY foobar ALTER COLUMN id SET DEFAULT nextval('foobar_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY logged_actions ALTER COLUMN id SET DEFAULT nextval('logged_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY memberships ALTER COLUMN id SET DEFAULT nextval('memberships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY news_items ALTER COLUMN id SET DEFAULT nextval('news_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY node_projects ALTER COLUMN id SET DEFAULT nextval('node_projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nodes ALTER COLUMN id SET DEFAULT nextval('nodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY non_member_collaborations ALTER COLUMN id SET DEFAULT nextval('non_member_collaborations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY non_member_collaborators ALTER COLUMN id SET DEFAULT nextval('non_member_collaborators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY people ALTER COLUMN id SET DEFAULT nextval('people_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY permission_settings ALTER COLUMN id SET DEFAULT nextval('permission_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY postings ALTER COLUMN id SET DEFAULT nextval('postings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY recommendations ALTER COLUMN id SET DEFAULT nextval('recommendations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions ALTER COLUMN id SET DEFAULT nextval('sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY spam_warnings ALTER COLUMN id SET DEFAULT nextval('spam_warnings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tagged_nodes ALTER COLUMN id SET DEFAULT nextval('tagged_models_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: collaborations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collaborations
    ADD CONSTRAINT collaborations_pkey PRIMARY KEY (id);


--
-- Name: collaborator_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collaborator_types
    ADD CONSTRAINT collaborator_types_pkey PRIMARY KEY (id);


--
-- Name: email_recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY email_recommendations
    ADD CONSTRAINT email_recommendations_pkey PRIMARY KEY (id);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: logged_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY logged_actions
    ADD CONSTRAINT logged_actions_pkey PRIMARY KEY (id);


--
-- Name: memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: news_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY news_items
    ADD CONSTRAINT news_items_pkey PRIMARY KEY (id);


--
-- Name: node_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY node_projects
    ADD CONSTRAINT node_projects_pkey PRIMARY KEY (id);


--
-- Name: nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nodes
    ADD CONSTRAINT nodes_pkey PRIMARY KEY (id);


--
-- Name: non_member_collaborations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY non_member_collaborations
    ADD CONSTRAINT non_member_collaborations_pkey PRIMARY KEY (id);


--
-- Name: non_member_collaborators_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY non_member_collaborators
    ADD CONSTRAINT non_member_collaborators_pkey PRIMARY KEY (id);


--
-- Name: people_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: permission_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY permission_settings
    ADD CONSTRAINT permission_settings_pkey PRIMARY KEY (id);


--
-- Name: pg_ts_cfg_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pg_ts_cfg
    ADD CONSTRAINT pg_ts_cfg_pkey PRIMARY KEY (ts_name);


--
-- Name: pg_ts_cfgmap_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pg_ts_cfgmap
    ADD CONSTRAINT pg_ts_cfgmap_pkey PRIMARY KEY (ts_name, tok_alias);


--
-- Name: pg_ts_dict_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pg_ts_dict
    ADD CONSTRAINT pg_ts_dict_pkey PRIMARY KEY (dict_name);


--
-- Name: pg_ts_parser_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pg_ts_parser
    ADD CONSTRAINT pg_ts_parser_pkey PRIMARY KEY (prs_name);


--
-- Name: postings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY postings
    ADD CONSTRAINT postings_pkey PRIMARY KEY (id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY recommendations
    ADD CONSTRAINT recommendations_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: spam_warnings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY spam_warnings
    ADD CONSTRAINT spam_warnings_pkey PRIMARY KEY (id);


--
-- Name: tagged_models_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tagged_nodes
    ADD CONSTRAINT tagged_models_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: index_attachments_on_node_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attachments_on_node_id ON attachments USING btree (node_id);


--
-- Name: index_attachments_on_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attachments_on_person_id ON attachments USING btree (person_id);


--
-- Name: index_attachments_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attachments_on_type ON attachments USING btree (content_type);


--
-- Name: index_email_recommendations_on_node_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_email_recommendations_on_node_id ON email_recommendations USING btree (node_id);


--
-- Name: index_email_recommendations_on_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_email_recommendations_on_person_id ON email_recommendations USING btree (person_id);


--
-- Name: index_logged_actions_on_action; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_logged_actions_on_action ON logged_actions USING btree (action);


--
-- Name: index_logged_actions_on_controller; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_logged_actions_on_controller ON logged_actions USING btree (controller);


--
-- Name: index_logged_actions_on_ip_address; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_logged_actions_on_ip_address ON logged_actions USING btree (ip_address);


--
-- Name: index_logged_actions_on_is_searchbot; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_logged_actions_on_is_searchbot ON logged_actions USING btree (is_searchbot);


--
-- Name: index_logged_actions_on_node_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_logged_actions_on_node_id ON logged_actions USING btree (node_id);


--
-- Name: index_logged_actions_on_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_logged_actions_on_person_id ON logged_actions USING btree (person_id);


--
-- Name: index_logged_actions_on_referrer; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_logged_actions_on_referrer ON logged_actions USING btree (referrer);


--
-- Name: index_logged_actions_on_url; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_logged_actions_on_url ON logged_actions USING btree (url);


--
-- Name: index_memberships_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_memberships_on_group_id ON memberships USING btree (group_id);


--
-- Name: index_memberships_on_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_memberships_on_person_id ON memberships USING btree (person_id);


--
-- Name: index_memberships_on_person_id_and_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_memberships_on_person_id_and_group_id ON memberships USING btree (person_id, group_id);


--
-- Name: index_news_items_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_news_items_on_created_at ON news_items USING btree (created_at);


--
-- Name: index_news_items_on_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_news_items_on_person_id ON news_items USING btree (person_id);


--
-- Name: index_news_items_on_title; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_news_items_on_title ON news_items USING btree (title);


--
-- Name: index_node_projects_on_node_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_node_projects_on_node_id ON node_projects USING btree (node_id);


--
-- Name: index_node_projects_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_node_projects_on_project_id ON node_projects USING btree (project_id);


--
-- Name: index_nodes_on_changeability_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nodes_on_changeability_id ON nodes USING btree (changeability_id);


--
-- Name: index_nodes_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nodes_on_created_at ON nodes USING btree (created_at);


--
-- Name: index_nodes_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nodes_on_group_id ON nodes USING btree (group_id);


--
-- Name: index_nodes_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nodes_on_name ON nodes USING btree (name);


--
-- Name: index_nodes_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nodes_on_parent_id ON nodes USING btree (parent_id);


--
-- Name: index_nodes_on_visibility_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nodes_on_visibility_id ON nodes USING btree (visibility_id);


--
-- Name: index_non_member_collaborations_on_collaborator_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_non_member_collaborations_on_collaborator_type_id ON non_member_collaborations USING btree (collaborator_type_id);


--
-- Name: index_non_member_collaborations_on_node_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_non_member_collaborations_on_node_id ON non_member_collaborations USING btree (node_id);


--
-- Name: index_non_member_collaborations_on_non_member_collaborator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_non_member_collaborations_on_non_member_collaborator_id ON non_member_collaborations USING btree (non_member_collaborator_id);


--
-- Name: index_non_member_collaborators_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_non_member_collaborators_on_email ON non_member_collaborators USING btree (email);


--
-- Name: index_non_member_collaborators_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_non_member_collaborators_on_name ON non_member_collaborators USING btree (name);


--
-- Name: index_people_on_email_address; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_email_address ON people USING btree (email_address);


--
-- Name: index_people_on_first_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_first_name ON people USING btree (first_name);


--
-- Name: index_people_on_last_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_last_name ON people USING btree (last_name);


--
-- Name: index_people_on_registration_consent; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_registration_consent ON people USING btree (registration_consent);


--
-- Name: index_permission_settings_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_permission_settings_on_name ON permission_settings USING btree (name);


--
-- Name: index_postings_on_body; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_postings_on_body ON postings USING btree (body);


--
-- Name: index_postings_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_postings_on_created_at ON postings USING btree (created_at);


--
-- Name: index_postings_on_nlmodel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_postings_on_nlmodel_id ON postings USING btree (node_id);


--
-- Name: index_postings_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_postings_on_parent_id ON postings USING btree (parent_id);


--
-- Name: index_postings_on_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_postings_on_person_id ON postings USING btree (person_id);


--
-- Name: index_postings_on_title; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_postings_on_title ON postings USING btree (title);


--
-- Name: index_postings_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_postings_on_updated_at ON postings USING btree (updated_at);


--
-- Name: index_projects_on_changeability_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_changeability_id ON projects USING btree (changeability_id);


--
-- Name: index_projects_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_group_id ON projects USING btree (group_id);


--
-- Name: index_projects_on_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_person_id ON projects USING btree (person_id);


--
-- Name: index_projects_on_visibility_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_visibility_id ON projects USING btree (visibility_id);


--
-- Name: index_recommendations_on_node_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_recommendations_on_node_id ON recommendations USING btree (node_id);


--
-- Name: index_recommendations_on_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_recommendations_on_person_id ON recommendations USING btree (person_id);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sessions_on_session_id ON sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sessions_on_updated_at ON sessions USING btree (updated_at);


--
-- Name: index_spam_warnings_on_node_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_spam_warnings_on_node_id ON spam_warnings USING btree (node_id);


--
-- Name: index_spam_warnings_on_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_spam_warnings_on_person_id ON spam_warnings USING btree (person_id);


--
-- Name: index_tagged_nodes_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tagged_nodes_on_created_at ON tagged_nodes USING btree (created_at);


--
-- Name: index_tagged_nodes_on_node_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tagged_nodes_on_node_id ON tagged_nodes USING btree (node_id);


--
-- Name: index_tagged_nodes_on_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tagged_nodes_on_person_id ON tagged_nodes USING btree (person_id);


--
-- Name: index_tagged_nodes_on_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tagged_nodes_on_tag_id ON tagged_nodes USING btree (tag_id);


--
-- Name: index_tagged_nodes_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tagged_nodes_on_updated_at ON tagged_nodes USING btree (updated_at);


--
-- Name: index_tags_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_on_created_at ON tags USING btree (created_at);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_tags_on_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_on_person_id ON tags USING btree (person_id);


--
-- Name: index_tags_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_on_updated_at ON tags USING btree (updated_at);


--
-- Name: index_versions_on_node_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_versions_on_node_id ON versions USING btree (node_id);


--
-- Name: index_versions_on_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_versions_on_person_id ON versions USING btree (person_id);


--
-- Name: logged_actions_logged_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX logged_actions_logged_at ON logged_actions USING btree (logged_at);


--
-- Name: logged_actions_not_null_node_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX logged_actions_not_null_node_id_idx ON logged_actions USING btree (node_id) WHERE (node_id IS NOT NULL);


--
-- Name: logged_actions_null_node_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX logged_actions_null_node_id_idx ON logged_actions USING btree (node_id) WHERE (node_id IS NULL);


--
-- Name: model_downloads_ip_address_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX model_downloads_ip_address_idx ON model_downloads USING btree (ip_address);


--
-- Name: model_downloads_logged_at_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX model_downloads_logged_at_idx ON model_downloads USING btree (logged_at);


--
-- Name: model_downloads_node_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX model_downloads_node_id_idx ON model_downloads USING btree (node_id);


--
-- Name: model_downloads_person_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX model_downloads_person_id_idx ON model_downloads USING btree (person_id);


--
-- Name: model_views_ip_address_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX model_views_ip_address_idx ON model_views USING btree (ip_address);


--
-- Name: model_views_logged_at_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX model_views_logged_at_idx ON model_views USING btree (logged_at);


--
-- Name: model_views_node_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX model_views_node_id_idx ON model_views USING btree (node_id);


--
-- Name: model_views_person_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX model_views_person_id_idx ON model_views USING btree (person_id);


--
-- Name: new_model_view_counts_count_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX new_model_view_counts_count_idx1 ON model_view_counts USING btree (count);


--
-- Name: new_model_view_counts_node_id_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX new_model_view_counts_node_id_idx1 ON model_view_counts USING btree (node_id);


--
-- Name: node_id_not_null; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX node_id_not_null ON logged_actions USING btree (node_id) WHERE (node_id IS NOT NULL);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: versions_to_tsvector_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX versions_to_tsvector_idx ON versions USING gin (to_tsvector('english'::regconfig, description));


--
-- Name: versions_to_tsvector_idx1; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX versions_to_tsvector_idx1 ON versions USING gin (to_tsvector('english'::regconfig, contents));


--
-- Name: node_changeability_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nodes
    ADD CONSTRAINT node_changeability_fkey FOREIGN KEY (changeability_id) REFERENCES permission_settings(id);


--
-- Name: node_parent_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nodes
    ADD CONSTRAINT node_parent_fkey FOREIGN KEY (parent_id) REFERENCES nodes(id);


--
-- Name: node_visibility_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nodes
    ADD CONSTRAINT node_visibility_fkey FOREIGN KEY (visibility_id) REFERENCES permission_settings(id);


--
-- Name: posting_node_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY postings
    ADD CONSTRAINT posting_node_fkey FOREIGN KEY (node_id) REFERENCES nodes(id);


--
-- Name: posting_parent_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY postings
    ADD CONSTRAINT posting_parent_fkey FOREIGN KEY (parent_id) REFERENCES nodes(id);


--
-- Name: posting_versions_person_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY postings
    ADD CONSTRAINT posting_versions_person_fkey FOREIGN KEY (person_id) REFERENCES people(id);


--
-- Name: tag_creator_person_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tag_creator_person_fkey FOREIGN KEY (person_id) REFERENCES people(id);


--
-- Name: tag_node_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tagged_nodes
    ADD CONSTRAINT tag_node_fkey FOREIGN KEY (node_id) REFERENCES nodes(id);


--
-- Name: tag_person_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tagged_nodes
    ADD CONSTRAINT tag_person_fkey FOREIGN KEY (person_id) REFERENCES people(id);


--
-- Name: tag_tag_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tagged_nodes
    ADD CONSTRAINT tag_tag_fkey FOREIGN KEY (tag_id) REFERENCES tags(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('20080830231357');

INSERT INTO schema_migrations (version) VALUES ('20080830235312');

INSERT INTO schema_migrations (version) VALUES ('20080831000255');

INSERT INTO schema_migrations (version) VALUES ('20080831002250');

INSERT INTO schema_migrations (version) VALUES ('20080831005900');

INSERT INTO schema_migrations (version) VALUES ('20080831014318');

INSERT INTO schema_migrations (version) VALUES ('20080831080849');

INSERT INTO schema_migrations (version) VALUES ('20080831083552');

INSERT INTO schema_migrations (version) VALUES ('20080831124531');

INSERT INTO schema_migrations (version) VALUES ('20080831124729');

INSERT INTO schema_migrations (version) VALUES ('20080910213406');

INSERT INTO schema_migrations (version) VALUES ('20080912111556');

INSERT INTO schema_migrations (version) VALUES ('20080914064532');

INSERT INTO schema_migrations (version) VALUES ('20080915081706');

INSERT INTO schema_migrations (version) VALUES ('20080915084421');

INSERT INTO schema_migrations (version) VALUES ('20081006093559');

INSERT INTO schema_migrations (version) VALUES ('20081006093638');

INSERT INTO schema_migrations (version) VALUES ('20081006103922');

INSERT INTO schema_migrations (version) VALUES ('20081006141507');

INSERT INTO schema_migrations (version) VALUES ('20081006152938');

INSERT INTO schema_migrations (version) VALUES ('20081006153420');

INSERT INTO schema_migrations (version) VALUES ('20081006154251');

INSERT INTO schema_migrations (version) VALUES ('20081013052347');

INSERT INTO schema_migrations (version) VALUES ('20081030135004');

INSERT INTO schema_migrations (version) VALUES ('20081102075512');

INSERT INTO schema_migrations (version) VALUES ('20081106131322');

INSERT INTO schema_migrations (version) VALUES ('20081128000507');

INSERT INTO schema_migrations (version) VALUES ('20081130071736');

INSERT INTO schema_migrations (version) VALUES ('20081212095805');

INSERT INTO schema_migrations (version) VALUES ('20081212123315');

INSERT INTO schema_migrations (version) VALUES ('20081221071249');

INSERT INTO schema_migrations (version) VALUES ('20090219112647');

INSERT INTO schema_migrations (version) VALUES ('20090219135245');

INSERT INTO schema_migrations (version) VALUES ('20090222003149');

INSERT INTO schema_migrations (version) VALUES ('20090222003303');

INSERT INTO schema_migrations (version) VALUES ('20090419171536');

INSERT INTO schema_migrations (version) VALUES ('20090421095910');

INSERT INTO schema_migrations (version) VALUES ('20090426153124');

INSERT INTO schema_migrations (version) VALUES ('20090429103554');

INSERT INTO schema_migrations (version) VALUES ('20090430091507');

INSERT INTO schema_migrations (version) VALUES ('20090525144838');

INSERT INTO schema_migrations (version) VALUES ('20090614172259');

INSERT INTO schema_migrations (version) VALUES ('20100222140321');

INSERT INTO schema_migrations (version) VALUES ('20100222143655');

INSERT INTO schema_migrations (version) VALUES ('20100613083851');

INSERT INTO schema_migrations (version) VALUES ('20100614153954');

INSERT INTO schema_migrations (version) VALUES ('20100621152433');

INSERT INTO schema_migrations (version) VALUES ('20110204050318');

INSERT INTO schema_migrations (version) VALUES ('20110207102309');

INSERT INTO schema_migrations (version) VALUES ('20110408060635');

INSERT INTO schema_migrations (version) VALUES ('20110422104454');

INSERT INTO schema_migrations (version) VALUES ('20120130001501');

INSERT INTO schema_migrations (version) VALUES ('20130110113739');

INSERT INTO schema_migrations (version) VALUES ('20130315142615');

INSERT INTO schema_migrations (version) VALUES ('20130315142822');

INSERT INTO schema_migrations (version) VALUES ('20130321065519');

INSERT INTO schema_migrations (version) VALUES ('20130327224511');

INSERT INTO schema_migrations (version) VALUES ('20130327224552');

INSERT INTO schema_migrations (version) VALUES ('20130331140537');

INSERT INTO schema_migrations (version) VALUES ('20130406222718');

INSERT INTO schema_migrations (version) VALUES ('20130406224201');

INSERT INTO schema_migrations (version) VALUES ('20130406231216');

INSERT INTO schema_migrations (version) VALUES ('20130407101541');

INSERT INTO schema_migrations (version) VALUES ('20130407102046');

INSERT INTO schema_migrations (version) VALUES ('20130412084458');

INSERT INTO schema_migrations (version) VALUES ('20130427214653');

INSERT INTO schema_migrations (version) VALUES ('20130519153050');

INSERT INTO schema_migrations (version) VALUES ('20130708125819');

INSERT INTO schema_migrations (version) VALUES ('20130708125917');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('23');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('25');

INSERT INTO schema_migrations (version) VALUES ('26');

INSERT INTO schema_migrations (version) VALUES ('27');

INSERT INTO schema_migrations (version) VALUES ('28');

INSERT INTO schema_migrations (version) VALUES ('29');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('9');