# Part C - Routine Maintenance

**Outcome: ANALYZE and ordinary VACUUM completed and were independently verified.** The account used is the non-superuser maintenance login from the evaluated Activity 4 plan, explicitly activating its assigned owner group. No new grants, superuser retry or restriction bypass was used.

## Purpose and suitability assessed before execution

The initial inventory showed small seed-only tables with recent test mutations and estimated dead tuples. Target `public.lease` had **4 exact rows**, **4 estimated dead tuples**, `reltuples=-1` and no recorded manual or automatic analyze. This supports a bounded statistics refresh and ordinary cleanup; it does not demonstrate a bloat emergency or justify a table rewrite.

- **ANALYZE** refreshes planner statistics used by the selected real application query. All six business tables joined by the lease-summary view were analyzed, including its payment/utility aggregate inputs.
- **Ordinary VACUUM** makes reclaimable tuple space reusable and maintains visibility/freeze metadata. It is not a promise to shrink the database file or improve query latency.
- `TRUNCATE FALSE` disables tail truncation to avoid that vacuum phase's stronger lock. Lock/statement timeouts were set to 3s/30s. No FULL vacuum, forced freeze, index creation or rebuild was run.

No competing project session/blocker appeared in the inspection. Maintenance can still contend with other operations; these commands ran only in the dedicated local lab. Other tables' remaining estimates are reported rather than claiming the whole database was vacuumed.

## Account and executed commands

Direct authenticated login: **`boardtrack_dba`**. Existing membership activated with **`SET ROLE boardtrack_owner_grp`**. [Before-role evidence](evidence/02_roles_before.txt) confirms effective MAINTAIN through ownership; normal runtime MAINTAIN is false.

```sql
SET lock_timeout = '3s';
SET statement_timeout = '30s';
SET ROLE boardtrack_owner_grp;
ANALYZE VERBOSE public.property;
ANALYZE VERBOSE public.room;
ANALYZE VERBOSE public.tenant;
ANALYZE VERBOSE public.lease;
ANALYZE VERBOSE public.payment;
ANALYZE VERBOSE public.utility_bill;
VACUUM (VERBOSE, ANALYZE, TRUNCATE FALSE) public.lease;
```

[Maintenance SQL](sql/03_maintenance.sql) and [actual verbose output](evidence/04_maintenance.txt) record execution. VACUUM was a standalone psql command, outside a transaction block. The output contained no permission/skip warning and the process succeeded. Command tags alone were not accepted as proof.

## Fresh-session verification

| Target statistic | Before | After |
|---|---|---|
| Exact live rows | 4 | 4 |
| Estimated dead tuples | 4 | 0 |
| reltuples estimate | -1 | 4 |
| Manual vacuum count | 0 | 1 |
| Manual analyze count | 0 | 2 |
| Last manual vacuum | NULL | 2026-11-06T21:08:41.948562+08:00 |
| Last manual analyze | NULL | 2026-11-06T21:08:41.951769+08:00 |
| Target total bytes | 65536 | 98304 |

[After-health evidence](evidence/05_health_after.txt) confirms exact counts and sequence values stayed unchanged across **all** project tables/sequences. [After-role evidence](evidence/06_roles_after.txt) matches the initial role/ACL/default policy exactly. Physical sizes need not fall: ordinary vacuum can allocate visibility/free-space metadata and reuses space rather than rewriting/shrinking files. Actual outputs, not a size decrease, establish success.

The target was analyzed twice by this sequence: explicit ANALYZE, then VACUUM with ANALYZE. Other G11 selected business tables received the separate explicit ANALYZE only. No application records were inserted/updated/deleted by this activity; sequence values were not consumed or reset. Further vacuum across other tables is a workload-based follow-up, not a prerequisite to claiming this selected maintenance succeeded.

Reference: [PostgreSQL 18 VACUUM](https://www.postgresql.org/docs/18/sql-vacuum.html). The database owner role is used deliberately within its Activity 4 duties; report/runtime accounts remain restricted.
