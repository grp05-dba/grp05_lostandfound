-- Run directly as grp03_ojt_auditor. Metadata and aggregate counts only; no credentials or profile values.
\set ON_ERROR_STOP on
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database(),version();
SELECT relname,n_live_tup,n_dead_tup,n_mod_since_analyze,last_vacuum,last_analyze,vacuum_count,analyze_count FROM pg_stat_user_tables ORDER BY relname;
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
