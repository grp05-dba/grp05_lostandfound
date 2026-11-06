\set ON_ERROR_STOP on
DO $$ BEGIN IF current_setting('port')<>'55403' OR current_database() NOT IN('ojt_managementdb','g05_a6_g03_restore','g05_a6_g03_snapshot','g05_a6_g03_recovered') THEN RAISE EXCEPTION 'Wrong Activity6 verification environment'; END IF; END $$;
SET ROLE grp03_ojt_admin_grp;
SELECT 'academic_supervisors' AS table_name,count(*) FROM public.academic_supervisors;
SELECT 'attendance' AS table_name,count(*) FROM public.attendance;
SELECT 'audit_log' AS table_name,count(*) FROM public.audit_log;
SELECT 'companies' AS table_name,count(*) FROM public.companies;
SELECT 'company_supervisors' AS table_name,count(*) FROM public.company_supervisors;
SELECT 'evaluations' AS table_name,count(*) FROM public.evaluations;
SELECT 'ojt_applications' AS table_name,count(*) FROM public.ojt_applications;
SELECT 'ojt_placements' AS table_name,count(*) FROM public.ojt_placements;
SELECT 'requirements' AS table_name,count(*) FROM public.requirements;
SELECT 'student_requirements' AS table_name,count(*) FROM public.student_requirements;
SELECT 'students' AS table_name,count(*) FROM public.students;
SELECT 'users' AS table_name,count(*) FROM public.users;
