-- Direct campussafe_app; aggregate-only reads of auditor-excluded tables.
\set ON_ERROR_STOP on
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database();
SELECT 'app_user' AS table_name,count(user_id) AS rows FROM public.app_user
UNION ALL SELECT 'role',count(role_id) FROM public.role ORDER BY table_name;
