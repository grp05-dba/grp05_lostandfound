# Part E – Findings and Maintenance Report

**Project:** Group 3, OJT Management System / Project-OJT-RMA-System. **Testing group:** Group 5. **Date:** 6 November 2026, Asia/Manila. **Environment:** local PostgreSQL 18.6, `ojt_managementdb`, public schema, existing Activity 4 setup.

**Overall result: Issues found; maintenance completed.** The database is reachable and the initial snapshot shows no blockers. Routine maintenance removed 18 dead tuples while preserving the 12 seeded live rows. Cross-database connection scope and application audit coverage still require attention.

## Work performed and evidence

| Area | Account and Activity 4 responsibility | Findings and evidence |
|---|---|---|
| Health/roles | `grp03_ojt_auditor` / `grp03_ojt_readonly_grp` | [Part A](part_a.md), [health capture](evidence/01_health.txt): 8990 kB initially; 12 tables, 12 sequences, 24 indexes; one inspection session and no blocking; expected roles/representative restrictions retained. |
| Log settings/access | `grp03_ojt_dba` / `grp03_ojt_admin_grp` | [Part B](part_b.md), [SQL evidence](evidence/02_logging_access.txt): stderr logging, collector off, duration logging disabled; server log functions denied. |
| Service journal | Existing OS user `me`; no PostgreSQL role assumed | [Scoped extract](evidence/07_service_log_review.txt): 24 project ERROR records, comprising 22 Activity 4 negative tests and two current access probes; historical unrelated-database authorizations also recorded. |
| Maintenance | `grp03_ojt_dba` / inherited admin ownership | [Part C](part_c.md), [verbose results](evidence/03_maintenance.txt): 12 ANALYZE and 12 ordinary VACUUM completions, no errors/skips; 18 primary-table dead tuples removed. |
| Verification | `grp03_ojt_auditor` / read-only inspection | [Fresh-session capture](evidence/05_verify.txt): all table counts preserved; zero dead tuples; vacuum count 1 and analyze count 2 per table with current timestamps. |
| Query analysis | `grp03_ojt_app` / runtime service, serving STUDENT | [Part D](part_d.md), [plans](evidence/04_query_plan.txt): actual My requirements SELECT, three estimated/actual output rows, sequential scans/hash left join/sort; 0.110 ms execution. |

No superuser, SET ROLE, schema changes, ACL changes, reseeding or application DML was used. The audit table was inspected by permitted aggregate counts and not modified. Routine maintenance appropriately changed physical/catalog/statistical state. The original repository's application sources were not edited.

## Prioritized recommendations

| Priority | Action | Responsibility and completion criterion |
|---|---|---|
| **Immediate action** | Resolve grp03 account CONNECT access to unrelated databases. Project-local PUBLIC restrictions do not override PUBLIC privileges on Park It or `postgres`. | Authorized cluster administrator: inventory legitimate clients, preserve explicit required grants, restrict inappropriate PUBLIC CONNECT or apply reviewed isolation controls, and rerun actual connection tests. No shared permission was changed here. |
| **Follow-up action** | Implement trustworthy application audit recording. `audit_log` is empty, no user-defined triggers exist, and the earlier source assessment found no automatic audit writes. | Owning group: record actor/action/outcome within appropriate transactions, verify audit records for representative writes and protect retention/access. No audit incident was invented. |
| **Follow-up action** | Preserve documented setup fixes and repair upstream reproducibility gaps: wrong archive, PDF DDL issue, Java-required columns and configuration mismatch. | Owning group: provide an executable compatible migration and accurate private runtime configuration instructions. Activity 5 reused the previously adapted local setup. |
| **Follow-up action** | Repeat health/plans with representative submissions and real workflow volume; monitor autovacuum and statistics after loading. | Application/database owner: use realistic authorized test data and compare estimates, buffer usage and timing for different student profiles. The seeded test cannot establish load capacity. |
| **Follow-up action** | Establish a scoped operational log-view/export process and assess slow-query logging only if needed. | Environment administrator: preserve restricted SQL roles and protect credentials/personal data in exported messages. Current SQL log functions are denied; the OS journal was separately readable. |
| **No action required** | Broader privileges to silence the documented negative-test and log-access denials. | Retain the intended role boundaries. Project DBA maintenance already succeeds through ownership; cluster provisioning remains separate. |
| **No action required now** | Additional query index, VACUUM FULL, index rebuild or aggressive repeated manual maintenance. | Existing `(student_id, req_id)` index fits the query; current plan and completed small cleanup justify monitoring rather than speculative changes. |

## Limits and AI validation

This is a local seed-data inspection, not an interactive application or production workload test. Workflow tables remain empty. Initial session evidence is a snapshot, other-session visibility is restricted, and cumulative counters do not establish an error cause or complete authentication history. Existing RLS policies are absent; student-specific authorization remains an application responsibility.

Journal findings cover one readable service window and PID-correlated project sessions. SQL function restrictions, pre-authorization failures, older/rotated history and alternate sinks limit completeness. Raw statements and secrets were excluded from the retained extract. No failed-password or slow-query incident was established from absent evidence.

AI assistance (OpenAI Codex) reviewed the Activity 5 PDF, Activity 4 setup and current source; prepared/executed checks and maintenance; filtered readable service messages; and drafted these reports. Validation used separate direct account identities, real PostgreSQL catalog/command output, actual maintenance completions, fresh-session timestamps/counters, unchanged 12-table exact counts and the real source query. The fetched clean `main` checkout still matched commit `6a899fbc5882c2916be0af3a91457b1c0c54084b`; [source provenance](evidence/08_source_query.txt) records the query constant and caller. No synthetic workload rows, invented incidents, passwords or password hashes are included.

## Repository handoff

The [README](README.md) indexes Parts A–E, SQL, evidence, reproduction commands and the repository portion of Part F. [Owner feedback](owner-feedback.md) is prepared as an unsent draft. Tracker/tracking-log updates and PDF documentation were excluded by the user's instructions; no external feedback or push is claimed.
