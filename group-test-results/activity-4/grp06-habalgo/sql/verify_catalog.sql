\set ON_ERROR_STOP on
SELECT version(),current_date,current_setting('TimeZone');
SELECT tablename,tableowner FROM pg_tables WHERE schemaname='habalgo' ORDER BY tablename;
SELECT c.relname,c.relkind,pg_get_userbyid(c.relowner) AS owner,c.relacl FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='habalgo' ORDER BY c.relkind,c.relname;
SELECT c.relkind,count(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='habalgo' GROUP BY c.relkind ORDER BY c.relkind;
SELECT conname,contype,pg_get_constraintdef(oid) FROM pg_constraint WHERE connamespace='habalgo'::regnamespace ORDER BY conname;
SELECT rolname,rolcanlogin,rolsuper,rolcreatedb,rolcreaterole,rolinherit,rolreplication,rolbypassrls FROM pg_roles WHERE rolname LIKE 'habalgo_%' ORDER BY rolname;
SELECT member.rolname AS login,parent.rolname AS group_role,m.admin_option,m.inherit_option,m.set_option FROM pg_auth_members m JOIN pg_roles member ON member.oid=m.member JOIN pg_roles parent ON parent.oid=m.roleid WHERE member.rolname LIKE 'habalgo_%';
SELECT datname,pg_get_userbyid(datdba) AS owner,datacl FROM pg_database ORDER BY datname;
SELECT nspname,pg_get_userbyid(nspowner) AS owner,nspacl FROM pg_namespace WHERE nspname IN ('public','habalgo');
SELECT grantee,table_name,privilege_type FROM information_schema.table_privileges WHERE table_schema='habalgo' ORDER BY grantee,table_name,privilege_type;
SELECT defaclrole::regrole,defaclnamespace,defaclobjtype,defaclacl FROM pg_default_acl;
SELECT (SELECT count(*) FROM habalgo.customer) AS customer, (SELECT count(*) FROM habalgo.driver) AS driver, (SELECT count(*) FROM habalgo.vehicle) AS vehicle, (SELECT count(*) FROM habalgo.driver_vehicle) AS driver_vehicle, (SELECT count(*) FROM habalgo.location) AS location, (SELECT count(*) FROM habalgo.booking) AS booking, (SELECT count(*) FROM habalgo.payment) AS payment, (SELECT count(*) FROM habalgo.rating_feedback) AS rating_feedback;
SELECT to_regclass('habalgo.e4_forbidden') IS NULL AND to_regclass('habalgo.e4_ddl_probe') IS NULL AS probe_tables_absent;
SELECT count(*) AS forbidden_database_count FROM pg_database WHERE datname='habalgo_e4_forbidden';
SELECT count(*) AS forbidden_role_count FROM pg_roles WHERE rolname='habalgo_e4_forbidden';
SELECT count(*) AS leftover_probe_customers FROM habalgo.customer WHERE email LIKE '%@example.invalid';
SELECT count(*) AS leftover_probe_drivers FROM habalgo.driver WHERE license_no LIKE 'E4%';
