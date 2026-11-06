# Parts C and D - Roles, Privileges, and Least Privilege

## 1. Implementation scope

The following scripts implement [the Group 6 access plan](part_b.md) and were executed on 6 November 2026 with PostgreSQL 18.6. [Setup output](evidence/setup.txt) and [catalog evidence](evidence/catalog.txt) record actual creation results, ownership, memberships and ACLs.

These are fresh-setup scripts: they stop on name conflicts and do not drop or overwrite an existing database. Roles are cluster-wide. The isolated evaluation cluster is on port 55432; the system service on port 5432 is unchanged. Never copy lab-wide CONNECT revokes blindly to a shared/production server.

The upstream role script was reviewed but **not executed**. It includes fixed password literals, generic role names and broader present/future grants than the actual API needs. Those passwords are not reproduced or reused in this evaluation.

## 2. Part C - Groups, logins and database privileges

Run [01_roles_database.sql](sql/01_roles_database.sql) as an authorized provisioning administrator connected to the administrative `postgres` database:

```sql
\set ON_ERROR_STOP on
-- Fresh project setup in the isolated evaluation cluster; connect to postgres.
CREATE ROLE habalgo_owner_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE habalgo_runtime_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE habalgo_readonly_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE habalgo_app LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE habalgo_auditor LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE habalgo_dba LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
GRANT habalgo_runtime_grp TO habalgo_app;
GRANT habalgo_readonly_grp TO habalgo_auditor;
GRANT habalgo_owner_grp TO habalgo_dba;
CREATE DATABASE grp00_habalgodb OWNER habalgo_owner_grp;
CREATE DATABASE habalgo_unrelateddb;
REVOKE ALL ON DATABASE grp00_habalgodb FROM PUBLIC;
REVOKE ALL ON DATABASE habalgo_unrelateddb FROM PUBLIC;
GRANT CONNECT ON DATABASE grp00_habalgodb TO habalgo_runtime_grp, habalgo_readonly_grp;
-- Set distinct private passwords locally; no passwords are stored in this script.
-- Other databases require their own CONNECT review; see 03_lab_isolation.sql.
```

Set each password locally. Manual reproduction can use psql's prompts, rather than storing credentials in SQL:

```text
\password habalgo_app
\password habalgo_auditor
\password habalgo_dba
```

The executed setup used independently generated random passwords stored only in local scratch configuration outside the submitted folder. Credentials were supplied privately to each psql process; password assignment was not echoed into evidence.

Connect to `grp00_habalgodb`, execute `SET ROLE habalgo_owner_grp`, and import the upstream root `schema.sql` and `sample data.sql`. The schema, eight tables, seven sequences and indexes are therefore owned by the NOLOGIN owner group rather than the runtime login. Reset to the provisioning administrator before applying grants.

## 3. Part C - Schema, table and sequence privileges

Run [02_privileges.sql](sql/02_privileges.sql) while connected to `grp00_habalgodb`:

```sql
\set ON_ERROR_STOP on
-- Run as provisioning administrator in grp00_habalgodb after importing upstream
-- schema.sql and "sample data.sql" with SET ROLE habalgo_owner_grp.
ALTER SCHEMA habalgo OWNER TO habalgo_owner_grp;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA habalgo FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA habalgo FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA habalgo FROM PUBLIC;
GRANT USAGE ON SCHEMA habalgo TO habalgo_runtime_grp, habalgo_readonly_grp;
GRANT SELECT ON habalgo.customer, habalgo.driver, habalgo.vehicle,
    habalgo.driver_vehicle, habalgo.location, habalgo.booking,
    habalgo.payment, habalgo.rating_feedback
    TO habalgo_runtime_grp, habalgo_readonly_grp;
GRANT INSERT, UPDATE, DELETE ON habalgo.customer, habalgo.vehicle,
    habalgo.driver_vehicle, habalgo.booking, habalgo.payment, habalgo.rating_feedback
    TO habalgo_runtime_grp;
GRANT INSERT ON habalgo.location TO habalgo_runtime_grp;
GRANT USAGE ON SEQUENCE habalgo.customer_customer_id_seq,
    habalgo.vehicle_vehicle_id_seq, habalgo.location_location_id_seq,
    habalgo.booking_booking_id_seq, habalgo.payment_payment_id_seq,
    habalgo.rating_feedback_rating_id_seq TO habalgo_runtime_grp;
ALTER DEFAULT PRIVILEGES FOR ROLE habalgo_owner_grp IN SCHEMA habalgo REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE habalgo_owner_grp IN SCHEMA habalgo REVOKE ALL ON SEQUENCES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE habalgo_owner_grp REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER ROLE habalgo_app IN DATABASE grp00_habalgodb SET search_path = habalgo;
ALTER ROLE habalgo_app IN DATABASE grp00_habalgodb SET statement_timeout = '30s';
ALTER ROLE habalgo_app IN DATABASE grp00_habalgodb SET lock_timeout = '10s';
```

The runtime has SELECT on all eight tables, CRUD on six of them, INSERT-only writes to location, and no driver writes. No sequence privilege is granted for driver IDs. The auditor has SELECT only; the DBA obtains project administration through its owner-group membership.

## 4. Part D - Unrelated-database isolation

