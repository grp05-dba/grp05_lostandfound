# Part B – Logs and Issue Identification

## What was reviewed

On 6 November 2026, the direct `park_it_dba` login inspected visible PostgreSQL logging settings using [02_logging.sql](sql/02_logging.sql). [Captured output](evidence/02_logging_access.txt) shows:

| Setting | Value | Meaning |
|---|---|---|
| `log_destination` | `stderr` | Server messages go to stderr; the service journal was checked as a possible sink. |
| `logging_collector` | `off` | No collector-managed file was assumed. |
| `log_connections`, `log_disconnections` | `on` | Connection lifecycle messages are enabled. |
| `log_min_messages` | `warning` | Warning/error messages meet this threshold. |
| `log_statement` | `ddl` | DDL is logged; ordinary SELECT/DML statements are not comprehensively logged by this setting. |
| `log_min_duration_statement` | `-1 ms` | Duration-based slow-query logging is disabled. |

`log_directory` and `log_filename` were not returned to this login. `pg_current_logfile()` and `pg_ls_logdir()` both returned SQLSTATE `42501`, permission denied. The DBA has no `pg_monitor`, `pg_read_all_stats` or `pg_read_server_files` membership. These are expected access limits, not justification to grant server-wide file access.

The current OS user could read `journalctl -u postgresql` without sudo. The [review script](review_service_logs.py) examined **1,432 readable service entries** from **2026-11-06 00:00:00 through 17:41:21 +08:00**. It correlated backend PIDs with preceding connection-authorization records and copied only allowlisted diagnostic messages for `grp_parkitdb` or the three Park It logins. It did not use `application_name` as proof of database identity. [Evidence](evidence/07_service_log_review.txt) contains **17 ERROR and 4 FATAL** records within that project scope. Timestamps in its diagnostic rows are UTC; add eight hours for Manila time.

The [filesystem/service-access notes](evidence/06_service_log_access.txt) also record that `/var/log/postgresql` does not exist and `/var/lib/postgres/data/log` is inaccessible to the current OS user. The service journal provided useful evidence despite the database-function restrictions. No server log, logging setting or tracker log was modified.

## Findings

| Evidence (Manila time, 6 Nov) | Explanation | Impact | Recommended next step / priority |
|---|---|---|---|
| 00:53:20 and 00:53:38, PID 101674, `postgres` / `grp_parkitdb`: `relation "vehicle" does not exist` | Historical query could have run before schema creation or with an unsuitable search path. The retained excerpt omits raw SQL, so the exact cause is unconfirmed. Current catalog and qualified queries find the table. | Queries fail while the relation is absent or not resolved. This is not evidence of current data loss. | **Follow-up:** confirm initialization order and use schema-qualified queries; reproduce only if it recurs. |
| 02:06:19, PIDs 101674, 101553 and 102055: `terminating connection due to administrator command` | Explicit administrative connection termination, not a demonstrated server crash. The operator and reason are not established by the excerpt. | Clients are disconnected and in-progress transactions may roll back. The three events are consistent with the current `sessions_killed=3` counter. | **Follow-up:** confirm whether planned test cleanup/restart explains the events; avoid terminating active work without coordination. |
| 16:21:11, attempted `me` / `grp_parkitdb`: `role "me" does not exist` | A local client likely omitted `-U` and defaulted to the OS username. This is a failed connection caused by a nonexistent role, not proof of a bad password or attack. | That client cannot open its database session. | **Follow-up:** use the documented explicit login. No need to create an unrestricted `me` account. |
| 16:23:15–16:23:17, 12 ERROR records across the runtime, auditor and DBA accounts | These table/schema/CREATE DATABASE/CREATE ROLE denials match the deliberate negative tests in [Activity 4 Part E](../../activity-4/grp02-parkit/part_e.md). The auditor's repeated vehicle denials cover write attempts; staff access denial covers the protected column. | Expected restrictions held. Treating these as application incidents would misclassify test evidence. | **No action required** for these deliberate denials. Investigate only if normal permitted workflows produce similar errors. |
| Historical successful connections by each Park It login to `postgres`; additional grp03 logins authorized to `grp_parkitdb` | Journal authorization records and Part A's ACL checks show broad database CONNECT paths. Successful connection alone does not establish table access. | Project connection boundaries are wider than the intended plan. | **Immediate action:** authorized cluster owner should review legitimate users and restrict inappropriate `PUBLIC` CONNECT while preserving needed explicit grants; rerun connection tests afterward. No grants were changed here. |
| 17:38:01, `park_it_dba`: `unrecognized privilege type: "MAINTAIN"` | An Activity 5 diagnostic incorrectly checked MAINTAIN as a database privilege. The check was corrected to table `has_table_privilege`; this was our inspection error, not an application failure. | The failed SELECT returned no privilege result and made no data or grant change. | **No action required:** final scripts use the corrected table-level check, and actual maintenance succeeded. |
| 17:39:33, `park_it_dba`: denied `pg_current_logfile` and `pg_ls_logdir` | These two deliberate Activity 5 probes confirm restricted server-log function access. | SQL log-file inspection is unavailable to this role; OS journal coverage is separate. | **No action required** to bypass the restriction. Arrange a scoped log export if further history is needed. |

The historical and current diagnostics account for all 17 ERROR and 4 FATAL records in the scoped extract: two missing-relation errors, twelve Activity 4 denials, one inspection-query error, two log-function denials, three terminated sessions and one nonexistent-role failure.

## Limits and long-running activity

No current blocked session was observed in Part A. No additional slow-query incident was established from the reviewed excerpts; duration logging is disabled, and no latency threshold can be assessed from its absence. The selected safe query was measured directly in Part D.

Coverage is limited to the current OS user's readable unit journal and selected window. Sessions authorized before the window, authentication failures without a correlatable authorization, rotated history, other sinks and unlogged errors may be missing. The raw journal is not committed: SQL/DETAIL/HINT lines, credentials and unrelated-project diagnostics were excluded. Counts are scoped observations, not a complete lifetime incident count. No application HTTP logs were reviewed, so none of these server errors is automatically attributed to a PHP request.
