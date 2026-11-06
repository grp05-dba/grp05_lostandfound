# Part A – Database Health and Activity Inspection

Group 5 inspected Group 3's OJT Management System on **6 November 2026**, using its existing Activity 4 database and accounts. Health evidence was captured at **17:59:10 Asia/Manila (UTC+08)**. This is a local test environment; the database was not recreated or reseeded.

## Environment and source

| Item | Observed value |
|---|---|
| Repository | https://github.com/swvenz/Project-OJT-RMA-System |
| Branch/commit | `main`, `6a899fbc5882c2916be0af3a91457b1c0c54084b` |
| Source verification | Successful `git fetch origin`; clean local checkout still matches refreshed `origin/main` |
| Application | Java Swing/JDBC; one service connection serves all five application roles |
| PostgreSQL | 18.6, x86_64 Linux |
| Database/schema | `ojt_managementdb` / `public` |
| Connection | Local Unix socket, port 5432, direct named logins using `psql -X -w` |
| Database and table owner | `grp03_ojt_admin_grp` |
| Initial database size | 9,205,439 bytes, displayed as `8990 kB` |
| Public objects | 12 tables, 12 sequences, 24 indexes |

This database retains the documented Activity 4 local schema adaptations. The source SQL archive was not an OJT schema; the earlier setup used corrected DDL from the project's PDF and four Java compatibility columns. Those decisions are documented in [Activity 4 Part A](../../activity-4/grp03-Project-OJT-RMA-System/part_a.md). Activity 5 assesses that existing setup; it does not claim the original archive was restored or that the owning group's setup gaps were fixed.

## Accounts used

| Checks | Direct login | Activity 4 responsibility |
|---|---|---|
| Health, objects, roles/privileges, verification | `grp03_ojt_auditor` / `grp03_ojt_readonly_grp` | Authorized read-only inspection |
| Logging settings/access probes, maintenance | `grp03_ojt_dba` / `grp03_ojt_admin_grp` | Project administration through inherited ownership |
| Query plans | `grp03_ojt_app` / `grp03_ojt_runtime_grp` | Runtime service; selected query serves the STUDENT role |
| Service journal | Existing OS user `me` | Existing OS read access, independent of PostgreSQL memberships |

Each SQL capture identifies `session_user` and `current_user`. No superuser connection, SET ROLE, privilege changes or ownership changes were used for these checks. Remote access and password authentication were not tested.

## Tables and maintenance indicators

The [health script](sql/01_health.sql) and [complete output](evidence/01_health.txt) contain the inventory, exact aggregate counts, statistics, indexes, role attributes, ACLs and representative column restrictions. No profile, email, password-hash or audit-detail values were selected.

| Table | Exact live rows | Initial estimated dead tuples |
|---|---:|---:|
| `academic_supervisors` | 1 | 1 |
| `attendance` | 0 | 2 |
| `audit_log` | 0 | 0 |
| `companies` | 1 | 1 |
| `company_supervisors` | 1 | 1 |
| `evaluations` | 0 | 1 |
| `ojt_applications` | 0 | 2 |
| `ojt_placements` | 0 | 2 |
| `requirements` | 3 | 1 |
| `student_requirements` | 0 | 2 |
| `students` | 1 | 1 |
| `users` | 5 | 4 |

There are **12 live rows** and **18 estimated dead tuples** across these tables. Exact counts for `users` and `audit_log` use the permitted ID columns. No manual/automatic analysis or vacuum timestamps were recorded in the initial statistics; all `reltuples` estimates were -1. Autovacuum and activity/count tracking are enabled, with no table storage-option override shown. Individual table/index totals were 16–64 kB and XID ages were 26, so these observations do not indicate an urgent wraparound or large-storage problem. They justify a small maintenance baseline; see Part C.

## Sessions and current activity

The initial database snapshot showed **one connection**, the auditor's own active inspection query (PID 44835), approximately **2.609 ms** into execution. No other active/idle project sessions appeared, and `pg_blocking_pids` returned `{}`. No long-running or blocked query was observed at that moment.

Database counters were `xact_commit=321`, `xact_rollback=26`, `deadlocks=0`, `conflicts=0`, `sessions=15`, and zero abandoned/fatal/killed sessions; `stats_reset` was NULL. These cumulative counters do not explain individual errors or establish a lifetime incident rate. Earlier Activity 4 rollback tests are a plausible contributor to the rollback count and dead tuples.

Other accounts' SQL is intentionally omitted from the capture to prevent sensitive literals being copied. PostgreSQL also restricts other-session details without monitoring privileges. Only the auditor session was present, so this run does not directly test cross-account visibility. Part B reviews available historical service messages separately.

## Activity 4 roles and access comparison

All six planned roles remain present. Only `grp03_ojt_app`, `grp03_ojt_auditor` and `grp03_ojt_dba` have LOGIN, each with its single corresponding runtime/readonly/admin group. All six have INHERIT and lack SUPERUSER, CREATEDB, CREATEROLE, BYPASSRLS and REPLICATION. Membership ADMIN OPTION is false.

The effective privilege checks agree with the reviewed plan: runtime SELECT on the 12 tables and INSERT on 11, excluding `audit_log`; no runtime DELETE/TRUNCATE/MAINTAIN. Runtime UPDATE is column-scoped, so table-level UPDATE checks can be false while specific permitted column checks are true. The tested `users.is_active` and `attendance.is_verified` updates are allowed, while `users.role` and `attendance.hours_rendered` updates are denied. The auditor can read approved user IDs but not user email/hash or audit details, and has no writes or maintenance. The DBA can maintain all tables through inherited ownership. These are catalog checks, not a repeat of every Activity 4 behavioral test.

The project database and public schema exclude PUBLIC privileges. **Cross-database isolation remains incomplete:** all three project logins still have effective CONNECT to `grp_parkitdb` and `postgres`, where PUBLIC defaults permit it. The journal and [Activity 4 verification](../../activity-4/grp03-Project-OJT-RMA-System/part_d.md) show actual earlier connections to Park It. No fresh unrelated-database connection was attempted and no unrelated table access is inferred.

No user-defined audit trigger or RLS policy was found. `audit_log` is empty despite seeded application records; the earlier source review also found no automatic audit INSERT. This is an audit-coverage gap, not proof that no writes occurred. No audit log was modified.

**Assessment:** reachable and responsive, with no current blocking in the snapshot. Maintenance is appropriate, but connection scope, audit coverage and the limited seed-only workload remain qualifications to overall health.
