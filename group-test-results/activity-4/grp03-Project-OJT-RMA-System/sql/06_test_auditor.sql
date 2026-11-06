\pset pager off
\set VERBOSITY verbose
SELECT current_database(), session_user, current_user;
\echo R01: approved reads
SELECT user_id,username,role,is_active FROM users;
SELECT audit_id,table_name,action,row_id,action_time FROM audit_log LIMIT 0;
SELECT count(*) FROM companies;
SELECT count(*) FROM students;
SELECT count(*) FROM attendance;
\echo R02: expected denial
BEGIN;
SELECT password_hash FROM users LIMIT 0;
ROLLBACK;
\echo R03: expected denial
BEGIN;
SELECT details FROM audit_log LIMIT 0;
ROLLBACK;
\echo R04: expected denial
BEGIN;
UPDATE companies SET company_name=company_name WHERE false;
ROLLBACK;
\echo R05: expected denial
BEGIN;
INSERT INTO requirements(title) VALUES ('Activity4 denied');
ROLLBACK;
\echo R06: expected denial
BEGIN;
DELETE FROM attendance WHERE false;
ROLLBACK;
\echo R07: expected denial
BEGIN;
SELECT nextval('requirements_req_id_seq');
ROLLBACK;
\echo R08: expected denial
BEGIN;
CREATE TABLE public.a4_forbidden(id int);
ROLLBACK;
\echo R09: expected denial
BEGIN;
SET ROLE grp03_ojt_runtime_grp;
ROLLBACK;
\echo R10: expected cluster privilege denials
CREATE DATABASE grp03_a4_forbidden;
CREATE ROLE grp03_a4_forbidden NOLOGIN;
