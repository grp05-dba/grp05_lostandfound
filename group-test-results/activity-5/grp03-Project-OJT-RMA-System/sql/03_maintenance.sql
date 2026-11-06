-- Existing local Activity 4 database only. Run directly as grp03_ojt_dba.
-- Ownership through the inherited admin group permits maintenance without superuser access.
-- ANALYZE refreshes planner statistics; ordinary VACUUM removes reusable dead space.
-- Baseline all 12 small tables; do not run with --single-transaction or use VACUUM FULL.
\set ON_ERROR_STOP on
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database();
SET lock_timeout='3s';
SET statement_timeout='30s';
SELECT c.relname,pg_get_userbyid(c.relowner) AS owner,has_table_privilege(current_user,c.oid,'MAINTAIN') AS can_maintain
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relkind='r' ORDER BY c.relname;
ANALYZE VERBOSE public.academic_supervisors;
ANALYZE VERBOSE public.attendance;
ANALYZE VERBOSE public.audit_log;
ANALYZE VERBOSE public.companies;
ANALYZE VERBOSE public.company_supervisors;
ANALYZE VERBOSE public.evaluations;
ANALYZE VERBOSE public.ojt_applications;
ANALYZE VERBOSE public.ojt_placements;
ANALYZE VERBOSE public.requirements;
ANALYZE VERBOSE public.student_requirements;
ANALYZE VERBOSE public.students;
ANALYZE VERBOSE public.users;
VACUUM (VERBOSE, ANALYZE) public.academic_supervisors;
VACUUM (VERBOSE, ANALYZE) public.attendance;
VACUUM (VERBOSE, ANALYZE) public.audit_log;
VACUUM (VERBOSE, ANALYZE) public.companies;
VACUUM (VERBOSE, ANALYZE) public.company_supervisors;
VACUUM (VERBOSE, ANALYZE) public.evaluations;
VACUUM (VERBOSE, ANALYZE) public.ojt_applications;
VACUUM (VERBOSE, ANALYZE) public.ojt_placements;
VACUUM (VERBOSE, ANALYZE) public.requirements;
VACUUM (VERBOSE, ANALYZE) public.student_requirements;
VACUUM (VERBOSE, ANALYZE) public.students;
VACUUM (VERBOSE, ANALYZE) public.users;
