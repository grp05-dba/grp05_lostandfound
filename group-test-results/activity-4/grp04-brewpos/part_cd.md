# Parts C and D - Roles, Privileges, and Least Privilege

## 1. Implementation scope

The following scripts were executed in the isolated PostgreSQL 18.6 cluster on 6 November 2026. They implement [the access-control plan](part_b.md). [Actual setup output](evidence/setup.txt) and [catalog verification](evidence/catalog.txt) accompany the scripts. The owning BrewPOS repository was not modified.

These scripts target a **fresh lab** and intentionally fail on conflicting existing role/database names. They do not DROP/replace an existing database. PostgreSQL roles are cluster-wide; inspect conflicts before adapting them to a shared instance.

## 2. Part C - Roles, accounts and database access

Connect as an authorized provisioning administrator to the administrative `postgres` database:

```sql
\set ON_ERROR_STOP on
-- Fresh dedicated lab only. Connect as provisioning administrator to postgres.
CREATE ROLE brewpos_owner_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE brewpos_runtime_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE brewpos_readonly_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE brewpos_app LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE brewpos_auditor LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE brewpos_dba LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
GRANT brewpos_runtime_grp TO brewpos_app;
GRANT brewpos_readonly_grp TO brewpos_auditor;
GRANT brewpos_owner_grp TO brewpos_dba;
CREATE DATABASE grp_brewposdb OWNER brewpos_owner_grp;
CREATE DATABASE brewpos_unrelateddb;
REVOKE ALL ON DATABASE grp_brewposdb FROM PUBLIC;
REVOKE ALL ON DATABASE brewpos_unrelateddb FROM PUBLIC;
-- These two revokes are appropriate ONLY in this newly provisioned isolated lab.
-- On a shared server, assess legitimate users and preserve their grants first.
REVOKE CONNECT, TEMPORARY ON DATABASE postgres FROM PUBLIC;
REVOKE CONNECT, TEMPORARY ON DATABASE template1 FROM PUBLIC;
GRANT CONNECT ON DATABASE grp_brewposdb TO brewpos_runtime_grp, brewpos_readonly_grp;
-- Passwords are assigned locally after creation, never stored in these scripts.
```

Set passwords locally before logging in with the three accounts. For manual reproduction, use psql's interactive commands, supplying distinct private passwords:

```text
\password brewpos_app
\password brewpos_auditor
\password brewpos_dba
```

No actual passwords are included in the submitted scripts. The executed automated setup generated random local credentials, assigned them without SQL echo, and used environment-based credentials for psql processes. The local credential file and ignored scratch `.env` are outside the submitted project folder. They are not copied into the deliverable bundle.

Before granting object access, connect to `grp_brewposdb`, execute `SET ROLE brewpos_owner_grp`, then execute the upstream `database/schema.sql` and `database/seed.sql`. Use `RESET ROLE` afterwards. This creates tables and sequences under the designated owner group instead of the runtime login.

## 3. Part C - Schema, object and sequence privileges

Execute [02_privileges.sql](sql/02_privileges.sql) as the provisioning administrator while connected to `grp_brewposdb`:

```sql
\set ON_ERROR_STOP on
-- Connect as provisioning administrator to grp_brewposdb after importing
-- upstream schema.sql and seed.sql with SET ROLE brewpos_owner_grp.
ALTER SCHEMA public OWNER TO brewpos_owner_grp;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO brewpos_runtime_grp, brewpos_readonly_grp;
GRANT SELECT ON public.staff, public.menu_category, public.menu_item,
    public.order_ticket, public.order_line_item TO brewpos_runtime_grp, brewpos_readonly_grp;
GRANT INSERT, UPDATE, DELETE ON public.menu_category TO brewpos_runtime_grp;
GRANT INSERT, UPDATE ON public.menu_item TO brewpos_runtime_grp;
GRANT INSERT ON public.order_ticket, public.order_line_item TO brewpos_runtime_grp;
GRANT USAGE ON SEQUENCE public.menu_category_category_id_seq,
    public.menu_item_item_id_seq, public.order_ticket_order_id_seq TO brewpos_runtime_grp;
-- No runtime access to staff_staff_id_seq or setval; no auditor sequence grants.
ALTER DEFAULT PRIVILEGES FOR ROLE brewpos_owner_grp IN SCHEMA public
    REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE brewpos_owner_grp IN SCHEMA public
    REVOKE ALL ON SEQUENCES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE brewpos_owner_grp
    REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
-- Future tables/sequences require explicit reviewed grants; no blanket runtime grants.
ALTER ROLE brewpos_app IN DATABASE grp_brewposdb SET search_path = public;
ALTER ROLE brewpos_app IN DATABASE grp_brewposdb SET statement_timeout = '30s';
ALTER ROLE brewpos_app IN DATABASE grp_brewposdb SET lock_timeout = '10s';
```

