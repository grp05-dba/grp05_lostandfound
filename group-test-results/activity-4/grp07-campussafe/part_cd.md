# Parts C and D - Roles, Privileges, and Least Privilege

## 1. Implementation scope

Executed on 6 November 2026 using PostgreSQL 18.6 in the owned evaluation cluster, port 55432. These scripts implement [the role plan](part_b.md); [setup output](evidence/setup.txt) and [catalog inspection](evidence/catalog.txt) provide actual evidence. The system service on port 5432 and the owning repository's tracked files were not modified.

Scripts intentionally target a fresh setup and stop on conflicting names. They do not drop/replace an existing database. The upstream schema and seed are destructive, so their execution was gated on a newly created empty project database. They are not rerunnable migrations for populated installations.

## 2. Part C - Create groups, login roles and database access

Run [01_roles_database.sql](sql/01_roles_database.sql) as the provisioning administrator connected to an administrative database:

```sql
\set ON_ERROR_STOP on
-- Fresh evaluation setup. Connect as provisioning administrator to postgres.
CREATE ROLE campussafe_owner_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE campussafe_runtime_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE campussafe_readonly_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE campussafe_backup_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE campussafe_app LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE campussafe_report LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE campussafe_backup LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE campussafe_dba LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
GRANT campussafe_runtime_grp TO campussafe_app;
GRANT campussafe_readonly_grp TO campussafe_report;
GRANT campussafe_backup_grp TO campussafe_backup;
GRANT campussafe_owner_grp TO campussafe_dba;
CREATE DATABASE grp07_campussafedb OWNER campussafe_owner_grp;
CREATE DATABASE campussafe_unrelateddb;
REVOKE ALL ON DATABASE grp07_campussafedb FROM PUBLIC;
REVOKE ALL ON DATABASE campussafe_unrelateddb FROM PUBLIC;
GRANT CONNECT ON DATABASE grp07_campussafedb TO campussafe_runtime_grp, campussafe_readonly_grp, campussafe_backup_grp;
-- Assign distinct private passwords locally after creation, never in this script.
```

Assign distinct private local passwords. Manual reproduction can use psql prompts:

```text
\password campussafe_app
\password campussafe_report
\password campussafe_backup
\password campussafe_dba
```

The executed setup generated random passwords and used private process configuration to authenticate. No password assignment was echoed to the submitted evidence. The scratch .env and credential files are not in the deliverable bundle.

As provisioning administrator in the new `grp07_campussafedb`, execute `SET ROLE campussafe_owner_grp`, set search_path to public, and import upstream `database/01_schema.sql` and `database/02_seed.sql`. Reset the role afterwards. Tables/sequences belong to the NOLOGIN owner group; runtime accounts do not own them. Schema/seed source fingerprints and command tags are recorded without echoing seed passwords or hashes.

## 3. Part C - Apply schema, table and sequence permissions

Run [02_privileges.sql](sql/02_privileges.sql) in the target database:

```sql
\set ON_ERROR_STOP on
-- Target grp07_campussafedb; schema and seed have been loaded as the owner group.
ALTER SCHEMA public OWNER TO campussafe_owner_grp;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO campussafe_runtime_grp, campussafe_readonly_grp, campussafe_backup_grp;
GRANT SELECT ON public.role, public.app_user, public.hazard_category,
    public.campus_location, public.hazard_report, public.assignment,
    public.report_status_history, public.maintenance_action, public.attachment
    TO campussafe_runtime_grp, campussafe_backup_grp;
GRANT INSERT ON public.app_user, public.hazard_category, public.campus_location,
    public.hazard_report, public.assignment, public.report_status_history,
    public.maintenance_action, public.attachment TO campussafe_runtime_grp;
GRANT UPDATE ON public.app_user, public.hazard_category, public.campus_location,
    public.hazard_report, public.assignment TO campussafe_runtime_grp;
GRANT DELETE ON public.attachment TO campussafe_runtime_grp;
GRANT USAGE ON SEQUENCE public.app_user_user_id_seq,
    public.hazard_category_category_id_seq, public.campus_location_location_id_seq,
    public.hazard_report_report_id_seq, public.assignment_assignment_id_seq,
    public.report_status_history_history_id_seq, public.maintenance_action_action_id_seq,
    public.attachment_attachment_id_seq TO campussafe_runtime_grp;
-- Auditor may inspect the role dictionary and operational records, not app_user.
GRANT SELECT ON public.role, public.hazard_category, public.campus_location,
    public.hazard_report, public.assignment, public.report_status_history,
    public.maintenance_action, public.attachment TO campussafe_readonly_grp;
-- Backup operator can read sequence states but cannot nextval/setval.
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO campussafe_backup_grp;
ALTER DEFAULT PRIVILEGES FOR ROLE campussafe_owner_grp IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE campussafe_owner_grp IN SCHEMA public REVOKE ALL ON SEQUENCES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE campussafe_owner_grp REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
-- New objects require reviewed grants, including for the backup operator.
ALTER ROLE campussafe_app IN DATABASE grp07_campussafedb SET search_path = public;
ALTER ROLE campussafe_app IN DATABASE grp07_campussafedb SET statement_timeout = '30s';
ALTER ROLE campussafe_app IN DATABASE grp07_campussafedb SET lock_timeout = '10s';
```

