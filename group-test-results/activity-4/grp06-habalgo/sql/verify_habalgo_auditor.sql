\set ON_ERROR_STOP off
\set VERBOSITY verbose
-- Expected denials deliberately continue; inspect statements and evidence.
\echo identity-habalgo_auditor expected=allowed
SELECT session_user,current_user,current_database();
ROLLBACK;

\echo read-habalgo_auditor expected=allowed
SELECT (SELECT count(*) FROM habalgo.customer) AS customer, (SELECT count(*) FROM habalgo.driver) AS driver, (SELECT count(*) FROM habalgo.vehicle) AS vehicle, (SELECT count(*) FROM habalgo.driver_vehicle) AS driver_vehicle, (SELECT count(*) FROM habalgo.location) AS location, (SELECT count(*) FROM habalgo.booking) AS booking, (SELECT count(*) FROM habalgo.payment) AS payment, (SELECT count(*) FROM habalgo.rating_feedback) AS rating_feedback;
ROLLBACK;

\echo auditor-deny-insert-customer expected=denied
BEGIN;
INSERT INTO habalgo.customer DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-update-customer expected=denied
BEGIN;
UPDATE habalgo.customer SET name=name WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-delete-customer expected=denied
BEGIN;
DELETE FROM habalgo.customer WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-insert-driver expected=denied
BEGIN;
INSERT INTO habalgo.driver DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-update-driver expected=denied
BEGIN;
UPDATE habalgo.driver SET name=name WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-delete-driver expected=denied
BEGIN;
DELETE FROM habalgo.driver WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-insert-vehicle expected=denied
BEGIN;
INSERT INTO habalgo.vehicle DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-update-vehicle expected=denied
BEGIN;
UPDATE habalgo.vehicle SET model=model WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-delete-vehicle expected=denied
BEGIN;
DELETE FROM habalgo.vehicle WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-insert-driver_vehicle expected=denied
BEGIN;
INSERT INTO habalgo.driver_vehicle DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-update-driver_vehicle expected=denied
BEGIN;
UPDATE habalgo.driver_vehicle SET assigned_from=assigned_from WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-delete-driver_vehicle expected=denied
BEGIN;
DELETE FROM habalgo.driver_vehicle WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-insert-location expected=denied
BEGIN;
INSERT INTO habalgo.location DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-update-location expected=denied
BEGIN;
UPDATE habalgo.location SET address=address WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-delete-location expected=denied
BEGIN;
DELETE FROM habalgo.location WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-insert-booking expected=denied
BEGIN;
INSERT INTO habalgo.booking DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-update-booking expected=denied
BEGIN;
UPDATE habalgo.booking SET booking_status=booking_status WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-delete-booking expected=denied
BEGIN;
DELETE FROM habalgo.booking WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-insert-payment expected=denied
BEGIN;
INSERT INTO habalgo.payment DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-update-payment expected=denied
BEGIN;
UPDATE habalgo.payment SET amount=amount WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-delete-payment expected=denied
BEGIN;
DELETE FROM habalgo.payment WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-insert-rating_feedback expected=denied
BEGIN;
INSERT INTO habalgo.rating_feedback DEFAULT VALUES;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-update-rating_feedback expected=denied
BEGIN;
UPDATE habalgo.rating_feedback SET rating=rating WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-delete-rating_feedback expected=denied
BEGIN;
DELETE FROM habalgo.rating_feedback WHERE false;
ROLLBACK;
ROLLBACK;

\echo auditor-deny-sequence expected=denied
SELECT nextval('habalgo.customer_customer_id_seq');
ROLLBACK;

\echo auditor-deny-create expected=denied
BEGIN; CREATE TABLE habalgo.e4_forbidden(id integer); ROLLBACK;
ROLLBACK;

\echo auditor-deny-owner expected=denied
SET ROLE habalgo_owner_grp;
ROLLBACK;

\echo deny-createdb-habalgo_auditor expected=denied
CREATE DATABASE habalgo_e4_forbidden;
ROLLBACK;

\echo deny-createrole-habalgo_auditor expected=denied
CREATE ROLE habalgo_e4_forbidden NOLOGIN;
ROLLBACK;
