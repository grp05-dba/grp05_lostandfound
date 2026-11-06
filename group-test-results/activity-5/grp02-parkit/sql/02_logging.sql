-- Run directly as park_it_dba. Expected log-access errors are evidence, not permission bypasses.
\set ON_ERROR_STOP off
\set VERBOSITY verbose
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database();
SELECT name,setting,unit FROM pg_settings
WHERE name IN ('logging_collector','log_destination','log_directory','log_filename',
 'log_min_duration_statement','log_min_messages','log_statement','log_connections','log_disconnections')
ORDER BY name;
SELECT pg_has_role(current_user,'pg_monitor','USAGE') AS monitor,
       pg_has_role(current_user,'pg_read_all_stats','USAGE') AS read_all_stats,
       pg_has_role(current_user,'pg_read_server_files','USAGE') AS read_server_files;
SELECT pg_current_logfile();
SELECT * FROM pg_ls_logdir();
