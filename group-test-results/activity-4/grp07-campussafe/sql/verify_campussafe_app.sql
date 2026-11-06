\set ON_ERROR_STOP off
\set VERBOSITY verbose
-- Expected permission errors continue; evaluate individual results.
\echo identity-campussafe_app expected=allowed
SELECT session_user,current_user,current_database();
ROLLBACK;

\echo read-campussafe_app expected=allowed
SELECT (SELECT count(*) FROM public.role) AS role, (SELECT count(*) FROM public.app_user) AS app_user, (SELECT count(*) FROM public.hazard_category) AS hazard_category, (SELECT count(*) FROM public.campus_location) AS campus_location, (SELECT count(*) FROM public.hazard_report) AS hazard_report, (SELECT count(*) FROM public.assignment) AS assignment, (SELECT count(*) FROM public.report_status_history) AS report_status_history, (SELECT count(*) FROM public.maintenance_action) AS maintenance_action, (SELECT count(*) FROM public.attachment) AS attachment;
ROLLBACK;

\echo runtime-workflow expected=allowed
BEGIN;
INSERT INTO app_user(role_id,full_name,email,username,password_hash) VALUES (1,'E4 test user','e4-test@example.invalid','e4_test_user','[test-only]') RETURNING user_id \gset
INSERT INTO hazard_category(category_name) VALUES ('E4 test category') RETURNING category_id \gset
INSERT INTO campus_location(building,room_area) VALUES ('E4 test building','E4 test room') RETURNING location_id \gset
INSERT INTO hazard_report(reporter_user_id,location_id,category_id,description) VALUES (:user_id,:location_id,:category_id,'E4 transactional hazard probe') RETURNING report_id \gset
INSERT INTO report_status_history(report_id,changed_by_user_id,status) VALUES (:report_id,:user_id,'Submitted');
UPDATE app_user SET account_status='inactive' WHERE user_id=:user_id;
UPDATE hazard_category SET is_active=false WHERE category_id=:category_id;
UPDATE campus_location SET is_active=false WHERE location_id=:location_id;
UPDATE hazard_report SET status='Verified',priority='High',verified_by_user_id=1,verified_at=now() WHERE report_id=:report_id;
INSERT INTO assignment(report_id,maintenance_user_id,assigned_by_user_id) VALUES (:report_id,2,1) RETURNING assignment_id \gset
UPDATE assignment SET assignment_status='In Progress' WHERE assignment_id=:assignment_id;
INSERT INTO maintenance_action(report_id,maintenance_user_id,action_details) VALUES (:report_id,2,'E4 test action');
INSERT INTO attachment(report_id,uploaded_by_user_id,file_name,file_path_or_url) VALUES (:report_id,:user_id,'e4-test.png','uploads/e4-test.png') RETURNING attachment_id \gset
DELETE FROM attachment WHERE attachment_id=:attachment_id;
SELECT h.status,h.priority,a.assignment_status FROM hazard_report h JOIN assignment a USING(report_id) WHERE h.report_id=:report_id;
ROLLBACK;
SELECT (SELECT count(*) FROM public.role) AS role, (SELECT count(*) FROM public.app_user) AS app_user, (SELECT count(*) FROM public.hazard_category) AS hazard_category, (SELECT count(*) FROM public.campus_location) AS campus_location, (SELECT count(*) FROM public.hazard_report) AS hazard_report, (SELECT count(*) FROM public.assignment) AS assignment, (SELECT count(*) FROM public.report_status_history) AS report_status_history, (SELECT count(*) FROM public.maintenance_action) AS maintenance_action, (SELECT count(*) FROM public.attachment) AS attachment;
ROLLBACK;

\echo runtime-deny-role-insert expected=denied
BEGIN;
INSERT INTO role(role_name) VALUES ('E4 forbidden');
ROLLBACK;
ROLLBACK;

\echo runtime-deny-role-update expected=denied
BEGIN;
UPDATE role SET description=description WHERE role_id=1;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-role-delete expected=denied
BEGIN;
DELETE FROM role WHERE false;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-user-delete expected=denied
BEGIN;
DELETE FROM app_user WHERE false;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-category-delete expected=denied
BEGIN;
DELETE FROM hazard_category WHERE false;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-location-delete expected=denied
BEGIN;
DELETE FROM campus_location WHERE false;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-report-delete expected=denied
BEGIN;
DELETE FROM hazard_report WHERE false;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-assignment-delete expected=denied
BEGIN;
DELETE FROM assignment WHERE false;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-history-update expected=denied
BEGIN;
UPDATE report_status_history SET notes=notes WHERE false;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-history-delete expected=denied
BEGIN;
DELETE FROM report_status_history WHERE false;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-action-update expected=denied
BEGIN;
UPDATE maintenance_action SET notes=notes WHERE false;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-action-delete expected=denied
BEGIN;
DELETE FROM maintenance_action WHERE false;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-attachment-update expected=denied
BEGIN;
UPDATE attachment SET file_name=file_name WHERE false;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-truncate expected=denied
BEGIN;
TRUNCATE report_status_history;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-create-table expected=denied
BEGIN;
CREATE TABLE public.e4_forbidden(id integer);
ROLLBACK;
ROLLBACK;

\echo runtime-deny-create-schema expected=denied
BEGIN;
CREATE SCHEMA e4_forbidden;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-create-temp expected=denied
BEGIN;
CREATE TEMP TABLE e4_forbidden(id integer);
ROLLBACK;
ROLLBACK;

\echo runtime-deny-alter-table expected=denied
BEGIN;
ALTER TABLE role ADD COLUMN e4_forbidden integer;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-role-sequence expected=denied
BEGIN;
SELECT nextval('role_role_id_seq');
ROLLBACK;
ROLLBACK;

\echo runtime-deny-sequence-reset expected=denied
BEGIN;
SELECT setval('hazard_report_report_id_seq',1);
ROLLBACK;
ROLLBACK;

\echo runtime-deny-owner-escalation expected=denied
BEGIN;
SET ROLE campussafe_owner_grp;
ROLLBACK;
ROLLBACK;

\echo deny-createdb-campussafe_app expected=denied
CREATE DATABASE campussafe_e4_forbidden;
ROLLBACK;

\echo deny-createrole-campussafe_app expected=denied
CREATE ROLE campussafe_e4_forbidden NOLOGIN;
ROLLBACK;
