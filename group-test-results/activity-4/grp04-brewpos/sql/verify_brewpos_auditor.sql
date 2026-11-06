\set ON_ERROR_STOP off
\set VERBOSITY verbose
-- Expected denials intentionally continue. See evidence and results.json.
\echo identity-brewpos_auditor expected=allowed
SELECT session_user, current_user, current_database();

ROLLBACK;

\echo read-brewpos_auditor expected=allowed
SELECT (SELECT count(*) FROM staff) AS staff, (SELECT count(*) FROM menu_category) AS categories, (SELECT count(*) FROM menu_item) AS items, (SELECT count(*) FROM order_ticket) AS orders, (SELECT count(*) FROM order_line_item) AS lines;
ROLLBACK;

\echo auditor-deny-insert-staff expected=denied
BEGIN;
INSERT INTO staff DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-update-staff expected=denied
BEGIN;
UPDATE staff SET full_name=full_name WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-delete-staff expected=denied
BEGIN;
DELETE FROM staff WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-insert-menu_category expected=denied
BEGIN;
INSERT INTO menu_category DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-update-menu_category expected=denied
BEGIN;
UPDATE menu_category SET category_name=category_name WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-delete-menu_category expected=denied
BEGIN;
DELETE FROM menu_category WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-insert-menu_item expected=denied
BEGIN;
INSERT INTO menu_item DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-update-menu_item expected=denied
BEGIN;
UPDATE menu_item SET price=price WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-delete-menu_item expected=denied
BEGIN;
DELETE FROM menu_item WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-insert-order_ticket expected=denied
BEGIN;
INSERT INTO order_ticket DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-update-order_ticket expected=denied
BEGIN;
UPDATE order_ticket SET payment_method=payment_method WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-delete-order_ticket expected=denied
BEGIN;
DELETE FROM order_ticket WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-insert-order_line_item expected=denied
BEGIN;
INSERT INTO order_line_item DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-update-order_line_item expected=denied
BEGIN;
UPDATE order_line_item SET quantity=quantity WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-delete-order_line_item expected=denied
BEGIN;
DELETE FROM order_line_item WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-sequence expected=denied
SELECT nextval('order_ticket_order_id_seq');
ROLLBACK;

\echo auditor-deny-create-table expected=denied
BEGIN; CREATE TABLE public.e4_forbidden(id integer); ROLLBACK;
ROLLBACK;

\echo auditor-deny-owner expected=denied
SET ROLE brewpos_owner_grp;
ROLLBACK;

\echo deny-createdb-brewpos_auditor expected=denied
CREATE DATABASE e4_forbidden_database;
ROLLBACK;

\echo deny-createrole-brewpos_auditor expected=denied
CREATE ROLE e4_forbidden_role NOLOGIN;
ROLLBACK;
