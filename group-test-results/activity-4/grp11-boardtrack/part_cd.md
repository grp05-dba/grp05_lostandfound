# Parts C and D - Roles, Privileges, and Least Privilege

## 1. SQL implementation and execution

The PDF uses Part C for role creation, Part D for least privilege and Part E for verification. The requested [part_d.md](part_d.md) contains that verification; this file covers C and D.

| Script / step | Connection and purpose |
|---|---|
| [01_roles_database.sql](sql/01_roles_database.sql) | Lab provisioning administrator in postgres; create safe groups/logins, explicit memberships, `boardtrack_g05_activity4` owned by `boardtrack_owner_grp`, and the unrelated lab database |
| Upstream initialization SQL | Target database, `SET ROLE boardtrack_owner_grp`; load the full plain-SQL setup bundle unchanged |
| [02_privileges.sql](sql/02_privileges.sql) | Provisioning administrator in `boardtrack_g05_activity4`; transactional reset/grants and future-object policy; rejects a different database name |
| [03_lab_isolation.sql](sql/03_lab_isolation.sql) | Dedicated port 55411 only; validates the five expected lab databases before revoking default PUBLIC access |

Use `psql -X -w -h 127.0.0.1 -p 55411 -U <account> -d <database> -v ON_ERROR_STOP=1 -f <script>`, with protected local credentials. In an authorized interactive psql session use `\password boardtrack_app`, `\password boardtrack_report` and `\password boardtrack_dba` to assign separate local passwords. No password literal is supplied in submitted scripts, URLs or evidence. Script 01 expects a new lab and intentionally does not overwrite existing roles/databases.

All table/sequence/view ownership comes from running upstream initialization under the NOLOGIN owner. The runtime and report logins have no owner membership. The maintenance login uses `SET ROLE boardtrack_owner_grp` for DDL, not an elevated role attribute. Raw [setup output](evidence/setup.txt) and [catalog output](evidence/catalog.txt) establish execution.

## 2. PDF Part D - least-privilege review

| Requirement | Implemented control | Actual verification |
|---|---|---|
| Normal traffic does not use superuser | `boardtrack_app` process configuration, safe role attributes | HTTP workflows plus pg_stat_activity showing runtime connections |
| Cannot connect to unrelated databases | Remove PUBLIC access only in isolated lab; explicit target CONNECT | All three logins denied at unrelated lab DB, postgres and template1 |
| Modify only assigned objects | Per-table grants; no runtime DDL/ownership | Actual rollback mutations and denied out-of-matrix writes |
| Read-only cannot write | Approved read grants only | INSERT/UPDATE/DELETE on every table denied |
| No unnecessary role/database creation | No CREATEDB/CREATEROLE/SUPERUSER/REPLICATION/BYPASSRLS | Catalog inspection and real denied CREATE DATABASE/ROLE |
| Review PUBLIC and inheritance | Restricted schema/objects/functions/default ACLs; three intended memberships, no ADMIN OPTION | Denied escalation/DDL plus future-object lifecycle tests |

## 3. Future objects, functions and ownership

New tables and sequences require explicit migration grants; runtime/reporting do not inherit automatic future access. PUBLIC EXECUTE on future functions is removed with **global** creator-specific ALTER DEFAULT PRIVILEGES, because per-schema revocation cannot undo a globally granted default. The actual owner group and maintenance login defaults are both covered.

An owner-created SERIAL table and SQL function were tested: runtime/reporting reads/execution were denied, maintenance access after SET ROLE succeeded, and both probes were dropped. Current application trigger workflows still passed after function PUBLIC revocation. The pgcrypto crypt(text,text) grant was also exercised by real login requests; reporting cannot invoke it.

The DBA is intentionally able to modify its own project objects and ACLs after explicit owner activation. No promise is made to constrain a malicious owner through its own grants. Default ACLs are creator-specific; future migration authors must use the documented owner role and review privileges.

References: [PostgreSQL 18 GRANT](https://www.postgresql.org/docs/18/sql-grant.html), [ALTER DEFAULT PRIVILEGES](https://www.postgresql.org/docs/18/sql-alterdefaultprivileges.html). Tests use actual effective privileges, including PUBLIC and inheritance, rather than assuming a role name enforces its responsibility.

## 4. Retained local environment and execution limits

The initialized data directory is `D:/Data Administration/course-review/g11-activity4-lab/pgdata`, listening only on loopback 55411. Credentials are stored separately in a private local lab configuration outside Git. The HTTP server was stopped after testing. The database remains available locally for later work; stop/restart only this cluster with pg_ctl and its exact data directory when needed.

Successful SQL probes rolled back; HTTP-created rows were removed. SERIAL values advanced during successful tests and were not reset. [Final cleanup](evidence/final-cleanup.txt) confirms original seed counts. Existing shared servers/databases were not hardened or reconfigured as part of this work.
