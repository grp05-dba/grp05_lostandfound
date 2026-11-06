\set ON_ERROR_STOP off
\set VERBOSITY verbose
-- Expected denials deliberately continue; inspect statements and evidence.
\echo identity-habalgo_app expected=allowed
SELECT session_user,current_user,current_database();
ROLLBACK;

\echo read-habalgo_app expected=allowed
SELECT (SELECT count(*) FROM habalgo.customer) AS customer, (SELECT count(*) FROM habalgo.driver) AS driver, (SELECT count(*) FROM habalgo.vehicle) AS vehicle, (SELECT count(*) FROM habalgo.driver_vehicle) AS driver_vehicle, (SELECT count(*) FROM habalgo.location) AS location, (SELECT count(*) FROM habalgo.booking) AS booking, (SELECT count(*) FROM habalgo.payment) AS payment, (SELECT count(*) FROM habalgo.rating_feedback) AS rating_feedback;
ROLLBACK;

\echo runtime-full-workflow expected=allowed
BEGIN;
INSERT INTO habalgo.customer(name,phone,email) VALUES ('E4 customer','09000000000','e4-customer@example.invalid') RETURNING customer_id \gset
INSERT INTO habalgo.vehicle(plate_no,vehicle_type,model) VALUES ('E4-TEST','Motorcycle','E4 model') RETURNING vehicle_id \gset
SELECT min(driver_id) AS driver_id FROM habalgo.driver \gset
INSERT INTO habalgo.driver_vehicle(driver_id,vehicle_id,assigned_from) VALUES (:driver_id,:vehicle_id,now());
INSERT INTO habalgo.location(address,city) VALUES ('E4 pickup','Manila') RETURNING location_id AS pickup_id \gset
INSERT INTO habalgo.location(address,city) VALUES ('E4 dropoff','Manila') RETURNING location_id AS dropoff_id \gset
INSERT INTO habalgo.booking(customer_id,driver_id,pickup_location_id,dropoff_location_id,booking_status)
VALUES (:customer_id,:driver_id,:pickup_id,:dropoff_id,'Completed') RETURNING booking_id \gset

INSERT INTO habalgo.payment(booking_id,amount,method,status) VALUES (:booking_id,150,'Cash','Paid') RETURNING payment_id \gset
INSERT INTO habalgo.rating_feedback(booking_id,customer_id,rating,feedback) VALUES (:booking_id,:customer_id,5,'E4 test') RETURNING rating_id \gset
UPDATE habalgo.customer SET name='E4 updated customer' WHERE customer_id=:customer_id;
UPDATE habalgo.vehicle SET model='E4 updated model' WHERE vehicle_id=:vehicle_id;
UPDATE habalgo.driver_vehicle SET assigned_to=now() WHERE driver_id=:driver_id AND vehicle_id=:vehicle_id;
UPDATE habalgo.booking SET booking_status='Confirmed' WHERE booking_id=:booking_id;
UPDATE habalgo.payment SET amount=175 WHERE payment_id=:payment_id;
UPDATE habalgo.rating_feedback SET rating=4 WHERE rating_id=:rating_id;
SELECT b.booking_status,p.amount,r.rating FROM habalgo.booking b JOIN habalgo.payment p USING(booking_id) JOIN habalgo.rating_feedback r USING(booking_id) WHERE b.booking_id=:booking_id;
DELETE FROM habalgo.rating_feedback WHERE rating_id=:rating_id;
DELETE FROM habalgo.payment WHERE payment_id=:payment_id;
DELETE FROM habalgo.booking WHERE booking_id=:booking_id;
DELETE FROM habalgo.driver_vehicle WHERE driver_id=:driver_id AND vehicle_id=:vehicle_id;
DELETE FROM habalgo.vehicle WHERE vehicle_id=:vehicle_id;
DELETE FROM habalgo.customer WHERE customer_id=:customer_id;
ROLLBACK;
SELECT (SELECT count(*) FROM habalgo.customer) AS customer, (SELECT count(*) FROM habalgo.driver) AS driver, (SELECT count(*) FROM habalgo.vehicle) AS vehicle, (SELECT count(*) FROM habalgo.driver_vehicle) AS driver_vehicle, (SELECT count(*) FROM habalgo.location) AS location, (SELECT count(*) FROM habalgo.booking) AS booking, (SELECT count(*) FROM habalgo.payment) AS payment, (SELECT count(*) FROM habalgo.rating_feedback) AS rating_feedback;
ROLLBACK;

\echo runtime-deny-driver-insert expected=denied
BEGIN;
INSERT INTO habalgo.driver(name,phone,license_no) VALUES ('E4 forbidden','09000000000','E4-FORBIDDEN');
ROLLBACK;
ROLLBACK;

\echo runtime-deny-driver-update expected=denied
BEGIN;
UPDATE habalgo.driver SET name=name WHERE driver_id=1;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-driver-delete expected=denied
BEGIN;
DELETE FROM habalgo.driver WHERE driver_id=1;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-location-update expected=denied
BEGIN;
UPDATE habalgo.location SET address=address WHERE false;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-location-delete expected=denied
BEGIN;
DELETE FROM habalgo.location WHERE false;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-truncate expected=denied
BEGIN;
TRUNCATE habalgo.payment;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-create-table expected=denied
BEGIN;
CREATE TABLE habalgo.e4_forbidden(id integer);
ROLLBACK;
ROLLBACK;

\echo runtime-deny-create-schema expected=denied
BEGIN;
CREATE SCHEMA e4_forbidden;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-public-create expected=denied
BEGIN;
CREATE TABLE public.e4_forbidden(id integer);
ROLLBACK;
ROLLBACK;

\echo runtime-deny-create-temp expected=denied
BEGIN;
CREATE TEMP TABLE e4_forbidden(id integer);
ROLLBACK;
ROLLBACK;

\echo runtime-deny-alter-table expected=denied
BEGIN;
ALTER TABLE habalgo.customer ADD COLUMN e4_forbidden integer;
ROLLBACK;
ROLLBACK;

\echo runtime-deny-driver-sequence expected=denied
BEGIN;
SELECT nextval('habalgo.driver_driver_id_seq');
ROLLBACK;
ROLLBACK;

\echo runtime-deny-sequence-reset expected=denied
BEGIN;
SELECT setval('habalgo.booking_booking_id_seq',1);
ROLLBACK;
ROLLBACK;

\echo runtime-deny-owner-escalation expected=denied
BEGIN;
SET ROLE habalgo_owner_grp;
ROLLBACK;
ROLLBACK;

\echo deny-createdb-habalgo_app expected=denied
CREATE DATABASE habalgo_e4_forbidden;
ROLLBACK;

\echo deny-createrole-habalgo_app expected=denied
CREATE ROLE habalgo_e4_forbidden NOLOGIN;
ROLLBACK;
