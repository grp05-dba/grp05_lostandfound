\set ON_ERROR_STOP off
\set VERBOSITY verbose
-- Expected denials intentionally continue. See evidence and results.json.
\echo identity-brewpos_dba expected=allowed
SELECT session_user, current_user, current_database();

ROLLBACK;

\echo read-brewpos_dba expected=allowed
SELECT (SELECT count(*) FROM staff) AS staff, (SELECT count(*) FROM menu_category) AS categories, (SELECT count(*) FROM menu_item) AS items, (SELECT count(*) FROM order_ticket) AS orders, (SELECT count(*) FROM order_line_item) AS lines;
ROLLBACK;

\echo dba-maintenance expected=allowed
BEGIN;
SET ROLE brewpos_owner_grp;
INSERT INTO staff(full_name,role) VALUES ('E4 DBA probe','MANAGER') RETURNING staff_id;
UPDATE menu_item SET price=price WHERE item_id=1;
ALTER TABLE staff ADD COLUMN e4_probe text;
CREATE TABLE public.e4_ddl_probe(id integer);
DROP TABLE public.e4_ddl_probe;
ROLLBACK;
SELECT to_regclass('public.e4_ddl_probe') IS NULL AS ddl_rolled_back;
SELECT count(*) AS leftover_staff FROM staff WHERE full_name='E4 DBA probe';
ROLLBACK;

\echo deny-createdb-brewpos_dba expected=denied
CREATE DATABASE e4_forbidden_database;
ROLLBACK;

\echo deny-createrole-brewpos_dba expected=denied
CREATE ROLE e4_forbidden_role NOLOGIN;
ROLLBACK;
