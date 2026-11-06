# Part B – Logs and Issue Identification

## Sources and access

At **19:08:04 +08 on 6 November 2026**, `campussafe_report` ran [02_logging.sql](sql/02_logging.sql). [Captured output](evidence/02_logging_access.txt) shows stderr logging, collector off, connections/disconnections enabled, minimum message level warning, statement logging DDL, and `log_min_duration_statement=-1 ms` (duration-based slow-query logging disabled). The account did not receive `log_directory`/`log_filename` rows.

`pg_current_logfile()` and `pg_ls_logdir()` each returned SQLSTATE **42501**, permission denied. The account lacks `pg_monitor`, `pg_read_all_stats` and `pg_read_server_files` access. No log privilege was added and the setup administrator was not substituted for the reporting account's SQL log checks.

Existing OS user `me` could read the service journal without sudo. [review_service_logs.py](review_service_logs.py) examined **1,855 readable service entries** for **6 November 00:00:00–19:08:34 +08**. It correlated backend PIDs with authorization records, selected CampusSafe database/accounts and copied only safe diagnostic formats. [Filtered evidence](evidence/07_service_log_review.txt) contains **one FATAL and two ERROR messages**. Diagnostic timestamps are UTC; add eight hours for Manila time. An authorization record does not guarantee completed session startup.

[Filesystem notes](evidence/06_service_log_access.txt) record `/var/log/postgresql` absent and `/var/lib/postgres/data/log` inaccessible to this OS user. The readable service journal supplied evidence despite SQL access limits. No log file was edited, and logging/tracking-log settings were not changed.

## Findings

| Evidence / finding | Explanation | Impact | Next step / priority |
|---|---|---|---|
| 19:01:18 +08: `role "campussafe_report" does not exist` | Our initial connection probe preceded local setup. Inventory confirmed that the supplied database/logins had not been installed. This was not a bad-password incident. | Initial project inspection could not connect. | **Resolved prerequisite:** setup installed the source schema/plan, with documented local adaptations; later direct reporting/runtime/owner connections succeeded. |
| 19:08:04 +08: reporting PID 74729 denied both log-file functions | Two deliberate Activity 5 access probes, consistent with restricted reporting privileges. | SQL log-file inspection remains unavailable to that account. | **No action required** to widen reporting permissions; use scoped approved exports when more history is necessary. |
| Source uses generic group names already present for HabalGo | Reusing those groups would mix project privilege paths. | A shared role could accumulate grants across projects. | **Resolved local setup adaptation:** CampusSafe-specific groups were used. Catalog membership checks show no CampusSafe account membership in existing HabalGo groups. Existing groups were not changed. |
| All four CampusSafe accounts have effective CONNECT to unrelated `postgres` | PUBLIC defaults in that other database remain, despite project database PUBLIC privileges being revoked. | Connection scope exceeds the source guide's expected unrelated-database denial. CONNECT does not establish unrelated table access. | **Follow-up:** authorized cluster owner should inventory legitimate clients and preserve explicit access before restricting inappropriate defaults or applying reviewed isolation controls. |
| Source names `campussafe_owner` for maintenance but installer omits it | Documentation and executable provisioning differ. Table ALL grants alone would not transfer ownership. | The installer alone would leave the documented maintenance identity unavailable. | **Resolved local prerequisite; upstream follow-up:** the documented non-superuser owner was provisioned with actual project ownership; make the upstream setup/owner procedure explicit. |

All three retained diagnostic events arise from this run's initial setup probe and SQL log-access checks. No maintenance error or additional application incident was established. The successful maintenance evidence is separate in Part C.

## Limits

No blocked query appeared in the health snapshot. No slow-query incident was established from the extract, and duration logging is disabled, so absence of messages does not demonstrate good performance. Part D measured one SELECT directly.

Coverage is limited to one readable unit/window and sessions with correlatable authorization. Pre-authorization failures, sessions opened before the window, rotated history, other sinks and unlogged behavior may be absent. No HTTP/application log audit was performed. Raw SQL, DETAIL/HINT lines, credentials and unrelated-project messages were excluded from retained service evidence. No failed-password or warning incident was invented.
