\set ON_ERROR_STOP on
DO $$ BEGIN IF current_setting('port')<>'55407' OR current_database() NOT IN('grp07_campussafedb','g05_a6_g07_restore','g05_a6_g07_snapshot','g05_a6_g07_recovered') THEN RAISE EXCEPTION 'Wrong Activity6 verification environment'; END IF; END $$;
SET ROLE campussafe_owner_grp;
SELECT 'app_user' AS table_name,count(*) FROM public.app_user;
SELECT 'assignment' AS table_name,count(*) FROM public.assignment;
SELECT 'attachment' AS table_name,count(*) FROM public.attachment;
SELECT 'campus_location' AS table_name,count(*) FROM public.campus_location;
SELECT 'hazard_category' AS table_name,count(*) FROM public.hazard_category;
SELECT 'hazard_report' AS table_name,count(*) FROM public.hazard_report;
SELECT 'maintenance_action' AS table_name,count(*) FROM public.maintenance_action;
SELECT 'report_status_history' AS table_name,count(*) FROM public.report_status_history;
SELECT 'role' AS table_name,count(*) FROM public.role;
