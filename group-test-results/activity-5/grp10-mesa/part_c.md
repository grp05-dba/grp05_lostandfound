# Part C - Routine Maintenance

**Outcome: ANALYZE and ordinary VACUUM completed and were independently verified.** The account used is the non-superuser maintenance login from the evaluated Activity 4 plan, explicitly activating its assigned owner group. No new grants, superuser retry or restriction bypass was used.

## Purpose and suitability assessed before execution

The initial inventory showed small seed-only tables with recent test mutations and estimated dead tuples. Target `public.menu_item` had **50 exact rows**, **6 estimated dead tuples**, `reltuples=50` and existing automatic statistics but no recorded manual vacuum. This supports a bounded statistics refresh and ordinary cleanup; it does not demonstrate a bloat emergency or justify a table rewrite.

- **ANALYZE** refreshes planner statistics used by the selected real application query. Only the selected query table was explicitly analyzed.
- **Ordinary VACUUM** makes reclaimable tuple space reusable and maintains visibility/freeze metadata. It is not a promise to shrink the database file or improve query latency.
- `TRUNCATE FALSE` disables tail truncation to avoid that vacuum phase's stronger lock. Lock/statement timeouts were set to 3s/30s. No FULL vacuum, forced freeze, index creation or rebuild was run.

No competing project session/blocker appeared in the inspection. Maintenance can still contend with other operations; these commands ran only in the dedicated local lab. Other tables' remaining estimates are reported rather than claiming the whole database was vacuumed.

## Account and executed commands

Direct authenticated login: **`rors_dba`**. Existing membership activated with **`SET ROLE rors_owner_grp`**. [Before-role evidence](evidence/02_roles_before.txt) confirms effective MAINTAIN through ownership; normal runtime MAINTAIN is false.

```sql
SET lock_timeout = '3s';
SET statement_timeout = '30s';
SET ROLE rors_owner_grp;
ANALYZE VERBOSE public.menu_item;
VACUUM (VERBOSE, ANALYZE, TRUNCATE FALSE) public.menu_item;
```

[Maintenance SQL](sql/03_maintenance.sql) and [actual verbose output](evidence/04_maintenance.txt) record execution. VACUUM was a standalone psql command, outside a transaction block. The output contained no permission/skip warning and the process succeeded. Command tags alone were not accepted as proof.

## Fresh-session verification

| Target statistic | Before | After |
|---|---|---|
| Exact live rows | 50 | 50 |
| Estimated dead tuples | 6 | 0 |
| reltuples estimate | 50 | 50 |
| Manual vacuum count | 0 | 1 |
| Manual analyze count | 0 | 2 |
| Last manual vacuum | NULL | 2026-11-06T21:08:38.190815+08:00 |
| Last manual analyze | NULL | 2026-11-06T21:08:38.197603+08:00 |
| Target total bytes | 49152 | 81920 |

[After-health evidence](evidence/05_health_after.txt) confirms exact counts and sequence values stayed unchanged across **all** project tables/sequences. [After-role evidence](evidence/06_roles_after.txt) matches the initial role/ACL/default policy exactly. Physical sizes need not fall: ordinary vacuum can allocate visibility/free-space metadata and reuses space rather than rewriting/shrinking files. Actual outputs, not a size decrease, establish success.

The target was analyzed twice by this sequence: explicit ANALYZE, then VACUUM with ANALYZE. Other G11 selected business tables received the separate explicit ANALYZE only. No application records were inserted/updated/deleted by this activity; sequence values were not consumed or reset. Further vacuum across other tables is a workload-based follow-up, not a prerequisite to claiming this selected maintenance succeeded.

Reference: [PostgreSQL 18 VACUUM](https://www.postgresql.org/docs/18/sql-vacuum.html). The database owner role is used deliberately within its Activity 4 duties; report/runtime accounts remain restricted.
