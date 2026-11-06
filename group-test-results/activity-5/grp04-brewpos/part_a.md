# Part A – Database Health and Activity Inspection

Group 5 inspected Group 4's BrewPOS café point-of-sale database on **6 November 2026**, with health evidence captured at **18:11:34 Asia/Manila (UTC+08)**. This uses the existing local database on port 5432. The isolated port-55432 environment described in the Activity 3 report was not assumed to be this database or restarted for Activity 5.

## Environment and source

| Item | Observed value |
|---|---|
| Repository | https://github.com/Nycri/brewpos |
| Reviewed branch/commit | `main`, `f2af982d7cd2709ebcb0e0f0fd00af27bc4286d4` |
| Source access | Connected GitHub read tools; schema, roles documentation, runtime setup and sales query/caller inspected |
| PostgreSQL | 18.6, x86_64 Linux |
| Database/schema | `grp_brewposdb` / `public` |
| Connection | Local Unix socket on port 5432, direct `psql -X -w -U brewpos_app` login |
| Database/table owner | `postgres`; not used for Activity 5 SQL |
| Initial database size | 8,263,359 bytes, displayed as `8070 kB` |
| Objects in public | Five tables, four sequences, nine indexes |

The supplied repository's current `main` is newer than the commit recorded in [Activity 3](../../activity-3/grp04-brewpos/testing-output.md). Its schema still describes the five observed application tables, four SERIAL sequences and two explicit performance indexes. The existing database was inspected without restoring, seeding, migrating or aligning it.

## Activity 4 prerequisite and account choice

Our [Activity 4 BrewPOS folder](../../activity-4/grp04-brewpos/) contains only `.gitkeep`; there is no local completed access-control plan or verification report to continue. The owning repository's [user-role documentation](https://github.com/Nycri/brewpos/blob/f2af982d7cd2709ebcb0e0f0fd00af27bc4286d4/docs/user-roles.md) supplies an **intended** role mapping, not evidence that those roles were installed locally.

| Documented role/account | Observed local status |
|---|---|
| `brewpos_app` | Present, LOGIN, NOINHERIT; no group memberships |
| `brewpos_auditor`, `brewpos_admin` | Absent |
| `app_runtime_grp`, `app_readonly_grp`, `app_admin_grp` | Absent |

The only BrewPOS-specific login found is the documented runtime service account. It lacks SUPERUSER, CREATEDB, CREATEROLE, REPLICATION and BYPASSRLS. All SQL checks therefore used **`brewpos_app` within its existing grants**; no auditor or DBA identity was fabricated. `session_user` and `current_user` are recorded in every SQL capture. Historical `postgres` sessions appear only in log evidence; we did not connect as that account.

The runtime represents Spring Boot's shared service connection for Cashier/Manager UI operations, including reporting. The account was used for SELECT inspection, logging-access probes, one maintenance-limit demonstration and query plans. Existing OS user `me` separately read accessible service-journal messages without sudo or database role substitution. Remote/password authentication and deployed application configuration were not tested.

## Tables, activity and statistics

The [health script](sql/01_health.sql) and [actual output](evidence/01_health.txt) record object/role inventories, exact aggregate counts, privileges, indexes, sessions and maintenance indicators. No staff names or credential values were captured.

| Table | Exact rows | `n_live_tup` estimate | Estimated dead tuples |
|---|---:|---:|---:|
| `menu_category` | 3 | 6 | 0 |
| `menu_item` | 11 | 22 | 0 |
| `order_line_item` | 9 | 18 | 0 |
| `order_ticket` | 5 | 10 | 0 |
| `staff` | 2 | 4 | 0 |

There are **30 exact live rows**. The statistics-view live estimates are twice those counts, while `pg_class.reltuples` matches the exact counts (3, 11, 9, 5, 2). This discrepancy is recorded rather than interpreted as duplicate data. Runtime statistics are approximate; this run does not establish why they diverged. Latest recorded ANALYZE was 5 November at approximately 22:48 +08; no vacuum/autovacuum/autoanalyze timestamp was recorded. All tables have one reported heap page, total table/index sizes of 24–40 kB, and XID ages of 70. Autovacuum and tracking are enabled, with no per-table storage override shown. No large dead-tuple backlog or wraparound emergency is demonstrated.

The initial snapshot showed **one connection**, the runtime's own active inspection query, PID 50461, approximately **2.774 ms** into execution. No other active/idle project sessions appeared and `pg_blocking_pids` returned `{}`. No current blocker or long-running query was observed. Other accounts' query text is deliberately excluded, and PostgreSQL may restrict other-session details; there was no other live session to test that visibility boundary.

Counters showed `xact_commit=2520`, `xact_rollback=3`, `deadlocks=0`, `conflicts=0`, `sessions=45`, zero abandoned/fatal sessions and one killed session; `stats_reset` was NULL. These cumulative observations are not a complete incident or authentication history. Part B identifies one historical administrator-terminated session in the readable journal.

## Privileges and differences from documentation

The runtime's direct table grants match `database/05_create_app_role.sql`: SELECT only on staff; CRUD on menu categories/items; SELECT/INSERT only on order tickets/lines; no TRUNCATE or MAINTAIN on any table. It has USAGE/SELECT, but not UPDATE, on all four sequences, including the staff sequence although it cannot insert staff. Database-specific defaults are `search_path=public`, `statement_timeout=30s`, `lock_timeout=10s`.

The separate role groups and logins described in `docs/user-roles.md` are absent. That document says the role setup is automated by `05_create_app_role.sql`, but the actual script creates/configures only the runtime with direct grants and NOINHERIT. The documented application membership is therefore not implemented by that script or present here. Its `app_admin_grp` design is for catalog management, not maintenance of every sales/staff table.

The project database retains PUBLIC CONNECT/TEMPORARY (`=Tc`), its public schema retains PUBLIC USAGE, and the runtime has effective CONNECT to unrelated `postgres` through default privileges. This was a catalog check, not a fresh unrelated-database connection or proof of unrelated table access. No ACL changes were made.

**Assessment:** reachable and responsive in this snapshot, with useful seed data and no current blockers. Activity 4 role separation is incomplete, maintenance is unavailable to the existing runtime, and the statistics discrepancy/access scope need follow-up. No completed Activity 4 configuration or successful Activity 5 maintenance is claimed.