The SQL auditor receives no app_user grant, while the backup role deliberately receives full current-data reads. Runtime history/action logs are INSERT-only; role definitions are read-only. Assignment DELETE and blanket sequence SELECT from the upstream script are omitted because current feature code does not require them.

## 4. Part D - Unrelated-database isolation

The project database and unrelated test database are closed to PUBLIC. Other databases require their own ACL review. [03_lab_isolation.sql](sql/03_lab_isolation.sql) was applied only in the owned local test cluster:

```sql
\set ON_ERROR_STOP on
-- ONLY for this owned, isolated evaluation cluster. Preserve existing project grants.
-- Review legitimate users before adapting any PUBLIC revokes to a shared server.
REVOKE CONNECT, TEMPORARY ON DATABASE postgres FROM PUBLIC;
REVOKE CONNECT, TEMPORARY ON DATABASE template1 FROM PUBLIC;
REVOKE CONNECT, TEMPORARY ON DATABASE grp_brewposdb FROM PUBLIC;
REVOKE CONNECT, TEMPORARY ON DATABASE brewpos_unrelateddb FROM PUBLIC;
REVOKE CONNECT, TEMPORARY ON DATABASE grp00_habalgodb FROM PUBLIC;
REVOKE CONNECT, TEMPORARY ON DATABASE habalgo_unrelateddb FROM PUBLIC;
```

Prior explicit Group 4/6 grants remain intact. Actual tests confirmed denied connections in both directions and preserved own-project runtime access. On a shared server, first inspect legitimate users and preserve their explicit grants; do not run these PUBLIC revokes indiscriminately. PostgreSQL has no per-login DENY that overrides another remaining PUBLIC grant.

## 5. Part D - Least-privilege review

| Requirement | Applied control / actual verification |
|---|---|
| Ordinary app does not use superuser | Local .env selects campussafe_app; PDO diagnostic confirms session/current user |
| Real group and login separation | Four NOLOGIN groups, four LOGIN accounts, one intended membership each, no ADMIN OPTION |
| No unnecessary cluster attributes | All eight roles lack superuser/database creation/role creation/replication/BYPASSRLS; CREATE DATABASE/ROLE attempts denied for each login |
| Runtime follows current model operations | Exact table matrix; report/user/master-data deletes and audit-log updates/deletes denied |
| Auditor cannot modify data or read hashes | INSERT/UPDATE/DELETE denied on every table; app_user and password_hash SELECT denied |
| Backup read access is separate | Full current-data dump succeeds, while all writes, nextval and setval are denied |
| DDL and sequence scope limited | No runtime role-ID generation or setval; no service/inspection schema CREATE; owner role inaccessible to non-DBA logins |
| PUBLIC/ownership/inheritance reviewed | Database/schema/table/sequence ACLs, owner and membership catalogs captured |
| Unrelated databases restricted | All four logins denied connections to seven unrelated/administrative databases |
| Future objects require approval | New owner-created table/function inaccessible to runtime/auditor/backup until explicit review; DBA access succeeds |

The DBA has actual project-owner membership, not merely ALL PRIVILEGES on existing tables. It can change project DDL/grants and is trusted for approved maintenance, but cannot create databases/roles. Ordinary traffic must not use this account.

Future-object defaults are creator-specific. Migrations should SET ROLE to campussafe_owner_grp. Creating objects as a different login requires that creator's defaults to be reviewed. No automatic future UPDATE grant is applied to runtime, preserving intentional append-only distinctions.

## 6. Reproduce tests and inspect evidence

From this report directory with PostgreSQL bin on PATH:

```powershell
psql -X -W -h 127.0.0.1 -p 55432 -U campussafe_app -d grp07_campussafedb -f sql/verify_campussafe_app.sql
psql -X -W -h 127.0.0.1 -p 55432 -U campussafe_report -d grp07_campussafedb -f sql/verify_campussafe_report.sql
psql -X -W -h 127.0.0.1 -p 55432 -U campussafe_backup -d grp07_campussafedb -f sql/verify_campussafe_backup.sql
psql -X -W -h 127.0.0.1 -p 55432 -U campussafe_dba -d grp07_campussafedb -f sql/verify_campussafe_dba.sql
psql -X -W -h 127.0.0.1 -p 55432 -U postgres -d grp07_campussafedb -f sql/verify_catalog.sql
```

The submitted SQL scripts continue after expected denials. Their final process status is not a substitute for checking individual statements. The automated executed main checks used one direct connection per case with ON_ERROR_STOP and matched exit status plus actual error text. Successful probes roll back; failed transaction connections close without committing.

Isolation checks use separate connections to each target, for example:

```powershell
psql -X -W -h 127.0.0.1 -p 55432 -U campussafe_report -d grp00_habalgodb -c 'SELECT current_database();'
```

The evaluated result is an explicit lack-of-CONNECT failure. [results.json](evidence/results.json) stores full main-case SQL, login, database, expectation, exit code and status. The report [part_d.md](part_d.md) maps the evidence and records remaining web failures separately.

## 7. Security scope

These grants successfully constrain the database runtime, SQL auditor, backup and DBA as designed. All human web sessions still use the runtime connection. The Auditor submission, unassigned-technician start-work and unauthenticated attachment findings require application authorization fixes. No owning-group code was patched, and those findings are not represented as fixed by PostgreSQL role creation.
