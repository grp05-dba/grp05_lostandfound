-- Run directly as grp03_ojt_auditor. Metadata and aggregate counts only; no credentials or profile values.
\set ON_ERROR_STOP on
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database(),version();
SELECT pg_size_pretty(pg_database_size(current_database())) AS database_size,pg_database_size(current_database()) AS database_bytes;
SELECT c.relkind,count(*) AS object_count FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' GROUP BY c.relkind ORDER BY c.relkind;
SELECT tablename,tableowner FROM pg_tables WHERE schemaname='public' ORDER BY tablename;
SELECT 'academic_supervisors' AS table_name,count(*) AS rows FROM public.academic_supervisors
UNION ALL SELECT 'attendance' AS table_name,count(*) AS rows FROM public.attendance
UNION ALL SELECT 'audit_log' AS table_name,count(audit_id) AS rows FROM public.audit_log
UNION ALL SELECT 'companies' AS table_name,count(*) AS rows FROM public.companies
UNION ALL SELECT 'company_supervisors' AS table_name,count(*) AS rows FROM public.company_supervisors
UNION ALL SELECT 'evaluations' AS table_name,count(*) AS rows FROM public.evaluations
UNION ALL SELECT 'ojt_applications' AS table_name,count(*) AS rows FROM public.ojt_applications
UNION ALL SELECT 'ojt_placements' AS table_name,count(*) AS rows FROM public.ojt_placements
UNION ALL SELECT 'requirements' AS table_name,count(*) AS rows FROM public.requirements
UNION ALL SELECT 'student_requirements' AS table_name,count(*) AS rows FROM public.student_requirements
UNION ALL SELECT 'students' AS table_name,count(*) AS rows FROM public.students
UNION ALL SELECT 'users' AS table_name,count(user_id) AS rows FROM public.users ORDER BY table_name;
SELECT datname,numbackends,xact_commit,xact_rollback,deadlocks,conflicts,sessions,sessions_abandoned,sessions_fatal,sessions_killed,stats_reset FROM pg_stat_database WHERE datname=current_database();
-- Other accounts' SQL is omitted to avoid credentials and personal data. Privileges may also hide fields.
SELECT pid,usename,application_name,state,wait_event_type,wait_event,query_start,
 CASE WHEN state='active' THEN clock_timestamp()-query_start END AS active_duration,
 CASE WHEN usename=current_user THEN query ELSE '[other-account SQL omitted; visibility may be restricted]' END AS query
FROM pg_stat_activity WHERE datname=current_database() ORDER BY query_start NULLS LAST;
SELECT pid,usename,state,pg_blocking_pids(pid) AS blocking_pids FROM pg_stat_activity WHERE datname=current_database();
SELECT rolname,rolcanlogin,rolsuper,rolcreatedb,rolcreaterole,rolinherit,rolbypassrls,rolreplication FROM pg_roles WHERE rolname LIKE 'grp03_ojt_%' ORDER BY rolname;
SELECT member.rolname AS login,parent.rolname AS group_role,m.admin_option,m.inherit_option,m.set_option
FROM pg_auth_members m JOIN pg_roles member ON member.oid=m.member JOIN pg_roles parent ON parent.oid=m.roleid WHERE member.rolname LIKE 'grp03_ojt_%' ORDER BY login,group_role;
SELECT datname,pg_get_userbyid(datdba) AS owner,datacl FROM pg_database WHERE datname IN (current_database(),'grp_parkitdb','postgres') ORDER BY datname;
SELECT nspname,nspacl FROM pg_namespace WHERE nspname='public';
SELECT r.rolname,c.relname,p.privilege,has_table_privilege(r.oid,c.oid,p.privilege) AS allowed
FROM pg_roles r CROSS JOIN pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
CROSS JOIN (VALUES ('SELECT'),('INSERT'),('UPDATE'),('DELETE'),('TRUNCATE'),('MAINTAIN')) p(privilege)
WHERE r.rolname IN ('grp03_ojt_app','grp03_ojt_auditor','grp03_ojt_dba') AND n.nspname='public' AND c.relkind='r' ORDER BY r.rolname,c.relname,p.privilege;
SELECT grantee,table_name,column_name,privilege_type FROM information_schema.column_privileges
WHERE table_schema='public' AND grantee IN ('grp03_ojt_readonly_grp','grp03_ojt_runtime_grp')
AND (table_name IN ('users','audit_log') OR privilege_type='UPDATE') ORDER BY grantee,table_name,column_name,privilege_type;
SELECT has_column_privilege('grp03_ojt_auditor','public.users','user_id','SELECT') AS auditor_id,
 has_column_privilege('grp03_ojt_auditor','public.users','email','SELECT') AS auditor_email,
 has_column_privilege('grp03_ojt_auditor','public.users','password_hash','SELECT') AS auditor_hash,
 has_column_privilege('grp03_ojt_auditor','public.audit_log','details','SELECT') AS auditor_audit_details,
 has_column_privilege('grp03_ojt_app','public.users','is_active','UPDATE') AS runtime_activation_update,
 has_column_privilege('grp03_ojt_app','public.users','role','UPDATE') AS runtime_role_update,
 has_column_privilege('grp03_ojt_app','public.attendance','is_verified','UPDATE') AS runtime_verify_update,
 has_column_privilege('grp03_ojt_app','public.attendance','hours_rendered','UPDATE') AS runtime_hours_update;
SELECT r.rolname,d.datname,has_database_privilege(r.oid,d.oid,'CONNECT') AS can_connect
FROM pg_roles r CROSS JOIN pg_database d WHERE r.rolname IN ('grp03_ojt_app','grp03_ojt_auditor','grp03_ojt_dba') AND d.datname IN ('grp_parkitdb','postgres') ORDER BY r.rolname,d.datname;
SELECT relname,n_live_tup,n_dead_tup,n_mod_since_analyze,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze,vacuum_count,analyze_count FROM pg_stat_user_tables ORDER BY relname;
SELECT schemaname,tablename,indexname,indexdef FROM pg_indexes WHERE schemaname='public' ORDER BY tablename,indexname;
SELECT c.relname,c.reltuples,c.relpages,c.reloptions,age(c.relfrozenxid) AS xid_age,pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relkind='r' ORDER BY c.relname;
SELECT name,setting,unit FROM pg_settings WHERE name IN ('autovacuum','track_activities','track_counts') ORDER BY name;
SELECT count(*) AS user_defined_triggers FROM pg_trigger WHERE NOT tgisinternal AND tgrelid IN (SELECT oid FROM pg_class WHERE relnamespace='public'::regnamespace);
SELECT count(*) AS rls_policies FROM pg_policies WHERE schemaname='public';
