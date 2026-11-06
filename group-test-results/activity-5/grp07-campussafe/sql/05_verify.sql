-- Run directly as campussafe_report. Approved metadata and aggregate counts only.
-- app_user and role are intentionally excluded from auditor counts.
\set ON_ERROR_STOP on
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database(),version();
SELECT relname,n_live_tup,n_dead_tup,n_mod_since_analyze,last_vacuum,last_analyze,vacuum_count,analyze_count FROM pg_stat_user_tables ORDER BY relname;
SELECT 'assignment' AS table_name,count(*) AS rows FROM public.assignment
UNION ALL SELECT 'attachment' AS table_name,count(*) AS rows FROM public.attachment
UNION ALL SELECT 'campus_location' AS table_name,count(*) AS rows FROM public.campus_location
UNION ALL SELECT 'hazard_category' AS table_name,count(*) AS rows FROM public.hazard_category
UNION ALL SELECT 'hazard_report' AS table_name,count(*) AS rows FROM public.hazard_report
UNION ALL SELECT 'maintenance_action' AS table_name,count(*) AS rows FROM public.maintenance_action
UNION ALL SELECT 'report_status_history' AS table_name,count(*) AS rows FROM public.report_status_history ORDER BY table_name;
