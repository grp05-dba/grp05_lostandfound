\set ON_ERROR_STOP on
SELECT version(), current_date, current_setting('TimeZone');
SELECT session_user,current_user,current_database();
SELECT tablename,tableowner FROM pg_tables WHERE schemaname='public' ORDER BY tablename;
SELECT c.relname,c.relkind,pg_get_userbyid(c.relowner) AS owner,c.relacl FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' ORDER BY c.relkind,c.relname;
SELECT conname,contype,pg_get_constraintdef(oid) FROM pg_constraint WHERE connamespace='public'::regnamespace ORDER BY conname;
SELECT rolname,rolcanlogin,rolsuper,rolcreatedb,rolcreaterole,rolinherit,rolreplication,rolbypassrls FROM pg_roles WHERE rolname LIKE 'brewpos_%' ORDER BY rolname;
SELECT member.rolname AS login,parent.rolname AS group_role,m.admin_option,m.inherit_option,m.set_option FROM pg_auth_members m JOIN pg_roles member ON member.oid=m.member JOIN pg_roles parent ON parent.oid=m.roleid WHERE member.rolname LIKE 'brewpos_%';
SELECT datname,pg_get_userbyid(datdba) AS owner,datacl FROM pg_database ORDER BY datname;
SELECT nspname,pg_get_userbyid(nspowner) AS owner,nspacl FROM pg_namespace WHERE nspname='public';
SELECT grantee,table_name,privilege_type FROM information_schema.table_privileges WHERE table_schema='public' ORDER BY grantee,table_name,privilege_type;
SELECT defaclrole::regrole,defaclnamespace,defaclobjtype,defaclacl FROM pg_default_acl;
SELECT usename,datname,client_addr FROM pg_stat_activity WHERE usename LIKE 'brewpos_%';
SELECT (SELECT count(*) FROM staff) AS staff, (SELECT count(*) FROM menu_category) AS categories, (SELECT count(*) FROM menu_item) AS items, (SELECT count(*) FROM order_ticket) AS orders, (SELECT count(*) FROM order_line_item) AS lines;
SELECT t.order_timestamp::date AS sales_date,count(DISTINCT t.order_id) AS orders,SUM(l.quantity*l.sold_price) AS total FROM order_ticket t JOIN order_line_item l USING(order_id) GROUP BY t.order_timestamp::date ORDER BY sales_date;
SELECT to_regclass('public.e4_forbidden') IS NULL AND to_regclass('public.e4_ddl_probe') IS NULL AS probe_tables_absent;
SELECT count(*) AS forbidden_database_count FROM pg_database WHERE datname='e4_forbidden_database';
SELECT count(*) AS forbidden_role_count FROM pg_roles WHERE rolname='e4_forbidden_role';
