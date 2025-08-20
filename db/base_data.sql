SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Data for Name: permission_settings; Type: TABLE DATA; Schema: public; Owner: nlcommons
--

COPY public.permission_settings (id, name, created_at, updated_at, short_form) FROM stdin;
2	the author	2008-09-16 01:07:56.828182	2008-09-16 01:07:56.828182	u
3	group members	2008-09-16 01:07:56.830749	2008-09-16 01:07:56.830749	g
1	everyone	2008-09-16 01:07:56.740132	2008-09-16 01:07:56.740132	a
\.


--
-- Name: permission_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nlcommons
--

SELECT pg_catalog.setval('public.permission_settings_id_seq', 3, true);


--
-- PostgreSQL database dump complete
--
