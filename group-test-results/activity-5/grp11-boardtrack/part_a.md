# Part A - Database Health and Activity Inspection

## Environment and Activity 4 continuity

Group 5 inspected **Group 11 - BoardTrack - Boarding House and Rental Management System** on **6 November 2026 (Asia/Manila)**. Main maintenance capture: `2026-11-06T21:08:40.264299+08:00` through `2026-11-06T21:08:43.674437+08:00`. This reuses the actual Activity 4 database and evaluated roles, rather than rebuilding the owning group's database or copying another report's environment values.

| Item | Actual environment |
|---|---|
| Source | [Repository](https://github.com/karlrobertc-art/BoardTrack), pinned main commit `242b366936f17324dca7e4435bc1d6abe59b27d7` |
| Database/schema | `boardtrack_g05_activity4` / `public` |
| PostgreSQL | **18.3**, Windows x64, SCRAM-authenticated psql TCP sessions |
| Dedicated endpoint | `127.0.0.1:55411` |
| Initial size | 9,451,199 bytes / `9230 kB` |
| Relevant objects | 8 tables, 7 sequences, 1 views, 16 indexes |
| Activity 4 setup/plan | [Part A](../../activity-4/grp11-boardtrack/part_a.md), [access plan](../../activity-4/grp11-boardtrack/part_b.md), [verification](../../activity-4/grp11-boardtrack/part_d.md) |

The source/schema/seed and evaluated role configuration were already installed and tested in Activity 4. No new schema/seed installation was necessary. No Activity 5 role changes, superuser connection, application-source edits or unrelated-database modifications were performed. The HTTP application processes remain stopped; this activity inspects and maintains their initialized PostgreSQL databases, not production traffic.

## Accounts used

| Task | Direct login / active role | Why this fits the existing plan |
|---|---|---|
| Exact counts, catalog/ACL review and maintenance | `boardtrack_dba` → explicit `SET ROLE boardtrack_owner_grp` | Existing non-superuser maintenance login and deliberately assigned project-owner membership |
| Session snapshot | `boardtrack_dba`, without SET ROLE | Allows inspection of its own session without inventing global monitoring privileges |
| Approved reporting read and log-access probes | `boardtrack_report` | Existing reporting login; its server-file restrictions are preserved |
| Query EXPLAIN/ANALYZE | `boardtrack_app` | Same restricted database service identity the selected application query uses |
| Available PostgreSQL stderr log | Existing OS user reading this dedicated lab's `postgres.log` | Authorized local lab output; no database server-file grant added |

[Before-role evidence](evidence/02_roles_before.txt) and [after-role evidence](evidence/06_roles_after.txt) match exactly: six safe project roles, three intended login memberships, no membership ADMIN OPTION and no SUPERUSER/CREATEDB/CREATEROLE/REPLICATION/BYPASSRLS. The maintenance login requires explicit owner activation; runtime/reporting do not inherit owner rights. The owner can maintain `public.lease`, while the runtime cannot. Object ACLs, database/schema ACLs and default ACLs were unchanged.

## Table/index and statistics review

[Initial health output](evidence/01_health_before.txt) and [derived summary](evidence/summary.json) record exact counts, estimates, maintenance history, table/index sizes and XID ages. Exact live rows total **30** across the listed tables; estimated live/dead rows are separate statistics, not exact counts or proof of physical bloat.

| Table | Exact rows | Estimated live | Estimated dead | Changes since analyze | reltuples | Total bytes |
|---|---:|---:|---:|---:|---:|---:|
| `app_user` | 3 | 3 | 0 | 3 | -1 | 49152 |
| `lease` | 4 | 4 | 4 | 4 | -1 | 65536 |
| `payment` | 6 | 6 | 2 | 6 | -1 | 40960 |
| `property` | 2 | 2 | 4 | 5 | -1 | 24576 |
| `room` | 6 | 6 | 9 | 10 | -1 | 40960 |
| `schema_migrations` | 1 | 1 | 0 | 1 | -1 | 32768 |
| `tenant` | 4 | 4 | 2 | 4 | -1 | 40960 |
| `utility_bill` | 4 | 4 | 2 | 4 | -1 | 40960 |

Autovacuum, activity tracking and count tracking are enabled. No table reloptions override was observed. Maximum initial table XID age was **43**; no wraparound emergency is demonstrated. Index sizes/use counters were inventoried; there was no evidence requiring a rebuild or a new index merely to satisfy this activity.

## Sessions, counters and visibility limits

The separate [activity snapshot](evidence/activity_visibility.txt), captured at `2026-11-06T21:10:09.633159+08:00`, showed **1 connection**, the inspection itself: `boardtrack_dba`, state `active`, approximately **0.016339 seconds** since its query began, and no reported blocking PIDs. No other project session appeared in that snapshot. This is not a historical or load/concurrency assessment.

The owner-switched health snapshots had unavailable state/duration fields for the login's activity row. Their original `query_visible` field only checked non-nullness and must not be read as proof of query-text visibility; PostgreSQL can return an insufficient-privilege marker. The separate direct-login snapshot corrects that visibility limitation without granting pg_monitor or pg_read_all_stats. Other sessions' SQL text was not copied.

Initial counters: commits **246**, rollbacks **66**, deadlocks **0**, conflicts **0**, sessions **95**, abandoned sessions **1**, fatal sessions **0**. The nonzero abandoned-session count warrants correlation with controlled application shutdowns and any future real workload; this snapshot does not establish its cause. Earlier negative Activity 4 tests explain many recorded errors/rollbacks; database counters are not a full connection audit.

**Assessment:** reachable and responsive in this small local test environment, no current blocker observed. Statistics/ordinary cleanup were appropriate on selected objects, with outcomes in [Part C](part_c.md). Logs and historical visibility qualifications are in [Part B](part_b.md).
