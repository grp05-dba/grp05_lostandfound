# Part E – Findings and Maintenance Report

**Project:** Group 6, HabalGo ride and booking management system. **Testing group:** Group 5. **Date:** 6 November 2026, Asia/Manila. **Environment inspected:** new local PostgreSQL 18.6 `grp00_habalgodb`, schema `habalgo`, port 5432.

**Overall result: missing setup resolved; inspection and query analysis completed; maintenance remains limited by the supplied privileges.** The initial failure was missing installed database roles, not missing source definitions. The supplied schema, sanitized role plan and documented seed were installed, after which dedicated-account checks succeeded. No successful ANALYZE/VACUUM is claimed.

## Work and evidence

| Area/account | Actual result and evidence |
|---|---|
| Prerequisite inventory/provisioning: `postgres`, setup administrator only | [Initial inventory](evidence/00_initial_inventory.txt) showed neither candidate database nor supplied roles installed. `00_database_setup`, `00_schema_setup`, `00_role_setup` and `00_seed_setup` outputs record creation of the new database, schema, roles and ten-driver sample seed. The role script's PASSWORD clauses were removed. |
| Health/roles: `habalgo_readonly_user` / `app_readonly_grp` | [Part A](part_a.md), [health output](evidence/01_health.txt): 8150 kB; eight tables, seven sequences, seventeen indexes; ten drivers and empty workflow tables; no current blockers. Installed roles match the supplied runtime/readonly plan. |
| Logs: read-only SQL account and existing OS journal reader `me` | [Part B](part_b.md), [SQL access](evidence/02_logging_access.txt), [filtered journal](evidence/07_service_log_review.txt): two initial missing-role FATALs, two expected log-function ERRORs and two maintenance-skip WARNINGs. |
| Maintenance limit: `habalgo_app_user` / `app_runtime_grp` | [Part C](part_c.md), [actual output](evidence/03_maintenance.txt): ANALYZE and ordinary VACUUM on `driver` skipped; no supplied maintenance role/privilege and no superuser retry. |
| Verification: read-only account | [Fresh session](evidence/05_verify.txt): all eight exact table counts unchanged; all maintenance counters remain zero and timestamps NULL. |
| Query analysis: runtime account | [Part D](part_d.md), [plans](evidence/04_query_plan.txt): actual driver-dropdown SELECT, scan/sort, estimated 190 versus actual ten rows, 0.105 ms execution. No personal result values captured. |

The administrator was used only to install the missing source prerequisites. Subsequent Activity 5 checks respected the source runtime/read-only boundaries without SET ROLE, new maintenance grants or owner/superuser retries. The ten seed inserts and source role/schema creation are intentional setup changes; the later inspections/query/denied-maintenance probes did not change application records or consume sequence values. No other project's data or privileges were changed.

## Prioritized actions

| Priority | Action and completion criterion |
|---|---|
| **Resolved prerequisite** | The source definitions were installed locally with password literals excluded. Direct runtime/read-only sessions now succeed. Retain the distinction between repository files and installed server state. This is not a claim of a fully verified pre-existing Activity 4 deployment. |
| **Follow-up action** | Access-control owner should approve a scoped maintenance identity; then run suitable ANALYZE/ordinary VACUUM and verify no skips, current counters/timestamps and preserved row counts. Neither supplied group has MAINTAIN. |
| **Follow-up action** | Refresh initial statistics and repeat the driver-query plan. Its 190-versus-ten row estimate is consistent with missing analysis on this fresh table. No speedup from a skipped operation is claimed. |
| **Follow-up action** | Remove password literals from upstream provisioning and configure credentials privately; rotate any values actually deployed. The original credential-bearing script was not executed/committed in this run. |
| **Follow-up action** | Cluster owner should review PUBLIC connection defaults and the generic group names before reuse across projects. Both logins can CONNECT to unrelated `postgres`; no unrelated table access was inferred. Preserve legitimate clients before changing shared ACLs. |
| **Follow-up action** | Document/configure the actual runtime database and role. README names `grp00_habalgodb`, while config defaults to `habalgo` and `postgres`; API hardcodes the `habalgo` search path. PHP deployment was not changed or launched here. |
| **Follow-up action** | Reassess workflow health and query behavior with representative bookings/payments and realistic concurrency. Current evidence covers a ten-driver seed, not full application readiness. Arrange scoped log exports/slow-query observability if needed. |
| **No action required now** | Extra name-order index, FULL vacuum, index rebuild or aggressive repeated maintenance. The measured scan/sort is reasonable for ten rows, and no dead-tuple backlog is demonstrated. |
| **No action required** | Wider auditor server-log privileges merely to suppress expected function denials. Existing OS journal access supplied scoped evidence without changing those restrictions. |

## Limitations and AI validation

Our Activity 4 HabalGo folder had no completed local plan/report; the repository's role plan was installed as a prerequisite during this work. It supplies no maintenance account and leaves PUBLIC database defaults. Full negative privilege testing, production/remote authentication, PHP UI workflows, end-user authorization and realistic load were not tested. Workflow tables remain empty. The read-only role can read operational personal information, so it is an authorized internal account, not a public reporting identity.

Live activity is a point-in-time snapshot; fresh database counters are not a complete connection audit. Service-log review covers one readable window and PID-correlated sessions, with possible gaps for pre-authorization failures, prior sessions, rotated history and other sinks. No failed-password, slow-query or unrelated application incident was fabricated. Log files were not edited and logging configuration was retained.

AI assistance (OpenAI Codex) reviewed instructions/source, prepared the password-free setup adaptation and SQL checks, provisioned local prerequisites, ran direct-account inspections and query analysis, filtered readable service messages and drafted reports. Validation used the clean source commit, setup results, direct session/current identities, catalog privileges, actual warning/error output, unchanged exact counts/counters, real execution plans and the exact source SELECT. [Provenance](evidence/08_source_query.txt) records source blobs. No real passwords, password hashes or raw driver/contact values are included in this package.

## Repository handoff

[README](README.md) indexes Parts A–E, setup/check scripts, evidence and repository instructions for Part F. [Owner feedback](owner-feedback.md) is an unsent draft. No tracker or tracking-log updates, PDF preparation, external feedback or push is claimed. Successful maintenance remains an explicit follow-up rather than a bypassed restriction.
