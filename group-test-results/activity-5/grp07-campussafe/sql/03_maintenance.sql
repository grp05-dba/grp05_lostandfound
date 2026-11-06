-- Run directly as documented non-superuser campussafe_owner, after reviewed prerequisite setup.
-- ANALYZE refreshes seeded-table statistics; ordinary VACUUM maintains dead-space/visibility/freeze data.
-- Do not run with --single-transaction. No FULL vacuum, new indexes or application DML.
\set ON_ERROR_STOP on
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database();
SET lock_timeout='3s';
SET statement_timeout='30s';
SELECT c.relname,pg_get_userbyid(c.relowner) AS owner,has_table_privilege(current_user,c.oid,'MAINTAIN') AS can_maintain FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relkind='r' ORDER BY c.relname;
ANALYZE VERBOSE public.app_user;
ANALYZE VERBOSE public.assignment;
ANALYZE VERBOSE public.attachment;
ANALYZE VERBOSE public.campus_location;
ANALYZE VERBOSE public.hazard_category;
ANALYZE VERBOSE public.hazard_report;
ANALYZE VERBOSE public.maintenance_action;
ANALYZE VERBOSE public.report_status_history;
ANALYZE VERBOSE public.role;
VACUUM (VERBOSE, ANALYZE) public.app_user;
VACUUM (VERBOSE, ANALYZE) public.assignment;
VACUUM (VERBOSE, ANALYZE) public.attachment;
VACUUM (VERBOSE, ANALYZE) public.campus_location;
VACUUM (VERBOSE, ANALYZE) public.hazard_category;
VACUUM (VERBOSE, ANALYZE) public.hazard_report;
VACUUM (VERBOSE, ANALYZE) public.maintenance_action;
VACUUM (VERBOSE, ANALYZE) public.report_status_history;
VACUUM (VERBOSE, ANALYZE) public.role;
