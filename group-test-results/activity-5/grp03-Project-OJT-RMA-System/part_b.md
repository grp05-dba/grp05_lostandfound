# Part B – Logs and Issue Identification

## Sources and access

At **17:59:14 +08 on 6 November 2026**, `grp03_ojt_dba` ran [02_logging.sql](sql/02_logging.sql). [Actual output](evidence/02_logging_access.txt) shows `log_destination=stderr`, `logging_collector=off`, connection/disconnection logging enabled, `log_min_messages=warning`, `log_statement=ddl`, and `log_min_duration_statement=-1 ms` (duration-based slow-query logging disabled). `log_directory` and `log_filename` were not visible in this login's settings result.

`pg_current_logfile()` and `pg_ls_logdir()` both returned SQLSTATE **42501**, permission denied. The account has no `pg_monitor`, `pg_read_all_stats` or `pg_read_server_files` membership. These restrictions were retained; project ownership does not automatically grant server-log access.

The existing OS user could read the PostgreSQL service journal without sudo. [review_service_logs.py](review_service_logs.py) inspected **1,456 service entries** from **2026-11-06 00:00:00 through 17:59:36 +08**. It correlated backend PIDs with their preceding authorization records and retained only safe diagnostic formats for `ojt_managementdb` or the three grp03 logins. Database identity came from the authorization's database field, not `application_name`. [Filtered evidence](evidence/07_service_log_review.txt) records **24 ERROR messages**, with no FATAL or WARNING messages among the correlated project-session diagnostics.

[Filesystem notes](evidence/06_service_log_access.txt) record that `/var/log/postgresql` is absent and `/var/lib/postgres/data/log` is inaccessible to the OS reader. The readable journal supplied useful evidence despite SQL log-function limits. No server log or logging configuration was changed.

## Findings, interpretation and action

| Evidence | Explanation | Impact | Next step and priority |
|---|---|---|---|
| 17:01:45 +08, runtime PID 28802: ten table, sequence, schema, SET ROLE and cluster-creation denials | Matches the deliberate negative tests in [Activity 4 verification](../../activity-4/grp03-Project-OJT-RMA-System/part_d.md), including protected user/attendance updates and audit writes. | Expected service-account restrictions held; these are not established application incidents. | **No action required** for the planned tests. Investigate if a permitted normal workflow later produces the same errors. |
| 17:01:48 +08, auditor PID 28823: ten protected-column, write, sequence, schema, SET ROLE and cluster-creation denials | Matches the Activity 4 auditor's forbidden operations. | Sensitive columns and write paths remained restricted. | **No action required**; do not widen auditor privileges to suppress test errors. |
| 17:01:49 +08, DBA PID 28833: CREATE DATABASE and CREATE ROLE denied | The project DBA intentionally lacks cluster provisioning attributes. | Project maintenance is permitted through ownership; cluster provisioning is outside this account's duties. | **No action required**; use the designated cluster owner only for separately authorized provisioning. |
| 17:59:14 +08, DBA PID 44880: `pg_current_logfile` and `pg_ls_logdir` denied | Two deliberate Activity 5 log-access probes. | This role cannot directly inspect server log files through those SQL functions. | **Follow-up if more history is needed:** obtain a scoped administrator export or approved service view; keep server-file privileges restricted. |
| Journal shows each grp03 login authorized once to `grp_parkitdb`; current ACL checks also allow unrelated `postgres` | Earlier Activity 4 isolation tests reached Park It through its PUBLIC CONNECT grant. Current grp03 database PUBLIC privileges are restricted, but that does not remove grants on other databases. | Connection boundaries exceed the intended project scope. Successful connection does not establish unrelated table privileges. | **Immediate action:** authorized cluster administrator should inventory legitimate users, preserve explicit required access and restrict inappropriate PUBLIC CONNECT or use reviewed isolation controls. Retest afterward. No shared ACL was changed here. |
| `audit_log` has zero rows and there are no user-defined triggers; earlier source review found no automatic audit INSERT | The application audit table alone does not provide a working change history. PostgreSQL service logging and application audit logging have different coverage. | Application changes may lack attributable before/after or actor history. | **Follow-up:** owning group should implement and test transaction-aware audit recording, protect records, and define retention. No audit records were inserted or edited. |

The observed error total is fully explained by **22 Activity 4 negative-test errors plus two Activity 5 access probes**. No unrelated failure was attributed to the application from this extract. There is no basis to invent a failed-password incident: the filtered records do not demonstrate one.

## Current activity and coverage limits

Part A found no current blockers or other running project query. The journal extract establishes no slow-query incident; duration logging is disabled, so this is not evidence that every query has been fast. Part D measures one SELECT directly.

The review covers one readable service unit/window and sessions whose preceding authorization can be correlated. Pre-authorization failures, sessions opened before the window, rotated history, other log sinks and unlogged application behavior may be absent. Zero database `sessions_fatal` is not a complete authentication audit. No application GUI/error log was reviewed or fabricated.

Raw SQL, DETAIL/HINT lines, credentials and other projects' diagnostics were excluded from retained journal evidence. Only historical grp03 account connections to Park It are listed because they directly concern grp03's access boundary. The scripts read logs without changing them; no tracker or tracking log was touched.
