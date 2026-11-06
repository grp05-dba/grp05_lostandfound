# Part B – Logs and Issue Identification

## Reviewed sources and access

At **18:28:49 +08 on 6 November 2026**, `habalgo_readonly_user` ran [02_logging.sql](sql/02_logging.sql). [Actual output](evidence/02_logging_access.txt) shows stderr logging, collector off, connection/disconnection logging on, `log_min_messages=warning`, `log_statement=ddl`, and `log_min_duration_statement=-1 ms` (duration logging disabled). `log_directory` and `log_filename` were not returned to this account.

`pg_current_logfile()` and `pg_ls_logdir()` each returned SQLSTATE **42501**, permission denied. The account has no `pg_monitor`, `pg_read_all_stats` or `pg_read_server_files` membership. Those restrictions were retained. The provisioning administrator was not reused to read SQL log files.

The existing OS user could read the service journal without sudo. [review_service_logs.py](review_service_logs.py) inspected **1,640 service entries** in **6 November 00:00:00–18:29:23 +08** and retained safe diagnostics correlated with HabalGo account/database authorization records. [Filtered evidence](evidence/07_service_log_review.txt) contains **two FATAL, two ERROR and two WARNING** messages. Its diagnostic timestamps are UTC; add eight hours for Manila time. An authorization record is not proof that session startup completed: the initial nonexistent-role FATAL messages follow such records.

[Filesystem notes](evidence/06_service_log_access.txt) record that `/var/log/postgresql` is absent and `/var/lib/postgres/data/log` is inaccessible. The OS journal supplied evidence despite SQL function restrictions. No log files were edited or logging/tracking-log settings changed.

## Findings and interpretation

| Evidence, 6 November Manila time | Explanation | Impact | Next step / priority |
|---|---|---|---|
| 18:20:37: `role "habalgo_readonly_user" does not exist` and `role "habalgo_app_user" does not exist` | Our initial connection probes reached the server before the supplied roles/database were installed. The source definitions existed; local provisioning was missing. These are not failed-password incidents. | Neither project account could inspect the database at that point. | **Resolved prerequisite:** inventory confirmed absence; sanitized source setup installed the database/roles; subsequent direct logins succeeded. Do not confuse source files with installed server state. |
| 18:28:49: denied `pg_current_logfile` and `pg_ls_logdir` for the read-only account | Two deliberate Activity 5 log-access probes. | SQL server-file log inspection is unavailable to that role; separate OS access is available. | **No action required** to widen the auditor role. Use scoped approved exports if further history is required. |
| 18:28:50: permission denied to analyze/vacuum `driver`, skipping it | Deliberate maintenance-boundary demonstration. The supplied runtime/read-only role plan grants no MAINTAIN and the tables belong to `postgres`. | Neither command maintained the table. Planner statistics remain uninitialized; maintenance is outstanding despite command tags/zero process status. | **Follow-up:** approve a scoped maintenance identity in the role plan, then refresh statistics and run proportionate ordinary vacuum with verification. Do not give the normal runtime superuser access. |
| Catalog shows retained PUBLIC database CONNECT/TEMPORARY and effective access to unrelated `postgres` | The source plan adds intended grants without restricting default PUBLIC database access. | Project connection scope is wider than intended; no unrelated table privilege is established by CONNECT. | **Follow-up:** authorized cluster owner should review legitimate clients and preserve explicit required grants before changing shared defaults/isolation controls. |
| Source role script contains password literals | Executing or committing the original text can expose credentials in scripts/logging workflows. Whether a literal is a deployed secret was not established. | Reuse may propagate insecure credentials or disclose them. | **Follow-up:** use secret-free provisioning and private credential configuration; remove literals upstream and rotate any values actually used. This run removed all PASSWORD clauses before execution/commit. |

All six retained diagnostic events are accounted for by this activity's initial setup probes and later permission checks. No other application incident was inferred or invented from the reviewed records.

## Coverage limitations

No current blocking appeared in Part A. No slow-query incident was established; disabled duration logging means absence of slow-query messages cannot prove good performance. Part D measured one SELECT directly.

The review covers a readable service unit/window and sessions whose authorization can be correlated. Pre-authorization failures, sessions opened before the window, rotated history, other sinks and unlogged behavior may be absent. Fresh database counters are not a comprehensive historical connection audit. No HTTP/application error logs were reviewed. Raw SQL, DETAIL/HINT lines, passwords and unrelated-project diagnostics were excluded from retained journal output.
