-- Restricted demonstration, not a claim of successful maintenance.
-- Only brewpos_app exists; no authorized maintenance login/group was found.
-- ANALYZE would refresh planner statistics; ordinary VACUUM would reclaim dead tuple space.
-- The catalog shows MAINTAIN=false and postgres ownership, so expect permission skips.
-- Do not grant privileges, SET ROLE or reconnect as a superuser to make these work.
-- One small real table is sufficient to demonstrate the limitation; do not repeat on all tables.
-- VACUUM must be standalone; never run this with --single-transaction.
\set ON_ERROR_STOP off
\set VERBOSITY verbose
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database();
SET lock_timeout='3s';
SET statement_timeout='30s';
SELECT c.relname,pg_get_userbyid(c.relowner) AS owner,has_table_privilege(current_user,c.oid,'MAINTAIN') AS can_maintain
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relkind='r' ORDER BY c.relname;
ANALYZE VERBOSE public.menu_item;
VACUUM (VERBOSE, ANALYZE) public.menu_item;
