\set ON_ERROR_STOP off
\set VERBOSITY verbose
-- Expected denials intentionally continue. See evidence and results.json.
\echo identity-brewpos_app expected=allowed
SELECT session_user, current_user, current_database();

ROLLBACK;

\echo read-brewpos_app expected=allowed
SELECT (SELECT count(*) FROM staff) AS staff, (SELECT count(*) FROM menu_category) AS categories, (SELECT count(*) FROM menu_item) AS items, (SELECT count(*) FROM order_ticket) AS orders, (SELECT count(*) FROM order_line_item) AS lines;
ROLLBACK;

\echo runtime-catalog-write expected=allowed
BEGIN;
INSERT INTO menu_category(category_name) VALUES ('E4 temporary category') RETURNING category_id \gset
UPDATE menu_category SET category_name='E4 renamed category' WHERE category_id=:category_id RETURNING category_name;
INSERT INTO menu_item(category_id,item_name,price) VALUES (:category_id,'E4 temporary item',10) RETURNING item_id \gset
UPDATE menu_item SET price=12.50,is_active=false WHERE item_id=:item_id RETURNING price,is_active;
ROLLBACK;
SELECT count(*) AS leftover_categories FROM menu_category WHERE category_name LIKE 'E4%';
SELECT count(*) AS leftover_items FROM menu_item WHERE item_name LIKE 'E4%';
ROLLBACK;

\echo runtime-category-delete expected=allowed
BEGIN; INSERT INTO menu_category(category_name) VALUES ('E4 delete probe') RETURNING category_id \gset
DELETE FROM menu_category WHERE category_id=:category_id RETURNING category_name; ROLLBACK;
ROLLBACK;

\echo runtime-checkout expected=allowed
BEGIN;
INSERT INTO order_ticket(staff_id,payment_method) SELECT min(staff_id),'CASH' FROM staff RETURNING order_id \gset
INSERT INTO order_line_item(order_id,item_id,quantity,sold_price) SELECT :order_id,item_id,2,price FROM menu_item WHERE is_active AND item_name='Americano' ORDER BY item_id LIMIT 1;
SELECT order_id,SUM(quantity*sold_price) AS total FROM order_line_item WHERE order_id=:order_id GROUP BY order_id;
ROLLBACK;
SELECT (SELECT count(*) FROM staff) AS staff, (SELECT count(*) FROM menu_category) AS categories, (SELECT count(*) FROM menu_item) AS items, (SELECT count(*) FROM order_ticket) AS orders, (SELECT count(*) FROM order_line_item) AS lines;
ROLLBACK;

\echo runtime-deny-staff-insert expected=denied
BEGIN;
INSERT INTO staff(full_name,role) VALUES ('E4 probe','CASHIER');
ROLLBACK;
ROLLBACK;

\echo runtime-deny-staff-update expected=denied
BEGIN;
UPDATE staff SET full_name=full_name WHERE staff_id=1;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-staff-delete expected=denied
BEGIN;
DELETE FROM staff WHERE staff_id=1;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-item-delete expected=denied
BEGIN;
DELETE FROM menu_item WHERE false;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-order-update expected=denied
BEGIN;
UPDATE order_ticket SET payment_method=payment_method WHERE order_id=1;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-order-delete expected=denied
BEGIN;
DELETE FROM order_ticket WHERE false;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-line-update expected=denied
BEGIN;
UPDATE order_line_item SET sold_price=sold_price WHERE order_id=1;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-line-delete expected=denied
BEGIN;
DELETE FROM order_line_item WHERE false;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-truncate expected=denied
BEGIN;
TRUNCATE order_line_item;
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

\echo runtime-deny-alter-table expected=denied
BEGIN;
ALTER TABLE staff ADD COLUMN e4_forbidden integer;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-staff-sequence expected=denied
BEGIN;
SELECT nextval('staff_staff_id_seq');
ROLLBACK;
ROLLBACK;

\echo runtime-deny-sequence-reset expected=denied
BEGIN;
SELECT setval('order_ticket_order_id_seq',1);
ROLLBACK;
ROLLBACK;

\echo runtime-deny-owner-escalation expected=denied
BEGIN;
SET ROLE brewpos_owner_grp;
ROLLBACK;
ROLLBACK;

\echo deny-createdb-brewpos_app expected=denied
CREATE DATABASE e4_forbidden_database;
ROLLBACK;

\echo deny-createrole-brewpos_app expected=denied
CREATE ROLE e4_forbidden_role NOLOGIN;
ROLLBACK;