Only the owner group controls project DDL; runtime and auditor do not own tables or inherit the owner group. `brewpos_dba` can explicitly use the owner group for migrations, so future-object policy remains tied to a known creator.

## 4. Part D - Least-privilege review

| Requirement | Implementation and verification |
|---|---|
| Non-superuser ordinary application access | Scratch `.env` selects `brewpos_app`; account and group attributes verified in the catalog |
| Separate login/group roles | Three NOLOGIN groups, three LOGIN accounts; one intended membership each, no ADMIN OPTION |
| Restrict unrelated database access | PUBLIC CONNECT removed on isolated-lab databases; all three project logins actually denied connections to `brewpos_unrelateddb`, `postgres` and `template1` |
| Restrict writes by responsibility | Runtime cannot write staff, DELETE menu items, UPDATE/DELETE sales records, TRUNCATE tables or perform DDL; actual denials recorded |
| Read-only inspection | Auditor SELECT succeeds; INSERT/UPDATE/DELETE on each of five tables is denied |
| No unnecessary cluster attributes | All project roles lack SUPERUSER, CREATEDB, CREATEROLE, REPLICATION and BYPASSRLS; CREATE DATABASE/ROLE attempts denied for all logins |
| Minimum sequence access | Only three runtime USAGE grants; staff sequence access and `setval` denied; auditor sequence access denied |
| PUBLIC and inheritance review | Database/schema/table/sequence ACLs and membership checked in catalog output |
| Future objects | No blanket future table/sequence grants; owner-created future table reads and function execution denied to app/auditor in separate tests |

Database `ALL PRIVILEGES` is not a substitute for ownership or cluster role attributes. The DBA's project authority comes from the NOLOGIN owner group, while database and role provisioning remain outside its remit. DBA ownership is intentionally powerful and is unsuitable for ordinary application traffic.

The PUBLIC revokes on `postgres` and `template1` are lab-specific. They must not be run indiscriminately on a shared server. Legitimate existing users need explicit access preserved first; there is no per-role DENY that overrides an inherited PUBLIC grant.

## 5. Reproduction and evidence

Use the installed PostgreSQL `bin` directory or put it on PATH. These commands prompt for passwords instead of embedding secrets:

```powershell
psql -X -W -h 127.0.0.1 -p 55432 -U brewpos_app -d grp_brewposdb -f sql/verify_brewpos_app.sql
psql -X -W -h 127.0.0.1 -p 55432 -U brewpos_auditor -d grp_brewposdb -f sql/verify_brewpos_auditor.sql
psql -X -W -h 127.0.0.1 -p 55432 -U brewpos_dba -d grp_brewposdb -f sql/verify_brewpos_dba.sql
psql -X -W -h 127.0.0.1 -p 55432 -U postgres -d grp_brewposdb -f sql/verify_catalog.sql
```

The submitted account scripts deliberately continue after expected permission errors and contain rollback boundaries. Their exit status alone is not a pass/fail verdict. The executed automated checks used a separate direct connection for each case, stopped on the first statement error, and compared the actual exit status and output with the stated expectation. Failed transaction sessions close without committing; successful data/DDL probes explicitly roll back.

Unrelated-database connections are separate operations; for example:

```powershell
psql -X -W -h 127.0.0.1 -p 55432 -U brewpos_app -d brewpos_unrelateddb -c 'SELECT current_database();'
```

This must fail with a CONNECT privilege error in the evaluated lab. Repeat for each login and target listed in [the verification report](part_d.md). Full individual statements and expectations are also in [results.json](evidence/results.json).

## 6. Remaining security scope

Database restrictions were verified for the implemented privileges. They do not authenticate web users or freeze a receipt against new INSERTs. A direct runtime insert into an existing order was successful and rolled back, as recorded in [historical_append_gap.txt](evidence/historical_append_gap.txt). Closing this gap requires an explicit order lifecycle and guarded write design, not a false claim that absence of UPDATE/DELETE provides complete immutability.
