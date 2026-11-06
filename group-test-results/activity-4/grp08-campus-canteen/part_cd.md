# Parts C and D - Database Roles, Privileges, and Least Privilege

## 1. Implementation files and execution order

The PDF calls role creation **Part C**, least-privilege review **Part D**, and verification **Part E**. The user-requested `part_d.md` filename contains that verification report. These SQL files implement the evaluated G08 plan in Group 5's repository:

| Script | Connection | Purpose |
|---|---|---|
| [01_roles_database.sql](sql/01_roles_database.sql) | Provisioning administrator, `postgres`, new dedicated cluster | Three NOLOGIN groups, three safe logins, explicit memberships, owned project database and unrelated denial-test database |
| Upstream migrations 001, 002 and seed 001 | `canteen_g05_activity4`, provisioning session with `SET ROLE canteen_owner_grp` | Original seven-table schema/authentication columns and sample data, unchanged |
| [02_privileges.sql](sql/02_privileges.sql) | Provisioning administrator, `canteen_g05_activity4` | Reset PUBLIC/direct/group object grants, apply per-table/column/sequence policy and restrictive future-object defaults |
| [03_lab_isolation.sql](sql/03_lab_isolation.sql) | Provisioning administrator, dedicated port 55408 only | Remove default database access in the lab; restore only target CONNECT grants |

Use `psql -X -w -h 127.0.0.1 -p 55408 -U <account> -d <database> -v ON_ERROR_STOP=1 -f <script>`. Authenticate through a protected local password mechanism, not a password in the command line. From an authorized interactive session, use `\password canteen_app`, `\password canteen_readonly` and `\password canteen_admin` to assign distinct passwords. No real credentials are supplied in these files.

Script 01 is for a fresh lab, not a migration to an existing production cluster; repeated role/database creation intentionally fails. Script 02 validates the database name and uses a transaction. Script 03 checks the dedicated port and expected database inventory before applying lab-wide restrictions. Do not use it against a shared PostgreSQL service. Existing local servers were preserved.

## 2. Least-privilege decisions (PDF Part D)

| Requirement | Implemented control | Verification |
|---|---|---|
| No superuser for ordinary application traffic | `DB_USER=canteen_app`; no owner membership or elevated role attributes | Real HTTP workflows plus `pg_stat_activity` runtime identity |
| No unrelated database access | PUBLIC database grants removed only in this isolated cluster; explicit target CONNECT | Independent TCP attempts to unrelated lab DB, postgres and template1 denied for all three logins |
| Modify only assigned tables | Per-table matrix; no student/order_item UPDATE; DELETE only menu_item | Allowed transactional inserts/updates/delete and explicit denied write probes |
| Reporting cannot modify data | Column SELECT grants only, with no write/sequence grants | INSERT/UPDATE/DELETE against every table denied |
| No unnecessary elevated attributes | All six project roles have no SUPERUSER/CREATEDB/CREATEROLE/REPLICATION/BYPASSRLS | Catalog inventory and actual denied database/role creation |
| Review PUBLIC, memberships and ownership | Restricted schema/default ACLs, separate owner group, no membership ADMIN OPTION | DDL/escalation rejection and future-table/function lifecycle tests |

The maintenance login has owner-level powers only after explicit `SET ROLE canteen_owner_grp`. Ownership is a deliberate broad administrative capability, not an ordinary runtime grant. The provisioning administrator remains able to create roles/databases; that capability is not delegated to the maintenance login.

## 3. Upstream script assessment

Upstream role creation and privilege files were reviewed. They were not layered on top of this implementation. In particular:

- Upstream script 06 grants runtime SELECT/INSERT/UPDATE automatically on future tables. A transactional experiment created a table as the upstream-named administrator and verified all three permissions were true. The transaction was rolled back. The evaluated owner has no blanket future grants.
- Upstream script 07 revokes PUBLIC CONNECT across its cluster. Equivalent isolation was applied only to this new five-database lab, never to a shared service.
- The evaluated implementation needs sequence USAGE only; raw sequence SELECT/state-reset rights are withheld and tested.
- Removing PUBLIC function EXECUTE must use a global creator-specific default policy; a schema-only revoke cannot cancel a global default grant. Both owner and maintenance creators are covered.

Relevant official references: [PostgreSQL 18 GRANT](https://www.postgresql.org/docs/18/sql-grant.html) and [ALTER DEFAULT PRIVILEGES](https://www.postgresql.org/docs/18/sql-alterdefaultprivileges.html). These explain additive direct/group/PUBLIC privileges and creator-specific future-object ACLs. Actual lab output is in [verification.txt](evidence/verification.txt) and [catalog.txt](evidence/catalog.txt).

## 4. Reproduction and retained local lab

The local database lives outside the submission folder at `D:/Data Administration/course-review/g08-activity4-lab/pgdata`; the source snapshot is in sibling `g08-activity4-source`. Password configuration is private, outside Git. The API is stopped after HTTP validation. The database retains only the original seed rows; SERIAL sequences advanced during successful tests and were not reset.

If the lab server is stopped, start it using the PostgreSQL 18 `pg_ctl` executable with `-D` pointing at that exact data folder and `-l` pointing at its local log. The configuration binds only loopback port 55408. All submitted verification statements and their outputs are available in the evidence files; no test requires overwriting the owning group's repository.
