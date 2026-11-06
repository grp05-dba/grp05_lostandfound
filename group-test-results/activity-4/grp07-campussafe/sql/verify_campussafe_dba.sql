\set ON_ERROR_STOP off
\set VERBOSITY verbose
-- Expected permission errors continue; evaluate individual results.
\echo identity-campussafe_dba expected=allowed
SELECT session_user,current_user,current_database();
ROLLBACK;

\echo read-campussafe_dba expected=allowed
SELECT (SELECT count(*) FROM public.role) AS role, (SELECT count(*) FROM public.app_user) AS app_user, (SELECT count(*) FROM public.hazard_category) AS hazard_category, (SELECT count(*) FROM public.campus_location) AS campus_location, (SELECT count(*) FROM public.hazard_report) AS hazard_report, (SELECT count(*) FROM public.assignment) AS assignment, (SELECT count(*) FROM public.report_status_history) AS report_status_history, (SELECT count(*) FROM public.maintenance_action) AS maintenance_action, (SELECT count(*) FROM public.attachment) AS attachment;
ROLLBACK;

\echo dba-maintenance expected=allowed
BEGIN;
SET ROLE campussafe_owner_grp;
INSERT INTO role(role_name) VALUES ('E4 DBA role') RETURNING role_id;
ALTER TABLE role ADD COLUMN e4_probe text;
CREATE TABLE public.e4_ddl_probe(id integer);
DROP TABLE public.e4_ddl_probe;
ROLLBACK;
SELECT to_regclass('public.e4_ddl_probe') IS NULL AS probe_removed;
SELECT count(*) AS leftover_roles FROM role WHERE role_name='E4 DBA role';
ROLLBACK;

\echo deny-createdb-campussafe_dba expected=denied
CREATE DATABASE campussafe_e4_forbidden;
ROLLBACK;

\echo deny-createrole-campussafe_dba expected=denied
CREATE ROLE campussafe_e4_forbidden NOLOGIN;
ROLLBACK;
