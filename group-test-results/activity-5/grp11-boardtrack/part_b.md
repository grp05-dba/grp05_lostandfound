# Part B - Logs and Issue Identification

## Sources and retained scope

The existing OS user reviewed **165 lines** from the dedicated G11 cluster's stderr file redirected by pg_ctl. [Filtered log evidence](evidence/log_review.txt) and [structured events](evidence/log_review.json) retain only first ERROR/WARNING/FATAL/PANIC lines. The reviewed diagnostic timestamps span **2026-11-06 20:32:36.208 +08** through **2026-11-06 21:08:43.529 +08**; all are displayed with `+08` Manila offset. STATEMENT, DETAIL, CONTEXT and application-row values were excluded; raw log files were not copied to the repository.

Retained diagnostics: **66 ERROR, 9 FATAL, 0 WARNING, 0 PANIC**. These are log severity counts, not a count of failed passwords or production incidents. Permission-related FATALs are distinct from the pg_stat_database fatal-session counter.

[Logging settings](evidence/03_logging_settings.txt) show `log_destination=stderr`, collector off, `log_statement=none`, `log_min_messages=warning`, and `log_min_duration_statement=-1` (duration logging disabled). `log_connections` is an empty list/disabled; `log_disconnections=off`. The log is available because pg_ctl redirects stderr to a local file. No logging setting was changed.

The existing reporting login's `pg_current_logfile()` and `pg_ls_logdir()` probes were each denied with **42501**: [current logfile](evidence/log_access_current-logfile.txt), [directory listing](evidence/log_access_list-logdir.txt). Those expected restrictions were retained; the database provisioning superuser was not used to bypass them. The already-accessible OS log supplied scoped evidence.

## Findings and interpretation

| Evidence | Plausible explanation | Impact / priority / next step |
|---|---|---|
| Table/sequence/schema/function, role/database creation and ownership denials | Deliberate Activity 4 negative tests in this same lab; compare [recorded tests](../../activity-4/grp11-boardtrack/evidence/verification.txt) | Expected access enforcement, not evidence of an ordinary app outage. No privilege expansion is required merely to remove expected test errors. |
| Nine FATAL CONNECT denials to unrelated lab/postgres/template1 databases | Activity 4 tested three restricted logins against three unrelated databases | Expected isolation. No failed-password claim; retain intended database access controls. |
| Wrong-database guards and lease-overlap/room-status probes | Known safety/constraint tests, documented in Activity 4 | Expected safeguards. Do not treat them as spontaneous corruption or deployment failure. |
| Two denied log-access SQL functions | Intentional Activity 5 reporting-account probes | No action to widen reporting privileges; use scoped approved OS exports. |
| No slow-query evidence available from duration logs | Duration logging is disabled, and no workload was running during this inspection | Absence of messages does not prove good workload performance. Use bounded EXPLAIN measurements here; approve suitable duration monitoring before diagnosing future live slowness. |
| Initial abandoned-session counter = 1 | Controlled server/application shutdowns are a plausible contributor, but cause is not established | Follow-up: correlate future test shutdown times and session lifecycle; enable suitable connection observability only through an approved configuration change. |

All retained first-line diagnostics fit the recorded permission, guard, constraint or log-function test categories. No unaccounted production incident was established. There were no WARNING/PANIC entries in this retained window. This assessment does not certify raw/rotated/unavailable logs or later application runs.

## Coverage limits

The log covers only the new G11 lab and retained review window. Earlier services, rotated history, logs from other hosts and PHP/Java/Node application logs were not reviewed in Activity 5. Connection logging is off, so authorization histories and abandoned-session causes cannot be reconstructed fully. No SQL DETAIL/STATEMENT or sensitive record values were retained. Point-in-time blocking checks and short local query measurements cannot replace historical performance monitoring.
