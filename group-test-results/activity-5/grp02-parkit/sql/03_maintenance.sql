-- Run directly as park_it_dba against the existing local Activity 4 database.
-- PostgreSQL 18 table ALL includes MAINTAIN; verify rather than changing grants.
-- ANALYZE refreshes planner statistics. VACUUM reclaims reusable space and updates visibility.
-- Five small local tables: ordinary VACUUM is proportionate; no FULL, DDL, grants or seed writes.
-- Never run with psql --single-transaction: VACUUM must be standalone.
\set ON_ERROR_STOP on
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database();
SET lock_timeout='3s';
SET statement_timeout='30s';
SELECT c.relname,pg_get_userbyid(c.relowner) AS owner,
       has_table_privilege(current_user,c.oid,'MAINTAIN') AS can_maintain
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='public' AND c.relkind='r' ORDER BY c.relname;
ANALYZE VERBOSE public.parking_zone;
ANALYZE VERBOSE public.payment;
ANALYZE VERBOSE public.staff_user;
ANALYZE VERBOSE public."transaction";
ANALYZE VERBOSE public.vehicle;
VACUUM (VERBOSE, ANALYZE) public.parking_zone;
VACUUM (VERBOSE, ANALYZE) public.payment;
VACUUM (VERBOSE, ANALYZE) public.staff_user;
VACUUM (VERBOSE, ANALYZE) public."transaction";
VACUUM (VERBOSE, ANALYZE) public.vehicle;
