\set ON_ERROR_STOP on
SELECT version(),current_date,current_setting('TimeZone');
SELECT tablename,tableowner FROM pg_tables WHERE schemaname='public' ORDER BY tablename;
SELECT c.relname,c.relkind,pg_get_userbyid(c.relowner) AS owner,c.relacl FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' ORDER BY c.relkind,c.relname;
SELECT c.relkind,count(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' GROUP BY c.relkind ORDER BY c.relkind;
SELECT conname,contype,pg_get_constraintdef(oid) FROM pg_constraint WHERE connamespace='public'::regnamespace ORDER BY conname;
SELECT rolname,rolcanlogin,rolsuper,rolcreatedb,rolcreaterole,rolinherit,rolreplication,rolbypassrls FROM pg_roles WHERE rolname LIKE 'campussafe_%' ORDER BY rolname;
SELECT member.rolname AS login,parent.rolname AS group_role,m.admin_option,m.inherit_option,m.set_option FROM pg_auth_members m JOIN pg_roles member ON member.oid=m.member JOIN pg_roles parent ON parent.oid=m.roleid WHERE member.rolname LIKE 'campussafe_%';
SELECT datname,pg_get_userbyid(datdba) AS owner,datacl FROM pg_database ORDER BY datname;
SELECT nspname,pg_get_userbyid(nspowner) AS owner,nspacl FROM pg_namespace WHERE nspname='public';
SELECT grantee,table_name,privilege_type FROM information_schema.table_privileges WHERE table_schema='public' ORDER BY grantee,table_name,privilege_type;
SELECT defaclrole::regrole,defaclnamespace,defaclobjtype,defaclacl FROM pg_default_acl;
SELECT (SELECT count(*) FROM public.role) AS role, (SELECT count(*) FROM public.app_user) AS app_user, (SELECT count(*) FROM public.hazard_category) AS hazard_category, (SELECT count(*) FROM public.campus_location) AS campus_location, (SELECT count(*) FROM public.hazard_report) AS hazard_report, (SELECT count(*) FROM public.assignment) AS assignment, (SELECT count(*) FROM public.report_status_history) AS report_status_history, (SELECT count(*) FROM public.maintenance_action) AS maintenance_action, (SELECT count(*) FROM public.attachment) AS attachment;
SELECT status,count(*) FROM hazard_report GROUP BY status ORDER BY status;
SELECT to_regclass('public.e4_forbidden') IS NULL AND to_regclass('public.e4_ddl_probe') IS NULL AS probes_absent;
SELECT count(*) AS forbidden_database_count FROM pg_database WHERE datname='campussafe_e4_forbidden';
SELECT count(*) AS forbidden_role_count FROM pg_roles WHERE rolname='campussafe_e4_forbidden';
SELECT count(*) AS leftover_users FROM app_user WHERE username='e4_test_user';
