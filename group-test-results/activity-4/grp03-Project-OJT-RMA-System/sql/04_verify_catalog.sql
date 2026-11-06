\pset pager off
SELECT current_database(), session_user, current_user, version();
\dt public.*
\ds public.*
\dv public.*
\df public.*
\dn+
\dp public.*
\ddp
SELECT rolname, rolcanlogin, rolsuper, rolcreatedb, rolcreaterole, rolreplication, rolbypassrls
FROM pg_roles WHERE rolname LIKE 'grp03%' ORDER BY rolname;
SELECT r.rolname AS member, g.rolname AS group_role, m.admin_option, m.inherit_option, m.set_option
FROM pg_auth_members m JOIN pg_roles r ON r.oid=m.member JOIN pg_roles g ON g.oid=m.roleid
WHERE r.rolname LIKE 'grp03%' ORDER BY r.rolname;
SELECT datname, has_database_privilege('grp03_ojt_app',oid,'CONNECT') app_connect,
has_database_privilege('grp03_ojt_auditor',oid,'CONNECT') auditor_connect,
has_database_privilege('grp03_ojt_dba',oid,'CONNECT') dba_connect
FROM pg_database WHERE datallowconn ORDER BY datname;
SELECT relname, relrowsecurity FROM pg_class WHERE relnamespace='public'::regnamespace AND relkind='r';
SELECT count(*) AS user_triggers FROM pg_trigger WHERE NOT tgisinternal;
SELECT (SELECT count(*) FROM users) users, (SELECT count(*) FROM students) students,
(SELECT count(*) FROM companies) companies, (SELECT count(*) FROM requirements) requirements,
(SELECT count(*) FROM ojt_applications) applications, (SELECT count(*) FROM ojt_placements) placements,
(SELECT count(*) FROM attendance) attendance, (SELECT count(*) FROM evaluations) evaluations,
(SELECT count(*) FROM student_requirements) submissions, (SELECT count(*) FROM audit_log) audit_log;
