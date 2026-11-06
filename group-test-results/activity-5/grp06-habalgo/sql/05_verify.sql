-- Run directly as habalgo_readonly_user; metadata and aggregate counts only.
\set ON_ERROR_STOP on
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database(),version();
SELECT relname,n_live_tup,n_dead_tup,n_mod_since_analyze,last_vacuum,last_analyze,vacuum_count,analyze_count FROM pg_stat_user_tables WHERE schemaname='habalgo' ORDER BY relname;
SELECT 'booking' AS table_name,count(*) AS rows FROM habalgo.booking
UNION ALL SELECT 'customer' AS table_name,count(*) AS rows FROM habalgo.customer
UNION ALL SELECT 'driver' AS table_name,count(*) AS rows FROM habalgo.driver
UNION ALL SELECT 'driver_vehicle' AS table_name,count(*) AS rows FROM habalgo.driver_vehicle
UNION ALL SELECT 'location' AS table_name,count(*) AS rows FROM habalgo.location
UNION ALL SELECT 'payment' AS table_name,count(*) AS rows FROM habalgo.payment
UNION ALL SELECT 'rating_feedback' AS table_name,count(*) AS rows FROM habalgo.rating_feedback
UNION ALL SELECT 'vehicle' AS table_name,count(*) AS rows FROM habalgo.vehicle ORDER BY table_name;
