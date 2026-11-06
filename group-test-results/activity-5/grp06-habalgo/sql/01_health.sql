-- Run directly as habalgo_readonly_user; metadata and aggregate counts only.
\set ON_ERROR_STOP on
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database(),version();
SELECT pg_size_pretty(pg_database_size(current_database())) AS database_size,pg_database_size(current_database()) AS database_bytes;
SELECT c.relkind,count(*) AS object_count FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='habalgo' GROUP BY c.relkind ORDER BY c.relkind;
SELECT tablename,tableowner FROM pg_tables WHERE schemaname='habalgo' ORDER BY tablename;
SELECT 'booking' AS table_name,count(*) AS rows FROM habalgo.booking
UNION ALL SELECT 'customer' AS table_name,count(*) AS rows FROM habalgo.customer
UNION ALL SELECT 'driver' AS table_name,count(*) AS rows FROM habalgo.driver
UNION ALL SELECT 'driver_vehicle' AS table_name,count(*) AS rows FROM habalgo.driver_vehicle
UNION ALL SELECT 'location' AS table_name,count(*) AS rows FROM habalgo.location
UNION ALL SELECT 'payment' AS table_name,count(*) AS rows FROM habalgo.payment
UNION ALL SELECT 'rating_feedback' AS table_name,count(*) AS rows FROM habalgo.rating_feedback
UNION ALL SELECT 'vehicle' AS table_name,count(*) AS rows FROM habalgo.vehicle ORDER BY table_name;
SELECT datname,numbackends,xact_commit,xact_rollback,deadlocks,conflicts,sessions,sessions_abandoned,sessions_fatal,sessions_killed,stats_reset FROM pg_stat_database WHERE datname=current_database();
SELECT pid,usename,application_name,state,wait_event_type,wait_event,query_start,
 CASE WHEN state='active' THEN clock_timestamp()-query_start END AS active_duration,
 CASE WHEN usename=current_user THEN query ELSE '[other-account SQL omitted; visibility may be restricted]' END AS query
FROM pg_stat_activity WHERE datname=current_database() ORDER BY query_start NULLS LAST;
SELECT pid,usename,state,pg_blocking_pids(pid) AS blocking_pids FROM pg_stat_activity WHERE datname=current_database();
SELECT rolname,rolcanlogin,rolsuper,rolcreatedb,rolcreaterole,rolinherit,rolbypassrls,rolreplication FROM pg_roles
WHERE rolname IN ('habalgo_app_user','habalgo_readonly_user','app_runtime_grp','app_readonly_grp') ORDER BY rolname;
SELECT member.rolname AS login,parent.rolname AS group_role,m.admin_option,m.inherit_option,m.set_option
FROM pg_auth_members m JOIN pg_roles member ON member.oid=m.member JOIN pg_roles parent ON parent.oid=m.roleid WHERE member.rolname IN ('habalgo_app_user','habalgo_readonly_user') ORDER BY login,group_role;
SELECT datname,pg_get_userbyid(datdba) AS owner,datacl FROM pg_database WHERE datname IN (current_database(),'postgres') ORDER BY datname;
SELECT nspname,nspacl FROM pg_namespace WHERE nspname='habalgo';
SELECT r.rolname,c.relname,p.privilege,has_table_privilege(r.oid,c.oid,p.privilege) AS allowed
FROM pg_roles r CROSS JOIN pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
CROSS JOIN (VALUES ('SELECT'),('INSERT'),('UPDATE'),('DELETE'),('TRUNCATE'),('MAINTAIN')) p(privilege)
WHERE r.rolname IN ('habalgo_app_user','habalgo_readonly_user') AND n.nspname='habalgo' AND c.relkind='r' ORDER BY r.rolname,c.relname,p.privilege;
SELECT r.rolname,c.relname,has_sequence_privilege(r.oid,c.oid,'USAGE') AS usage,has_sequence_privilege(r.oid,c.oid,'SELECT') AS select
FROM pg_roles r CROSS JOIN pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE r.rolname IN ('habalgo_app_user','habalgo_readonly_user') AND n.nspname='habalgo' AND c.relkind='S' ORDER BY r.rolname,c.relname;
SELECT r.rolname,has_database_privilege(r.oid,'postgres','CONNECT') AS can_connect_to_unrelated_postgres FROM pg_roles r WHERE r.rolname IN ('habalgo_app_user','habalgo_readonly_user') ORDER BY r.rolname;
SELECT relname,n_live_tup,n_dead_tup,n_mod_since_analyze,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze,vacuum_count,analyze_count FROM pg_stat_user_tables WHERE schemaname='habalgo' ORDER BY relname;
SELECT schemaname,tablename,indexname,indexdef FROM pg_indexes WHERE schemaname='habalgo' ORDER BY tablename,indexname;
SELECT c.relname,c.reltuples,c.relpages,c.reloptions,age(c.relfrozenxid) AS xid_age,pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='habalgo' AND c.relkind='r' ORDER BY c.relname;
SELECT name,setting,unit FROM pg_settings WHERE name IN ('autovacuum','track_activities','track_counts') ORDER BY name;
