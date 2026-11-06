-- Run as park_it_auditor. Read-only inspection; do not select staff passwords.
\set ON_ERROR_STOP on
\pset pager off
SELECT clock_timestamp() AS captured_at, session_user, current_user, current_database(), version();
SELECT pg_size_pretty(pg_database_size(current_database())) AS database_size,
       pg_database_size(current_database()) AS database_bytes;
SELECT c.relkind, count(*) AS object_count
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='public' GROUP BY c.relkind ORDER BY c.relkind;
SELECT tablename, tableowner FROM pg_tables WHERE schemaname='public' ORDER BY tablename;
SELECT table_name,column_name,data_type,is_nullable,column_default
FROM information_schema.columns WHERE table_schema='public'
ORDER BY table_name,ordinal_position;
SELECT conrelid::regclass AS table_name,conname,pg_get_constraintdef(oid) AS definition
FROM pg_constraint WHERE connamespace='public'::regnamespace ORDER BY conrelid::regclass::text,conname;
SELECT 'parking_zone' AS table_name,count(*) AS rows FROM public.parking_zone
UNION ALL SELECT 'payment',count(*) FROM public.payment
UNION ALL SELECT 'staff_user',count(user_id) FROM public.staff_user
UNION ALL SELECT 'transaction',count(*) FROM public."transaction"
UNION ALL SELECT 'vehicle',count(*) FROM public.vehicle ORDER BY table_name;
SELECT datname,numbackends,xact_commit,xact_rollback,deadlocks,conflicts,
       sessions,sessions_abandoned,sessions_fatal,sessions_killed,stats_reset
FROM pg_stat_database WHERE datname=current_database();
-- Other users' query text may be hidden. Raw SQL from other sessions is deliberately excluded
-- because it may include credentials or personal data. Capture own SQL and durations where visible.
SELECT pid,usename,application_name,state,wait_event_type,wait_event,
       query_start,CASE WHEN state='active' THEN clock_timestamp()-query_start END AS active_duration,
       CASE WHEN usename=current_user THEN query ELSE '[other-account SQL omitted; visibility may be restricted]' END AS query
FROM pg_stat_activity WHERE datname=current_database() ORDER BY query_start NULLS LAST;
SELECT pid,usename,state,pg_blocking_pids(pid) AS blocking_pids
FROM pg_stat_activity WHERE datname=current_database();
SELECT rolname,rolcanlogin,rolsuper,rolcreatedb,rolcreaterole,rolinherit,rolbypassrls,rolreplication
FROM pg_roles WHERE rolname LIKE 'park_it_%' ORDER BY rolname;
SELECT member.rolname AS login,parent.rolname AS group_role,m.admin_option,m.inherit_option,m.set_option
FROM pg_auth_members m JOIN pg_roles member ON member.oid=m.member
JOIN pg_roles parent ON parent.oid=m.roleid
WHERE member.rolname LIKE 'park_it_%' ORDER BY login,group_role;
SELECT datname,pg_get_userbyid(datdba) AS owner,datacl
FROM pg_database WHERE datname IN (current_database(),'postgres') ORDER BY datname;
SELECT r.rolname,c.relname,p.privilege,
       has_table_privilege(r.oid,c.oid,p.privilege) AS allowed
FROM pg_roles r CROSS JOIN pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
CROSS JOIN (VALUES ('SELECT'),('INSERT'),('UPDATE'),('DELETE'),('MAINTAIN')) p(privilege)
WHERE r.rolname IN ('park_it_app','park_it_auditor','park_it_dba')
AND n.nspname='public' AND c.relkind='r' ORDER BY r.rolname,c.relname,p.privilege;
SELECT has_column_privilege('park_it_auditor','public.staff_user','user_id','SELECT') AS auditor_id,
       has_column_privilege('park_it_auditor','public.staff_user','username','SELECT') AS auditor_username,
       has_column_privilege('park_it_auditor','public.staff_user','role','SELECT') AS auditor_role,
       has_column_privilege('park_it_auditor','public.staff_user','password_hash','SELECT') AS auditor_password_hash;
SELECT r.rolname,has_database_privilege(r.oid,d.oid,'CONNECT') AS can_connect_to_postgres
FROM pg_roles r CROSS JOIN pg_database d
WHERE r.rolname IN ('park_it_app','park_it_auditor','park_it_dba') AND d.datname='postgres';
SELECT relname,n_live_tup,n_dead_tup,n_mod_since_analyze,last_vacuum,last_autovacuum,
       last_analyze,last_autoanalyze,vacuum_count,analyze_count
FROM pg_stat_user_tables ORDER BY relname;
SELECT schemaname,tablename,indexname,indexdef FROM pg_indexes
WHERE schemaname='public' ORDER BY tablename,indexname;
SELECT c.relname,c.reltuples,c.relpages,c.reloptions,age(c.relfrozenxid) AS xid_age
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='public' AND c.relkind='r' ORDER BY c.relname;
SELECT name,setting,unit FROM pg_settings
WHERE name IN ('autovacuum','track_activities','track_counts') ORDER BY name;