The project scripts revoke PUBLIC access on the two newly created HabalGo databases. Isolation from other databases also depends on those databases' ACLs. The following [lab-only script](sql/03_lab_isolation.sql) was applied to the existing, owned evaluation environment:

```sql
\set ON_ERROR_STOP on
-- ISOLATED LAB ONLY: all databases below belong to this evaluation environment.
-- Do not blindly apply PUBLIC revokes to a shared/production cluster.
-- Preserve any legitimate users' explicit grants before adapting these commands.
REVOKE CONNECT, TEMPORARY ON DATABASE postgres FROM PUBLIC;
REVOKE CONNECT, TEMPORARY ON DATABASE template1 FROM PUBLIC;
REVOKE CONNECT, TEMPORARY ON DATABASE grp_brewposdb FROM PUBLIC;
REVOKE CONNECT, TEMPORARY ON DATABASE brewpos_unrelateddb FROM PUBLIC;
-- The existing Group 4 explicit grants/ownership remain intact.
```

The pre-existing Group 4 role grants were preserved. The Group 6 logins were denied access to Group 4's database; Group 4's three logins were denied access to HabalGo; and Group 4's application login still connected to its own database. See [cross-project evidence](evidence/cross_project_isolation.txt) and the main verification matrix.

On a real shared server, inspect legitimate users, inherited roles, owners and PUBLIC grants and preserve required explicit access before adapting any revoke. PostgreSQL has no explicit DENY that overrides a remaining PUBLIC CONNECT grant.

## 5. Part D - Least-privilege review

| Requirement | Applied control and verification |
|---|---|
| Non-superuser ordinary runtime | PHP process uses `habalgo_app`; identical-environment PDO diagnostic confirms its identity |
| Appropriate login/group roles | Three NOLOGIN groups and three LOGIN accounts; only intended memberships, no ADMIN OPTION |
| Unrelated databases restricted | Actual denied connections for all three HabalGo logins to five unrelated/administrative databases |
| Writes limited to current responsibilities | Driver writes and location UPDATE/DELETE denied; allowed CRUD/assignment/booking operations tested on real probe records |
| Read-only account cannot write | INSERT/UPDATE/DELETE denied on every one of eight tables |
| No unnecessary elevated attributes | All six project roles lack superuser, database/role creation, replication and RLS-bypass attributes; CREATE DATABASE/ROLE denied for each login |
| Schema and DDL restricted | Runtime cannot create project/public tables, schemas, temporary tables or alter existing tables; auditor cannot create tables |
| Sequence scope limited | Runtime uses six required sequences; driver sequence and `setval` denied; auditor sequence access denied |
| PUBLIC/inherited access inspected | Database/schema/table/sequence ACLs, role memberships and owner catalog checked |
| Future objects reviewed | New owner-created table/function denied to app and auditor; DBA owner access works; probes removed |

Owner default privileges intentionally do not automatically expose future tables/sequences. Future function PUBLIC EXECUTE is explicitly removed globally for `habalgo_owner_grp`. These settings are creator-specific: migrations must use `SET ROLE habalgo_owner_grp`, and objects created as a different role require their own default-privilege review.

The DBA remains trusted within the project and can change project grants/objects. It is not a cluster administrator and is unsuitable for ordinary traffic. Database-level ALL PRIVILEGES does not by itself confer role creation, database creation or object ownership; actual owner membership is used here.

## 6. Reproduce verification

From this report folder, with PostgreSQL's `bin` on PATH, the following commands prompt privately for the relevant passwords:

```powershell
psql -X -W -h 127.0.0.1 -p 55432 -U habalgo_app -d grp00_habalgodb -f sql/verify_habalgo_app.sql
psql -X -W -h 127.0.0.1 -p 55432 -U habalgo_auditor -d grp00_habalgodb -f sql/verify_habalgo_auditor.sql
psql -X -W -h 127.0.0.1 -p 55432 -U habalgo_dba -d grp00_habalgodb -f sql/verify_habalgo_dba.sql
psql -X -W -h 127.0.0.1 -p 55432 -U postgres -d grp00_habalgodb -f sql/verify_catalog.sql
```

Expected denial statements deliberately continue in the submitted account scripts. Their overall process exit code is not a pass/fail verdict. The automated executed checks opened a separate direct account connection per case, used ON_ERROR_STOP, and matched actual exit status plus the required permission-error text. Successful probes use rollback; failed transactions close without committing.

To reproduce isolation, use a separate psql connection naming each target database. For example:

```powershell
psql -X -W -h 127.0.0.1 -p 55432 -U habalgo_app -d grp_brewposdb -c 'SELECT current_database();'
```

The expected result is a denied connection stating that the account lacks CONNECT. Repeat for the login/database combinations in [Part D's verification matrix](part_d.md). [results.json](evidence/results.json) preserves every main test statement, account, target database, expectation, exit code and result.

## 7. Remaining boundaries

These privileges support current application behavior, including payment/booking/feedback edits and deletions. They do not supply per-human authentication or an append-only accounting design. Direct SQL tests also proved missing assignment and feedback consistency rules. Recommended owner fixes and their evidence are in the verification report. No additional schema constraint or authentication feature was invented or patched into the owning group's source.
