# Part C – Routine Maintenance

## Review and choice

[Initial inspection](evidence/01_health.txt) found nine tables, nine sequences and twenty-four indexes, with **129 exact seeded rows** across the tables. Dead-tuple estimates were zero. Most tables had no planner statistics; status history already had an automatic analysis recorded at 19:06:12 +08. No manual analyze/vacuum timestamp existed. Autovacuum was enabled, observed XID ages were 53–61 and table/index sizes were 32–112 kB. These observations justify a small post-load baseline, not a bloat or wraparound emergency.

The index inventory includes report-category/status/submission-time indexes and keys supporting joins. No index rebuild or new index was justified by definitions alone; this was not a physical corruption check.

Before execution, the purposes/impacts were assessed:

- **ANALYZE** establishes or refreshes planner estimates after the sample load. Sampling consumes CPU/I/O and takes locks; the small local idle database is suitable.
- **Ordinary VACUUM** maintains reusable space, visibility and freeze information. No dead-tuple removal was expected; one baseline across the nine small tables is proportionate.
- **VACUUM with ANALYZE** refreshes statistics after vacuum. Explicit ANALYZE followed by the combined command intentionally demonstrates both required operations. Repeating both is unnecessary as a standing schedule.

Ordinary vacuum generally permits normal DML, but can conflict with DDL/maintenance and briefly request a stronger lock for tail-page truncation. The initial snapshot had no competing session. `lock_timeout=3s` and `statement_timeout=30s` bound waits/work. FULL vacuum and rebuilds were not needed.

## Authorized maintenance identity

The source's [user-role documentation](https://github.com/jeffersonorpesa2-ops/grp07-campussafe/blob/3684b97cfa8b8c6624d039eda461551ade774701/docs/user-roles.md) explicitly assigns VACUUM/ANALYZE to non-superuser **`campussafe_owner`**. The SQL installer did not create it; the local prerequisite step implemented that documented identity and actual database/table/sequence ownership in [setup/04_owner.sql](setup/04_owner.sql). This is disclosed setup work on the new database, not an undocumented privilege escalation after a denied command.

Runtime, reporting and backup accounts still have no MAINTAIN. The owner lacks SUPERUSER, CREATEDB, CREATEROLE, REPLICATION and BYPASSRLS. It connected directly, with matching session/current identities and no SET ROLE. The cluster setup administrator did not run Activity 5 maintenance.

## Commands and outcomes

[03_maintenance.sql](sql/03_maintenance.sql) checked effective MAINTAIN on all nine tables, then explicitly ran ANALYZE and ordinary VACUUM ANALYZE, for example:

```sql
ANALYZE VERBOSE public.hazard_report;
VACUUM (VERBOSE, ANALYZE) public.hazard_report;
```

The same commands ran on `app_user`, `assignment`, `attachment`, `campus_location`, `hazard_category`, `maintenance_action`, `report_status_history` and `role`. VACUUM ran standalone, without a transaction wrapper or psql `--single-transaction`.

Execution at **19:08:05 +08 on 6 November 2026** produced **nine ANALYZE and nine VACUUM completions**, no errors/warnings/skips, and zero dead tuples removed. [Verbose evidence](evidence/03_maintenance.txt) records each table's live rows and any separate TOAST maintenance; those auxiliary outputs are not extra application tables or duplicated counts. This baseline does not demonstrate disk-space savings or a measured speedup.

Fresh reporting/runtime sessions at **19:08:07 +08** verified the results:

- [Reporting verification](evidence/05_verify.txt): all nine tables show current manual timestamps, `vacuum_count=1`, `analyze_count=2`, zero dead tuples and zero modifications-since-analysis. Counts of the seven permitted tables are unchanged.
- [Runtime verification](evidence/05_runtime_counts_after.txt): six application users and five application roles remain, matching [before counts](evidence/00_runtime_counts_before.txt), without exposing any row values.

Together these preserve all **129 live rows**. The sample installation intentionally created that data before health inspection; maintenance/checks performed no application DML or sequence resets. Maintenance itself updates catalog/statistics, visibility and storage as intended. The separate setup work created roles/objects and transferred project ownership; it is not omitted from the change record.

**Recommendation:** retain autovacuum, analyze after substantial future loads and monitor dead tuples/modifications and maintenance timestamps under actual workload. A fixed aggressive manual schedule or FULL vacuum is not supported by this small dataset.
