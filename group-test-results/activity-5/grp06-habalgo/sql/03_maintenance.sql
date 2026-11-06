-- Run directly as habalgo_app_user after the source role plan is installed.
-- Source roles have no MAINTAIN. Expect permission-warning skips; never treat command tags as success.
-- ANALYZE would refresh statistics after seeding; ordinary VACUUM would maintain reusable space/visibility.
-- No maintenance role is supplied. Do not add grants, SET ROLE or use a superuser to bypass the result.
-- One seeded table demonstrates the limitation; never use --single-transaction or VACUUM FULL.
\set ON_ERROR_STOP off
\set VERBOSITY verbose
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database();
SET lock_timeout='3s';
SET statement_timeout='30s';
SELECT c.relname,pg_get_userbyid(c.relowner) AS owner,has_table_privilege(current_user,c.oid,'MAINTAIN') AS can_maintain
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='habalgo' AND c.relkind='r' ORDER BY c.relname;
ANALYZE VERBOSE habalgo.driver;
VACUUM (VERBOSE, ANALYZE) habalgo.driver;
