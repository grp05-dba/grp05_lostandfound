# Part A – Database Health and Activity Inspection

Group 5 inspected Group 2's Park It database on **6 November 2026, 17:39–17:41 Asia/Manila (UTC+08)**. This is the existing local Activity 4 database, not a newly restored or production database. All results below come from executed checks.

## Environment and source

| Item | Observed value |
|---|---|
| Supplied repository | https://github.com/HelloP0/PARK-IT-DATABASE-MANAGEMENT-SYSTEM |
| Source reviewed | `main`, commit `d369a457ce2dc88a024428513360f0ad76473f43` |
| Source files | `park-it/README.md`, `park-it/schema.sql`, monitoring endpoint and helper functions |
| PostgreSQL | 18.6, x86_64 Linux |
| Database/schema | `grp_parkitdb` / `public` |
| Connection | Local Unix socket, port 5432, direct named logins through `psql -X -w` |
| Database/table owner | `postgres`; that account was not used for Activity 5 SQL |
| Initial database size | 8,181,439 bytes, reported by PostgreSQL as `7990 kB` |

The [Activity 4 assessment](../../activity-4/grp02-parkit/part_a.md) cited `millerdevera6-glitch/park-it-database`, branch `final`. The URL supplied for this activity is different. Its schema defines the same five application tables, associated sequences, keys and relationships observed locally. The existing database and access-control configuration were retained; a matching structure does not establish identical repository history. The supplied repository's README still recommends a `postgres` application connection; Activity 5 instead uses the dedicated Activity 4 accounts.

## Accounts used

| Check | Direct login | Activity 4 group/responsibility |
|---|---|---|
| Health, roles, privilege checks and post-maintenance verification | `park_it_auditor` | `park_it_readonly_grp`, restricted inspection |
| Logging settings/function-access checks and maintenance | `park_it_dba` | `park_it_admin_grp`, database administration |
| Application query execution plans | `park_it_app` | `park_it_runtime_grp`, PHP runtime shared by application Admin/Staff |
| Service journal review | Existing OS user `me` | OS service-log reader; no PostgreSQL role assumed |

Each SQL evidence file records both `session_user` and `current_user`. No `SET ROLE`, superuser connection or privilege changes were used. Password authentication and remote connectivity were not tested.

## Objects and data

The [health script](sql/01_health.sql) and [complete output](evidence/01_health.txt) show **five tables, five sequences and nine indexes** in `public`. There are five primary-key and four additional unique indexes; `transaction` has only its primary-key index.

| Table | Exact visible rows | Initial estimated dead tuples |
|---|---:|---:|
| `parking_zone` | 0 | 0 |
| `payment` | 0 | 0 |
| `staff_user` | 0 | 0 |
| `transaction` | 0 | 0 |
| `vehicle` | 0 | 2 |

The auditor counted only the permitted `staff_user.user_id` column. Its information-schema column list excludes `password_hash` because that column is not readable; the column is not missing from the database. No password hashes were queried.

This setup has no parking zones or staff seed accounts and cannot demonstrate a populated application workflow. An authorized provisioning process should review seed/setup requirements before application testing. Empty tables were left empty rather than adding artificial workload records.

## Sessions, activity and unusual behavior

At 17:39:31, `pg_stat_database.numbackends` was **1**. `pg_stat_activity` showed only the auditor's own active inspection query (PID 35642), approximately **2.812 ms** into execution. No idle application sessions or other running queries appeared. `pg_blocking_pids` returned `{}`. This is a point-in-time observation, not proof that blocking never occurs.

Database counters showed `deadlocks=0`, `conflicts=0`, `xact_commit=1348`, `xact_rollback=18`, `sessions=20`, `sessions_abandoned=0`, `sessions_fatal=0`, and `sessions_killed=3`; `stats_reset` was NULL. These cumulative counters do not identify causes or provide a complete authentication/error history. Expected rollback tests from Activity 4 are a plausible contributor to rollbacks. The service journal records three historical administrator-terminated project connections; see [Part B](part_b.md).

Other accounts' SQL is deliberately excluded from the script's output, and PostgreSQL may restrict visibility of their session details. Neither the auditor nor DBA inherits `pg_read_all_stats`; no such grant was added. No other live project session was present to test this visibility limit directly.

## Activity 4 role comparison

All six expected roles exist. Only `park_it_app`, `park_it_auditor` and `park_it_dba` have LOGIN. Each has exactly its documented group membership. All six have INHERIT and lack SUPERUSER, CREATEDB, CREATEROLE, BYPASSRLS and REPLICATION. The effective table/column privilege matrix in the evidence agrees with the tested Activity 4 plan:

- Runtime: SELECT on all five tables; INSERT on vehicle, transaction and payment; UPDATE on operational tables; DELETE only on vehicle.
- Auditor: SELECT on the four operational tables and approved staff ID, username and role columns; no password-hash access, writes or maintenance.
- DBA: broad existing-table privileges, including effective table `MAINTAIN` on all five tables in PostgreSQL 18.

The previous access-scope problem persists: all three logins still have effective CONNECT to unrelated `postgres`, and the project ACL retains `PUBLIC` CONNECT/TEMPORARY (`=Tc`). Catalog checks confirm access paths; the previous Activity 4 report and today's historical journal review provide actual connection evidence. No new unrelated-database connection was needed or attempted. Table privileges on unrelated databases were not inferred from CONNECT.

**Assessment:** reachable and responsive in this snapshot; no current blocking observed. Application readiness is limited by empty tables, and database access scope still needs review. Maintenance and log findings are covered in the following parts.
