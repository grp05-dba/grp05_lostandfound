\pset pager off
\set VERBOSITY verbose
SELECT current_database(), session_user, current_user;
\echo D01: scoped ownership and maintenance
BEGIN;
CREATE TABLE public.a4_dba_probe (id SERIAL PRIMARY KEY, note TEXT);
INSERT INTO public.a4_dba_probe(note) VALUES ('test');
UPDATE public.a4_dba_probe SET note='updated';
DELETE FROM public.a4_dba_probe;
ALTER TABLE public.a4_dba_probe ADD COLUMN extra TEXT;
GRANT SELECT ON public.a4_dba_probe TO grp03_ojt_readonly_grp;
REVOKE SELECT ON public.a4_dba_probe FROM grp03_ojt_readonly_grp;
ROLLBACK;
SELECT to_regclass('public.a4_dba_probe') IS NULL AS probe_removed;
\echo D02: database admin has access to restricted operational columns
SELECT password_hash FROM users LIMIT 0;
SELECT details FROM audit_log LIMIT 0;
\echo D03: no cluster administration
CREATE DATABASE grp03_a4_forbidden;
CREATE ROLE grp03_a4_forbidden NOLOGIN;
\echo D04: future objects under migration owner remain private
BEGIN;
SET ROLE grp03_ojt_admin_grp;
CREATE TABLE public.a4_future_probe(id SERIAL PRIMARY KEY);
CREATE FUNCTION public.a4_future_fn() RETURNS integer LANGUAGE sql AS 'SELECT 1';
SELECT has_table_privilege('grp03_ojt_app','public.a4_future_probe','SELECT') AS runtime_future_select,
has_sequence_privilege('grp03_ojt_app','public.a4_future_probe_id_seq','USAGE') AS runtime_future_sequence,
has_function_privilege('grp03_ojt_app','public.a4_future_fn()','EXECUTE') AS runtime_future_function;
ROLLBACK;
