\set ON_ERROR_STOP off
\set VERBOSITY verbose
-- Expected permission errors continue; evaluate individual results.
\echo identity-campussafe_report expected=allowed
SELECT session_user,current_user,current_database();
ROLLBACK;

\echo read-campussafe_report expected=allowed
SELECT (SELECT count(*) FROM role) AS role, (SELECT count(*) FROM hazard_category) AS hazard_category, (SELECT count(*) FROM campus_location) AS campus_location, (SELECT count(*) FROM hazard_report) AS hazard_report, (SELECT count(*) FROM assignment) AS assignment, (SELECT count(*) FROM report_status_history) AS report_status_history, (SELECT count(*) FROM maintenance_action) AS maintenance_action, (SELECT count(*) FROM attachment) AS attachment;
ROLLBACK;

\echo auditor-deny-users expected=denied
SELECT user_id FROM app_user LIMIT 0;
ROLLBACK;

\echo auditor-deny-hashes expected=denied
SELECT password_hash FROM app_user LIMIT 0;
ROLLBACK;

\echo campussafe_report-deny-insert-role expected=denied
BEGIN;
INSERT INTO role DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-update-role expected=denied
BEGIN;
UPDATE role SET description=description WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-delete-role expected=denied
BEGIN;
DELETE FROM role WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-insert-app_user expected=denied
BEGIN;
INSERT INTO app_user DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-update-app_user expected=denied
BEGIN;
UPDATE app_user SET full_name=full_name WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-delete-app_user expected=denied
BEGIN;
DELETE FROM app_user WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-insert-hazard_category expected=denied
BEGIN;
INSERT INTO hazard_category DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-update-hazard_category expected=denied
BEGIN;
UPDATE hazard_category SET description=description WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-delete-hazard_category expected=denied
BEGIN;
DELETE FROM hazard_category WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-insert-campus_location expected=denied
BEGIN;
INSERT INTO campus_location DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-update-campus_location expected=denied
BEGIN;
UPDATE campus_location SET building=building WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-delete-campus_location expected=denied
BEGIN;
DELETE FROM campus_location WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-insert-hazard_report expected=denied
BEGIN;
INSERT INTO hazard_report DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-update-hazard_report expected=denied
BEGIN;
UPDATE hazard_report SET description=description WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-delete-hazard_report expected=denied
BEGIN;
DELETE FROM hazard_report WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-insert-assignment expected=denied
BEGIN;
INSERT INTO assignment DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-update-assignment expected=denied
BEGIN;
UPDATE assignment SET assignment_status=assignment_status WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-delete-assignment expected=denied
BEGIN;
DELETE FROM assignment WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-insert-report_status_history expected=denied
BEGIN;
INSERT INTO report_status_history DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-update-report_status_history expected=denied
BEGIN;
UPDATE report_status_history SET notes=notes WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-delete-report_status_history expected=denied
BEGIN;
DELETE FROM report_status_history WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-insert-maintenance_action expected=denied
BEGIN;
INSERT INTO maintenance_action DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-update-maintenance_action expected=denied
BEGIN;
UPDATE maintenance_action SET notes=notes WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-delete-maintenance_action expected=denied
BEGIN;
DELETE FROM maintenance_action WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-insert-attachment expected=denied
BEGIN;
INSERT INTO attachment DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-update-attachment expected=denied
BEGIN;
UPDATE attachment SET file_name=file_name WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-delete-attachment expected=denied
BEGIN;
DELETE FROM attachment WHERE false;
ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-nextval expected=denied
SELECT nextval('hazard_report_report_id_seq');
ROLLBACK;

\echo campussafe_report-deny-setval expected=denied
SELECT setval('hazard_report_report_id_seq',1);
ROLLBACK;

\echo campussafe_report-deny-create expected=denied
BEGIN; CREATE TABLE public.e4_forbidden(id integer); ROLLBACK;
ROLLBACK;

\echo campussafe_report-deny-owner expected=denied
SET ROLE campussafe_owner_grp;
ROLLBACK;

\echo deny-createdb-campussafe_report expected=denied
CREATE DATABASE campussafe_e4_forbidden;
ROLLBACK;

\echo deny-createrole-campussafe_report expected=denied
CREATE ROLE campussafe_e4_forbidden NOLOGIN;
ROLLBACK;
