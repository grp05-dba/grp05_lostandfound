-- Run directly as campussafe_report. Approved metadata and aggregate counts only.
-- app_user and role are intentionally excluded from auditor counts.
\set ON_ERROR_STOP on
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database(),version();
SELECT pg_size_pretty(pg_database_size(current_database())) AS database_size,pg_database_size(current_database()) AS database_bytes;
SELECT c.relkind,count(*) AS object_count FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' GROUP BY c.relkind ORDER BY c.relkind;
SELECT tablename,tableowner FROM pg_tables WHERE schemaname='public' ORDER BY tablename;
SELECT 'assignment' AS table_name,count(*) AS rows FROM public.assignment
UNION ALL SELECT 'attachment' AS table_name,count(*) AS rows FROM public.attachment
UNION ALL SELECT 'campus_location' AS table_name,count(*) AS rows FROM public.campus_location
UNION ALL SELECT 'hazard_category' AS table_name,count(*) AS rows FROM public.hazard_category
UNION ALL SELECT 'hazard_report' AS table_name,count(*) AS rows FROM public.hazard_report
UNION ALL SELECT 'maintenance_action' AS table_name,count(*) AS rows FROM public.maintenance_action
UNION ALL SELECT 'report_status_history' AS table_name,count(*) AS rows FROM public.report_status_history ORDER BY table_name;
SELECT datname,numbackends,xact_commit,xact_rollback,deadlocks,conflicts,sessions,sessions_abandoned,sessions_fatal,sessions_killed,stats_reset FROM pg_stat_database WHERE datname=current_database();
SELECT pid,usename,application_name,state,wait_event_type,wait_event,query_start,
 CASE WHEN state='active' THEN clock_timestamp()-query_start END AS active_duration,
 CASE WHEN usename=current_user THEN query ELSE '[other-account SQL omitted; visibility may be restricted]' END AS query
FROM pg_stat_activity WHERE datname=current_database() ORDER BY query_start NULLS LAST;
SELECT pid,usename,state,pg_blocking_pids(pid) AS blocking_pids FROM pg_stat_activity WHERE datname=current_database();
SELECT rolname,rolcanlogin,rolsuper,rolcreatedb,rolcreaterole,rolinherit,rolbypassrls,rolreplication FROM pg_roles WHERE rolname LIKE 'campussafe_%' ORDER BY rolname;
SELECT member.rolname AS login,parent.rolname AS group_role,m.admin_option,m.inherit_option,m.set_option
FROM pg_auth_members m JOIN pg_roles member ON member.oid=m.member JOIN pg_roles parent ON parent.oid=m.roleid WHERE member.rolname LIKE 'campussafe_%' ORDER BY login,group_role;
SELECT r.rolname,pg_has_role(r.oid,'app_runtime_grp','MEMBER') AS member_of_habalgo_runtime,pg_has_role(r.oid,'app_readonly_grp','MEMBER') AS member_of_habalgo_readonly
FROM pg_roles r WHERE r.rolname IN ('campussafe_app','campussafe_report','campussafe_backup','campussafe_owner') ORDER BY r.rolname;
SELECT datname,pg_get_userbyid(datdba) AS owner,datacl FROM pg_database WHERE datname IN (current_database(),'postgres') ORDER BY datname;
SELECT nspname,nspacl FROM pg_namespace WHERE nspname='public';
SELECT r.rolname,c.relname,p.privilege,has_table_privilege(r.oid,c.oid,p.privilege) AS allowed
FROM pg_roles r CROSS JOIN pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
CROSS JOIN (VALUES ('SELECT'),('INSERT'),('UPDATE'),('DELETE'),('TRUNCATE'),('MAINTAIN')) p(privilege)
WHERE r.rolname IN ('campussafe_app','campussafe_report','campussafe_backup','campussafe_owner') AND n.nspname='public' AND c.relkind='r' ORDER BY r.rolname,c.relname,p.privilege;
SELECT r.rolname,has_database_privilege(r.oid,'postgres','CONNECT') AS can_connect_to_unrelated_postgres FROM pg_roles r
WHERE r.rolname IN ('campussafe_app','campussafe_report','campussafe_backup','campussafe_owner') ORDER BY r.rolname;
SELECT relname,n_live_tup,n_dead_tup,n_mod_since_analyze,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze,vacuum_count,analyze_count FROM pg_stat_user_tables ORDER BY relname;
SELECT schemaname,tablename,indexname,indexdef FROM pg_indexes WHERE schemaname='public' ORDER BY tablename,indexname;
SELECT c.relname,c.reltuples,c.relpages,c.reloptions,age(c.relfrozenxid) AS xid_age,pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relkind='r' ORDER BY c.relname;
SELECT name,setting,unit FROM pg_settings WHERE name IN ('autovacuum','track_activities','track_counts') ORDER BY name;
-- Aggregate-only adaptations of the supplied verify.sql; no app_user join or personal values.
SELECT count(*) AS violation_unverified_with_verifier FROM public.hazard_report WHERE status='Submitted' AND (verified_by_user_id IS NOT NULL OR verified_at IS NOT NULL);
SELECT count(*) AS violation_resolved_missing_timestamp FROM public.hazard_report WHERE status IN ('Resolved','Closed') AND resolved_at IS NULL;
SELECT count(*) AS orphaned_assignments FROM public.assignment a LEFT JOIN public.hazard_report r ON a.report_id=r.report_id WHERE r.report_id IS NULL;
