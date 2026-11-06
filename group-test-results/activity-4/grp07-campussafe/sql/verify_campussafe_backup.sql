\set ON_ERROR_STOP off
\set VERBOSITY verbose
-- Expected permission errors continue; evaluate individual results.
\echo identity-campussafe_backup expected=allowed
SELECT session_user,current_user,current_database();
ROLLBACK;

\echo read-campussafe_backup expected=allowed
SELECT (SELECT count(*) FROM public.role) AS role, (SELECT count(*) FROM public.app_user) AS app_user, (SELECT count(*) FROM public.hazard_category) AS hazard_category, (SELECT count(*) FROM public.campus_location) AS campus_location, (SELECT count(*) FROM public.hazard_report) AS hazard_report, (SELECT count(*) FROM public.assignment) AS assignment, (SELECT count(*) FROM public.report_status_history) AS report_status_history, (SELECT count(*) FROM public.maintenance_action) AS maintenance_action, (SELECT count(*) FROM public.attachment) AS attachment;
ROLLBACK;

\echo backup-hash-column-readable expected=allowed
SELECT password_hash IS NOT NULL AS hash_present FROM app_user LIMIT 1;
ROLLBACK;

\echo backup-sequence-state expected=allowed
SELECT last_value FROM role_role_id_seq;
ROLLBACK;

\echo campussafe_backup-deny-insert-role expected=denied
BEGIN;
INSERT INTO role DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-update-role expected=denied
BEGIN;
UPDATE role SET description=description WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-delete-role expected=denied
BEGIN;
DELETE FROM role WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-insert-app_user expected=denied
BEGIN;
INSERT INTO app_user DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-update-app_user expected=denied
BEGIN;
UPDATE app_user SET full_name=full_name WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-delete-app_user expected=denied
BEGIN;
DELETE FROM app_user WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-insert-hazard_category expected=denied
BEGIN;
INSERT INTO hazard_category DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-update-hazard_category expected=denied
BEGIN;
UPDATE hazard_category SET description=description WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-delete-hazard_category expected=denied
BEGIN;
DELETE FROM hazard_category WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-insert-campus_location expected=denied
BEGIN;
INSERT INTO campus_location DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-update-campus_location expected=denied
BEGIN;
UPDATE campus_location SET building=building WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-delete-campus_location expected=denied
BEGIN;
DELETE FROM campus_location WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-insert-hazard_report expected=denied
BEGIN;
INSERT INTO hazard_report DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-update-hazard_report expected=denied
BEGIN;
UPDATE hazard_report SET description=description WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-delete-hazard_report expected=denied
BEGIN;
DELETE FROM hazard_report WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-insert-assignment expected=denied
BEGIN;
INSERT INTO assignment DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-update-assignment expected=denied
BEGIN;
UPDATE assignment SET assignment_status=assignment_status WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-delete-assignment expected=denied
BEGIN;
DELETE FROM assignment WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-insert-report_status_history expected=denied
BEGIN;
INSERT INTO report_status_history DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-update-report_status_history expected=denied
BEGIN;
UPDATE report_status_history SET notes=notes WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-delete-report_status_history expected=denied
BEGIN;
DELETE FROM report_status_history WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-insert-maintenance_action expected=denied
BEGIN;
INSERT INTO maintenance_action DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-update-maintenance_action expected=denied
BEGIN;
UPDATE maintenance_action SET notes=notes WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-delete-maintenance_action expected=denied
BEGIN;
DELETE FROM maintenance_action WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-insert-attachment expected=denied
BEGIN;
INSERT INTO attachment DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-update-attachment expected=denied
BEGIN;
UPDATE attachment SET file_name=file_name WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-delete-attachment expected=denied
BEGIN;
DELETE FROM attachment WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-nextval expected=denied
SELECT nextval('hazard_report_report_id_seq');
ROLLBACK;

\echo campussafe_backup-deny-setval expected=denied
SELECT setval('hazard_report_report_id_seq',1);
ROLLBACK;

\echo campussafe_backup-deny-create expected=denied
BEGIN; CREATE TABLE public.e4_forbidden(id integer); ROLLBACK;
ROLLBACK;

\echo campussafe_backup-deny-owner expected=denied
SET ROLE campussafe_owner_grp;
ROLLBACK;

\echo deny-createdb-campussafe_backup expected=denied
CREATE DATABASE campussafe_e4_forbidden;
ROLLBACK;

\echo deny-createrole-campussafe_backup expected=denied
CREATE ROLE campussafe_e4_forbidden NOLOGIN;
ROLLBACK;
