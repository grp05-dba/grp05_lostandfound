-- Run as park_it_auditor in a new session after maintenance statistics are published.
\set ON_ERROR_STOP on
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database();
SELECT relname,n_live_tup,n_dead_tup,n_mod_since_analyze,last_vacuum,last_analyze,
       vacuum_count,analyze_count FROM pg_stat_user_tables ORDER BY relname;
SELECT 'parking_zone' AS table_name,count(*) AS rows FROM public.parking_zone
UNION ALL SELECT 'payment',count(*) FROM public.payment
UNION ALL SELECT 'staff_user',count(user_id) FROM public.staff_user
UNION ALL SELECT 'transaction',count(*) FROM public."transaction"
UNION ALL SELECT 'vehicle',count(*) FROM public.vehicle ORDER BY table_name;
