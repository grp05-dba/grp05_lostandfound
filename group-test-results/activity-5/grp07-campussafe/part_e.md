# Part E – Findings and Maintenance Report

**Project:** Group 7, CampusSafe hazard and safety reporting system. **Testing group:** Group 5. **Date:** 6 November 2026, Asia/Manila. **Environment:** new local PostgreSQL 18.6 `grp07_campussafedb`, public schema, port 5432.

**Overall result: setup completed with disclosed adaptations; routine maintenance and query analysis completed; connection-scope follow-up remains.** Nine tables were analyzed/vacuumed under the documented non-superuser owner, and all 129 seeded rows were preserved.

## Work and evidence

| Work / account | Observed result |
|---|---|
| Prerequisite installation: cluster setup administrator only | Initial project database/logins were absent. The source schema/seed reset operations and password clauses were removed from local setup copies; source groups were prefixed to avoid HabalGo's existing roles. The documented `campussafe_owner`, omitted by the source installer, was provisioned with actual project ownership. `00_*` setup evidence records these changes. |
| Health/roles: `campussafe_report` / local readonly group | [Part A](part_a.md), [health evidence](evidence/01_health.txt): 8630 kB initially; nine tables/sequences, twenty-four indexes; one inspection session, no blockers; three aggregate integrity checks returned zero violations. |
| Private-table counts: `campussafe_app` / local runtime group | Six application users and five application roles counted without reading credentials or personal row values. Reporting grants were not widened. |
| Logs: reporting SQL account and existing OS reader `me` | [Part B](part_b.md), [SQL access](evidence/02_logging_access.txt), [journal extract](evidence/07_service_log_review.txt): one resolved initial missing-role failure and two expected SQL log-function denials. |
| Maintenance: direct `campussafe_owner`, no superuser attributes | [Part C](part_c.md), [verbose output](evidence/03_maintenance.txt): nine ANALYZE and nine ordinary VACUUM completions without errors/skips; no dead tuples needed removal. |
| Verification: fresh reporting and runtime sessions | [Reporting output](evidence/05_verify.txt), [runtime counts](evidence/05_runtime_counts_after.txt): all exact counts preserved, zero dead tuples, vacuum count 1/analyze count 2 per table and fresh timestamps. |
| Query analysis: runtime account | [Part D](part_d.md), [plans](evidence/04_query_plan.txt): real category-summary SELECT, scans/hash right join/hash aggregate/sort, matched estimates, six groups and 0.185 ms execution. |

The administrator was used for setup, not for Activity 5 maintenance/inspection or a superuser retry. The documented owner provided actual table ownership; runtime/reporting/backup MAINTAIN remained false. No application records were changed after seeding, no attachment or audit-history row was edited, and no other project's data/roles/grants were changed. Setup intentionally created the new project resources and ownership/default-privilege configuration; maintenance updated statistics/visibility/storage as expected.

## Prioritized recommendations

| Priority | Action and completion criterion |
|---|---|
| **Resolved prerequisite** | Missing project setup was installed locally; source generic groups were replaced with CampusSafe-specific groups and all passwords omitted from the setup copy. The documented owner identity now exists and maintained this project successfully. |
| **Follow-up action** | Authorized cluster owner should review unrelated-database CONNECT defaults: all four CampusSafe accounts can still CONNECT to `postgres`, contrary to the source guide's denial expectation. Preserve legitimate explicit access before restricting defaults or applying reviewed isolation controls; rerun actual connection tests afterward. No unrelated table access was inferred or attempted. |
| **Follow-up action** | Owning group should align installer and role documentation: provision/document the non-superuser owner and real ownership, use project-specific group names and document secret-free credentials and migration-owner defaults. The local adaptations are not upstream fixes. |
| **Follow-up action** | Review broad automatic future-table runtime grants before migrations. Existing audit/action tables are write-restricted as planned, while the source default grants include UPDATE for future tables; future objects need a deliberate privilege review. |
| **Follow-up action** | Reassess health, automatic maintenance and aggregate-query behavior with representative volume and concurrency; keep statistics fresh after substantial loads. Current evidence is a seeded local sample, not production capacity or end-to-end PHP workflow validation. |
| **Follow-up action** | Establish scoped operational log export/retention and evaluate slow-query observability if needed. Current SQL file-log functions are restricted and duration logging is disabled; retain appropriate reporting boundaries. |
| **No action required now** | Additional category index, speculative query rewrite/cache, FULL vacuum or rebuild. The measured plan is reasonable for the present workload, estimates match observed rows and routine maintenance completed. |
| **No action required** | Widen reporting privileges to read `app_user` or server log files. Approved aggregate counts and separate OS journal access supplied the required evidence without exposing hashes. |

## Limits and AI validation

The local Activity 4 folder lacked completed setup/report files; the supplied plan plus its documented owner were installed as prerequisites during this work. A full Activity 4 negative-test suite, backup/restore, PHP route authentication, attachment-file validation, remote/password authentication and realistic load testing were not performed. Group-name changes and owner provisioning are disclosed local adaptations, not an identical unmodified installer run.

Session evidence is a snapshot. Fresh database counters and a readable service-journal window are not a complete incident audit; prior sessions, pre-authorization failures, rotated history and other sinks may be absent. No failed-password, maintenance-error or slow-query incident was fabricated. No log files were edited and logging configuration was retained.

AI assistance (OpenAI Codex) reviewed instructions/source, prepared safe local setup adaptations, installed prerequisites, executed role-appropriate checks and maintenance, filtered readable service messages and drafted this package. Validation used the clean source commit, schema/seed/setup outputs, actual role ownership/memberships/privileges, direct session identities, aggregate-only counts from appropriate accounts, maintenance completion messages/counters, three sanity checks and the exact application SELECT. [Source provenance](evidence/08_source_query.txt) records commit `3684b97cfa8b8c6624d039eda461551ade774701`, query/caller, source blobs and the documented maintenance-owner role. No password literals, hashes, raw seed data or personal result values are included.

## Repository handoff

The [README](README.md) indexes Parts A–E, setup/check scripts, execution evidence and the repository portion of Part F. [Owner feedback](owner-feedback.md) is prepared but unsent. No tracker/tracking-log updates, PDF preparation, external feedback or push is claimed. The unresolved connection-scope finding remains visible rather than being marked fully secured.
