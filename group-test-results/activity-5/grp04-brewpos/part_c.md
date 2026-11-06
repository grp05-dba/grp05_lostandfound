# Part C – Routine Maintenance

**Outcome: maintenance blocked by the existing account privileges.** ANALYZE and ordinary VACUUM were attempted once on `public.menu_item` to demonstrate the restriction; PostgreSQL skipped both. No successful table maintenance is claimed.

## Object review and purpose

[Health evidence](evidence/01_health.txt) shows five small tables, four sequences and nine indexes. These include primary/unique keys, the order-timestamp index and the item-side line-item index. Individual table/index totals are 24–40 kB. Exact row counts total 30 and estimated dead tuples are zero. This inventory does not establish physical index integrity or a need to rebuild indexes.

The statistics view's live estimates are twice the exact counts, while catalog `reltuples` agrees with exact counts. Existing ANALYZE timestamps are from 5 November, approximately 22:48 +08. No manual/automatic vacuum timestamp is shown; autovacuum is enabled, table options show no override, and XID ages are 70. No demonstrated bloat or wraparound emergency justifies disruptive work.

Before attempting the restricted commands, their purposes and impact were assessed:

- **ANALYZE** would refresh planner statistics and help assess the observed statistics discrepancy. It would not guarantee a particular `pg_stat_user_tables` estimate or query plan.
- **Ordinary VACUUM** would remove reclaimable dead tuple versions and maintain visibility/freeze information. There is no measured dead-tuple backlog here; the command demonstrates the available maintenance approach and permission boundary on one small real table.
- **VACUUM with ANALYZE** combines cleanup and statistics refresh. It must run outside a transaction block. FULL vacuum, index creation and rebuilds were not justified.

Ordinary vacuum may conflict with DDL/other maintenance and may briefly seek a stronger lock for tail truncation. The local snapshot had no competing session. The script sets `lock_timeout=3s` and `statement_timeout=30s`. Because privilege checks already showed MAINTAIN=false, no physical maintenance was expected. The limitation was demonstrated once rather than repeated across every table.

## Account, statements and actual output

`brewpos_app` is the only BrewPOS login found; all tables belong to `postgres`, and the runtime has no MAINTAIN privilege on any of them. No completed local Activity 4 auditor/maintenance configuration exists. The owning group's intended catalog-admin account is absent and its documented grants would not in themselves authorize maintenance of all tables.

[03_maintenance.sql](sql/03_maintenance.sql) ran directly as `brewpos_app` at **18:11:36 +08 on 6 November 2026**, without a transaction wrapper:

```sql
ANALYZE VERBOSE public.menu_item;
VACUUM (VERBOSE, ANALYZE) public.menu_item;
```

[Actual output](evidence/03_maintenance.txt):

```text
WARNING:  01000: permission denied to analyze "menu_item", skipping it
ANALYZE
WARNING:  01000: permission denied to vacuum "menu_item", skipping it
VACUUM
```

The **ANALYZE/VACUUM tags and zero psql exit code do not establish success**. The warnings explicitly state that the table was skipped. ON_ERROR_STOP alone would not catch these warning-only outcomes; this script records them and the report assesses the individual results.

## Verification and required follow-up

A fresh direct runtime session at **18:11:38 +08** ran [05_verify.sql](sql/05_verify.sql). [Results](evidence/05_verify.txt) show unchanged exact counts (categories 3, items 11, lines 9, tickets 5, staff 2). All table vacuum counts remain 0, recorded ANALYZE timestamps remain on 5 November, and analyze counts remain 2 (staff 3), exactly as in the initial capture. Statistics-view live estimates also remain unchanged. No seed data, live sales records, grants, schema or sequence values were modified by this activity.

The appropriate next step is an **approved maintenance identity** added through a reconciled Activity 4 plan. A project-scoped NOLOGIN maintenance group with table-level MAINTAIN on the five BrewPOS tables, suitable CONNECT/schema access and an authorized login is a proportionate design to review. Keep normal runtime/auditor permissions narrow; avoid broad cluster-wide maintenance or superuser membership merely to make these commands work. Ownership-based administration is an alternative only if deliberately included in that plan.

After that prerequisite is established, use the approved account to run ANALYZE and ordinary VACUUM on the selected tables, capture verbose output without permission/skip warnings, and confirm fresh maintenance timestamps/counters and preserved row counts. Do not use `--single-transaction` or VACUUM FULL. No role provisioning or follow-up maintenance was performed here, and this outstanding work is not marked complete.
