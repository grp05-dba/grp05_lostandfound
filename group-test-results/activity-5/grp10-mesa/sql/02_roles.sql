\set ON_ERROR_STOP on
DO $$ BEGIN IF current_database()<>'mesa_g05_activity4' OR current_setting('port')<>'55410' THEN RAISE EXCEPTION 'Wrong Activity 5 test database'; END IF; END $$;
SET ROLE rors_owner_grp;
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database(),current_setting('server_version'),inet_server_addr(),inet_server_port();
SELECT json_build_object(
 'roles',(SELECT json_agg(row_to_json(r)) FROM (SELECT rolname,rolcanlogin,rolsuper,rolcreatedb,rolcreaterole,rolreplication,rolbypassrls,rolinherit FROM pg_roles WHERE rolname LIKE 'rors_%' ORDER BY rolname) r),
 'memberships',(SELECT json_agg(row_to_json(r)) FROM (SELECT a.rolname AS member,b.rolname AS parent,m.admin_option,m.inherit_option,m.set_option FROM pg_auth_members m JOIN pg_roles a ON a.oid=m.member JOIN pg_roles b ON b.oid=m.roleid WHERE a.rolname LIKE 'rors_%' ORDER BY 1,2) r),
 'objects',(SELECT json_agg(row_to_json(r)) FROM (SELECT c.relname,c.relkind,pg_get_userbyid(c.relowner) AS owner,c.relacl::text FROM pg_class c WHERE c.relnamespace='public'::regnamespace AND c.relkind IN('r','S','v') ORDER BY 1) r),
 'defaults',(SELECT json_agg(row_to_json(r)) FROM (SELECT defaclrole::regrole::text,defaclnamespace,defaclobjtype,defaclacl::text FROM pg_default_acl ORDER BY defaclrole,defaclnamespace,defaclobjtype) r),
 'schema',(SELECT nspacl::text FROM pg_namespace WHERE nspname='public'),
 'database_acl',(SELECT datacl::text FROM pg_database WHERE datname=current_database()),
 'owner_can_maintain',has_table_privilege(current_user,'public.menu_item','MAINTAIN'),
 'runtime_can_maintain',has_table_privilege('rors_app','public.menu_item','MAINTAIN')
);
