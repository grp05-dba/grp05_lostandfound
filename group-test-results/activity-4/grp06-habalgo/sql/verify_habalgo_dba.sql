\set ON_ERROR_STOP off
\set VERBOSITY verbose
-- Expected denials deliberately continue; inspect statements and evidence.
\echo identity-habalgo_dba expected=allowed
SELECT session_user,current_user,current_database();
ROLLBACK;

\echo read-habalgo_dba expected=allowed
SELECT (SELECT count(*) FROM habalgo.customer) AS customer, (SELECT count(*) FROM habalgo.driver) AS driver, (SELECT count(*) FROM habalgo.vehicle) AS vehicle, (SELECT count(*) FROM habalgo.driver_vehicle) AS driver_vehicle, (SELECT count(*) FROM habalgo.location) AS location, (SELECT count(*) FROM habalgo.booking) AS booking, (SELECT count(*) FROM habalgo.payment) AS payment, (SELECT count(*) FROM habalgo.rating_feedback) AS rating_feedback;
ROLLBACK;

\echo dba-maintenance expected=allowed
BEGIN;
SET ROLE habalgo_owner_grp;
INSERT INTO habalgo.driver(name,phone,license_no) VALUES ('E4 DBA driver','09000000000','E4-DBA-TEST') RETURNING driver_id;
ALTER TABLE habalgo.customer ADD COLUMN e4_probe text;
CREATE TABLE habalgo.e4_ddl_probe(id integer);
DROP TABLE habalgo.e4_ddl_probe;
ROLLBACK;
SELECT to_regclass('habalgo.e4_ddl_probe') IS NULL AS ddl_removed;
SELECT count(*) AS leftover_drivers FROM habalgo.driver WHERE license_no='E4-DBA-TEST';
ROLLBACK;

\echo deny-createdb-habalgo_dba expected=denied
CREATE DATABASE habalgo_e4_forbidden;
ROLLBACK;

\echo deny-createrole-habalgo_dba expected=denied
CREATE ROLE habalgo_e4_forbidden NOLOGIN;
ROLLBACK;
