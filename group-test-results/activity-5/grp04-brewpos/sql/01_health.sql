-- Existing local BrewPOS database; run directly as brewpos_app.
-- Runtime is the only BrewPOS login found. Inspect within existing grants; no superuser fallback.
\set ON_ERROR_STOP on
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database(),version();
SELECT pg_size_pretty(pg_database_size(current_database())) AS database_size,pg_database_size(current_database()) AS database_bytes;
SELECT c.relkind,count(*) AS object_count FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' GROUP BY c.relkind ORDER BY c.relkind;
SELECT tablename,tableowner FROM pg_tables WHERE schemaname='public' ORDER BY tablename;
SELECT 'menu_category' AS table_name,count(*) AS rows FROM public.menu_category
UNION ALL SELECT 'menu_item' AS table_name,count(*) AS rows FROM public.menu_item
UNION ALL SELECT 'order_line_item' AS table_name,count(*) AS rows FROM public.order_line_item
UNION ALL SELECT 'order_ticket' AS table_name,count(*) AS rows FROM public.order_ticket
UNION ALL SELECT 'staff' AS table_name,count(*) AS rows FROM public.staff ORDER BY table_name;
SELECT datname,numbackends,xact_commit,xact_rollback,deadlocks,conflicts,sessions,sessions_abandoned,sessions_fatal,sessions_killed,stats_reset FROM pg_stat_database WHERE datname=current_database();
-- Other users' SQL is omitted for redaction and may also be hidden by server privileges.
SELECT pid,usename,application_name,state,wait_event_type,wait_event,query_start,
 CASE WHEN state='active' THEN clock_timestamp()-query_start END AS active_duration,
 CASE WHEN usename=current_user THEN query ELSE '[other-account SQL omitted; visibility may be restricted]' END AS query
FROM pg_stat_activity WHERE datname=current_database() ORDER BY query_start NULLS LAST;
SELECT pid,usename,state,pg_blocking_pids(pid) AS blocking_pids FROM pg_stat_activity WHERE datname=current_database();
WITH expected(rolname) AS (VALUES ('brewpos_app'),('brewpos_auditor'),('brewpos_admin'),('app_runtime_grp'),('app_readonly_grp'),('app_admin_grp'))
SELECT e.rolname,r.oid IS NOT NULL AS present,r.rolcanlogin,r.rolsuper,r.rolcreatedb,r.rolcreaterole,r.rolinherit,r.rolbypassrls,r.rolreplication
FROM expected e LEFT JOIN pg_roles r ON r.rolname=e.rolname ORDER BY e.rolname;
SELECT member.rolname AS login,parent.rolname AS group_role,m.admin_option,m.inherit_option,m.set_option
FROM pg_auth_members m JOIN pg_roles member ON member.oid=m.member JOIN pg_roles parent ON parent.oid=m.roleid
WHERE member.rolname IN ('brewpos_app','brewpos_auditor','brewpos_admin','app_runtime_grp','app_readonly_grp','app_admin_grp') ORDER BY login,group_role;
SELECT datname,pg_get_userbyid(datdba) AS owner,datacl FROM pg_database WHERE datname IN (current_database(),'postgres') ORDER BY datname;
SELECT nspname,nspacl FROM pg_namespace WHERE nspname='public';
SELECT c.relname,p.privilege,has_table_privilege(current_user,c.oid,p.privilege) AS allowed,c.relacl
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
CROSS JOIN (VALUES ('SELECT'),('INSERT'),('UPDATE'),('DELETE'),('TRUNCATE'),('MAINTAIN')) p(privilege)
WHERE n.nspname='public' AND c.relkind='r' ORDER BY c.relname,p.privilege;
SELECT c.relname,has_sequence_privilege(current_user,c.oid,'USAGE') AS usage,has_sequence_privilege(current_user,c.oid,'SELECT') AS select,has_sequence_privilege(current_user,c.oid,'UPDATE') AS update
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relkind='S' ORDER BY c.relname;
SELECT has_database_privilege(current_user,'postgres','CONNECT') AS runtime_connect_to_unrelated_postgres;
SELECT relname,n_live_tup,n_dead_tup,n_mod_since_analyze,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze,vacuum_count,analyze_count FROM pg_stat_user_tables ORDER BY relname;
SELECT schemaname,tablename,indexname,indexdef FROM pg_indexes WHERE schemaname='public' ORDER BY tablename,indexname;
SELECT c.relname,c.reltuples,c.relpages,c.reloptions,age(c.relfrozenxid) AS xid_age,pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relkind='r' ORDER BY c.relname;
SELECT name,setting,unit FROM pg_settings WHERE name IN ('autovacuum','track_activities','track_counts') ORDER BY name;
SELECT unnest(setconfig) AS runtime_database_setting FROM pg_db_role_setting WHERE setrole=(SELECT oid FROM pg_roles WHERE rolname=current_user) AND setdatabase=(SELECT oid FROM pg_database WHERE datname=current_database());
