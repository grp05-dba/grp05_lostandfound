\set ON_ERROR_STOP on
SELECT clock_timestamp() AS captured_at, version(), current_database(), session_user, current_user;
SELECT rolname,rolcanlogin,rolinherit,rolsuper,rolcreatedb,rolcreaterole,rolreplication,rolbypassrls
FROM pg_roles WHERE rolname LIKE 'parkit_%' ORDER BY rolname;
SELECT parent.rolname AS group_role,child.rolname AS login,m.admin_option,m.inherit_option,m.set_option
FROM pg_auth_members m JOIN pg_roles parent ON parent.oid=m.roleid
JOIN pg_roles child ON child.oid=m.member WHERE child.rolname LIKE 'parkit_%' ORDER BY child.rolname;
SELECT datname,pg_get_userbyid(datdba) AS owner,datacl FROM pg_database ORDER BY datname;
SELECT nspname,pg_get_userbyid(nspowner) AS owner,nspacl FROM pg_namespace WHERE nspname='public';
SELECT c.relname,c.relkind,pg_get_userbyid(c.relowner) AS owner,c.relacl
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' ORDER BY c.relkind,c.relname;
SELECT table_name,column_name,privilege_type,grantee FROM information_schema.column_privileges
WHERE table_schema='public' AND grantee IN ('parkit_runtime_grp','parkit_readonly_grp')
ORDER BY table_name,grantee,privilege_type,column_name;
SELECT conrelid::regclass AS table_name,conname,contype,pg_get_constraintdef(oid) AS definition
FROM pg_constraint WHERE connamespace='public'::regnamespace ORDER BY conrelid::regclass::text,conname;
SELECT table_name,column_name,column_default,is_nullable FROM information_schema.columns
WHERE table_schema='public' ORDER BY table_name,ordinal_position;
SELECT schemaname,indexname,indexdef FROM pg_indexes WHERE schemaname='public' ORDER BY indexname;
SELECT defaclrole::regrole,defaclnamespace::regnamespace,defaclobjtype,defaclacl FROM pg_default_acl ORDER BY 1,2,3;
SELECT 'parking_zone' AS table_name,count(*) FROM public.parking_zone UNION ALL
SELECT 'staff_user',count(*) FROM public.staff_user UNION ALL SELECT 'vehicle',count(*) FROM public.vehicle UNION ALL
SELECT 'transaction',count(*) FROM public."transaction" UNION ALL SELECT 'payment',count(*) FROM public.payment;
SELECT zone_id,zone_name,max_capacity,current_active_count FROM public.parking_zone;
SELECT user_id,username,role FROM public.staff_user;
SELECT count(*) AS application_functions FROM pg_proc WHERE pronamespace='public'::regnamespace;
SELECT count(*) AS application_triggers FROM pg_trigger WHERE tgrelid IN
(SELECT oid FROM pg_class WHERE relnamespace='public'::regnamespace) AND NOT tgisinternal;
