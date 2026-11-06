# Part A - Database Health and Activity Inspection

## Environment and Activity 4 continuity

Group 5 inspected **Group 10 - MESA - Restaurant Online Ordering and Table Reservation System** on **6 November 2026 (Asia/Manila)**. Main maintenance capture: `2026-11-06T21:08:36.453026+08:00` through `2026-11-06T21:08:40.246151+08:00`. This reuses the actual Activity 4 database and evaluated roles, rather than rebuilding the owning group's database or copying another report's environment values.

| Item | Actual environment |
|---|---|
| Source | [Repository](https://github.com/kathlenmaecallos11-arch/Restaurant-Online-Ordering-Table-Reservation-System), pinned main commit `9e1141a51515fcede0fe176ee5f47cfb6c8abf9b` |
| Database/schema | `mesa_g05_activity4` / `public` |
| PostgreSQL | **18.3**, Windows x64, SCRAM-authenticated psql TCP sessions |
| Dedicated endpoint | `127.0.0.1:55410` |
| Initial size | 9,803,455 bytes / `9574 kB` |
| Relevant objects | 8 tables, 7 sequences, 4 views, 19 indexes |
| Activity 4 setup/plan | [Part A](../../activity-4/grp10-mesa/part_a.md), [access plan](../../activity-4/grp10-mesa/part_b.md), [verification](../../activity-4/grp10-mesa/part_d.md) |

The source/schema/seed and evaluated role configuration were already installed and tested in Activity 4. G10 uses the committed application snapshot exported around a Windows-invalid unrelated test-folder name; migrations/seed content was not changed. No Activity 5 role changes, superuser connection, application-source edits or unrelated-database modifications were performed. The HTTP application processes remain stopped; this activity inspects and maintains their initialized PostgreSQL databases, not production traffic.

## Accounts used

| Task | Direct login / active role | Why this fits the existing plan |
|---|---|---|
| Exact counts, catalog/ACL review and maintenance | `rors_dba` → explicit `SET ROLE rors_owner_grp` | Existing non-superuser maintenance login and deliberately assigned project-owner membership |
| Session snapshot | `rors_dba`, without SET ROLE | Allows inspection of its own session without inventing global monitoring privileges |
| Approved reporting read and log-access probes | `rors_report` | Existing reporting login; its server-file restrictions are preserved |
| Query EXPLAIN/ANALYZE | `rors_app` | Same restricted database service identity the selected application query uses |
| Available PostgreSQL stderr log | Existing OS user reading this dedicated lab's `postgres.log` | Authorized local lab output; no database server-file grant added |

[Before-role evidence](evidence/02_roles_before.txt) and [after-role evidence](evidence/06_roles_after.txt) match exactly: six safe project roles, three intended login memberships, no membership ADMIN OPTION and no SUPERUSER/CREATEDB/CREATEROLE/REPLICATION/BYPASSRLS. The maintenance login requires explicit owner activation; runtime/reporting do not inherit owner rights. The owner can maintain `public.menu_item`, while the runtime cannot. Object ACLs, database/schema ACLs and default ACLs were unchanged.

## Table/index and statistics review

[Initial health output](evidence/01_health_before.txt) and [derived summary](evidence/summary.json) record exact counts, estimates, maintenance history, table/index sizes and XID ages. Exact live rows total **464** across the listed tables; estimated live/dead rows are separate statistics, not exact counts or proof of physical bloat.

| Table | Exact rows | Estimated live | Estimated dead | Changes since analyze | reltuples | Total bytes |
|---|---:|---:|---:|---:|---:|---:|
| `customer` | 51 | 51 | 49 | 0 | 51 | 73728 |
| `menu_item` | 50 | 50 | 6 | 0 | 50 | 49152 |
| `order_item` | 167 | 167 | 3 | 2 | 167 | 73728 |
| `orders` | 60 | 60 | 13 | 5 | 60 | 98304 |
| `payment` | 56 | 56 | 6 | 2 | 56 | 40960 |
| `reservation` | 50 | 50 | 6 | 50 | -1 | 65536 |
| `restaurant_table` | 20 | 20 | 2 | 20 | -1 | 40960 |
| `staff` | 10 | 10 | 11 | 18 | -1 | 40960 |

Autovacuum, activity tracking and count tracking are enabled. No table reloptions override was observed. Maximum initial table XID age was **74**; no wraparound emergency is demonstrated. Index sizes/use counters were inventoried; there was no evidence requiring a rebuild or a new index merely to satisfy this activity.

## Sessions, counters and visibility limits

The separate [activity snapshot](evidence/activity_visibility.txt), captured at `2026-11-06T21:10:09.445156+08:00`, showed **1 connection**, the inspection itself: `rors_dba`, state `active`, approximately **0.020714 seconds** since its query began, and no reported blocking PIDs. No other project session appeared in that snapshot. This is not a historical or load/concurrency assessment.

The owner-switched health snapshots had unavailable state/duration fields for the login's activity row. Their original `query_visible` field only checked non-nullness and must not be read as proof of query-text visibility; PostgreSQL can return an insufficient-privilege marker. The separate direct-login snapshot corrects that visibility limitation without granting pg_monitor or pg_read_all_stats. Other sessions' SQL text was not copied.

Initial counters: commits **540**, rollbacks **66**, deadlocks **0**, conflicts **0**, sessions **144**, abandoned sessions **0**, fatal sessions **0**. No abandoned session was recorded in this initial snapshot. Earlier negative Activity 4 tests explain many recorded errors/rollbacks; database counters are not a full connection audit.

**Assessment:** reachable and responsive in this small local test environment, no current blocker observed. Statistics/ordinary cleanup were appropriate on selected objects, with outcomes in [Part C](part_c.md). Logs and historical visibility qualifications are in [Part B](part_b.md).
