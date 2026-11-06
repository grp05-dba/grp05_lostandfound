# Part E – Findings and Maintenance Report

**Project:** Group 2, Park It – Database Management System. **Testing group:** Group 5. **Inspection date:** 6 November 2026, Asia/Manila. **Environment:** existing local `grp_parkitdb`, PostgreSQL 18.6, public schema, Unix-socket connections on port 5432.

**Overall result: Issues found; routine maintenance completed.** The database was reachable with no current blocking observed. It is empty, so application readiness and realistic performance remain unverified. Existing overly broad database CONNECT access remains unresolved.

## Accounts and evidence

| Work | Account / Activity 4 role | Evidence and interpretation |
|---|---|---|
| Health, roles and access checks | `park_it_auditor` / `park_it_readonly_grp` | [Part A](part_a.md), [health output](evidence/01_health.txt): 7990 kB initially; five tables, five sequences, nine indexes; all exact counts zero; one inspection session, no blockers. |
| Log configuration and function access | `park_it_dba` / `park_it_admin_grp` | [Part B](part_b.md), [SQL output](evidence/02_logging_access.txt): stderr logging, collector off, duration logging disabled; log functions denied. |
| Available service journal | Existing OS user `me`, no database role substitution | [Scoped journal extract](evidence/07_service_log_review.txt): 17 ERROR and 4 FATAL messages across historical setup/test sessions and today's probes. Findings were interpreted individually rather than treated as current application failures. |
| Maintenance | `park_it_dba` / `park_it_admin_grp` | [Part C](part_c.md), [commands/results](evidence/03_maintenance.txt): effective MAINTAIN verified; ANALYZE and ordinary VACUUM completed on all five tables; two dead vehicle tuples removed. |
| Maintenance verification | `park_it_auditor` / `park_it_readonly_grp` | [Fresh-session output](evidence/05_verify.txt): each table has vacuum count 1 and analyze count 2; all live/dead estimates and exact live counts zero. |
| Query plan | `park_it_app` / `park_it_runtime_grp` | [Part D](part_d.md), [plans](evidence/04_query_plan.txt): actual monitoring SELECT; sequential scan, nested loops and sort; 0 actual rows, 0.104 ms execution. |

No SQL was run as superuser. All accounts and expected role memberships remain present, with no unexpected elevated attributes. Auditor column restrictions remain intact. Database-function log denial was respected; the separate OS journal was readable through the current user's existing access. No grants, ownership, schema or application data were changed.

## Prioritized recommendations

| Priority | Finding and action | Responsibility / completion criterion |
|---|---|---|
| **Immediate action** | Resolve the retained `PUBLIC` database CONNECT scope: the three Park It accounts can connect to `postgres`, and historical grp03 connections reached `grp_parkitdb`. Review legitimate access before changing shared ACLs. | Authorized cluster administrator; preserve explicit intended access, restrict inappropriate defaults and repeat actual permitted/denied connection tests. This activity did not change ACLs. |
| **Follow-up action** | Establish representative application setup/data. All five tables, including parking zones and staff accounts, are empty. | Application owner and authorized provisioning account; safely initialize required zone/accounts, validate ordinary workflows using `park_it_app`, then reassess health/performance. |
| **Follow-up action** | Reconcile repository provenance: previous Activity 4 files cite a different repository. | Documentation owner; record the intended canonical source and compare versioned schema/configuration before future upgrades. Current inspection used the URL supplied for Activity 5. |
| **Follow-up action** | Review historical missing-table errors and administrative disconnects if unexplained or recurring; use explicit `-U` for connections. | Environment owner; establish initialization order and reason for terminations. No continuing missing-table fault appeared in current checks. |
| **Follow-up action** | Improve observability only as needed: arrange scoped log exports and assess an appropriate slow-query threshold, retention and redaction policy. | Authorized environment administrator; avoid granting runtime/auditor server-wide log access. No logging settings were changed. |
| **Follow-up action** | Repeat query analysis with representative history and concurrent polling; assess the conditional partial index only if evidence supports it. | Application/database owner; compare plans and costs before implementation. No index added. |
| **No action required** | Deliberate Activity 4 permission denials and today's log-access denials demonstrate expected restrictions. The mistaken database-MAINTAIN probe was corrected to a table-level check. | Retain the correct privileges and final scripts; do not grant broader access merely to suppress expected errors. |
| **No action required now** | Additional aggressive vacuum, FULL vacuum or index rebuilding. Existing maintenance completed, and autovacuum is enabled. | Monitor after real workload starts and choose later maintenance based on evidence. |

## Limitations and validation

This was a local, empty database inspection rather than an end-to-end PHP workflow or production load test. Only one live session was visible at the initial snapshot. Lack of current blocking does not establish long-term health. Cumulative counters have no known reset boundary, and session-failure counters are not a complete connection-error audit.

Journal review covers a readable service/window and PID-correlated sessions; it does not cover all prior history, every pre-authorization failure or every log sink. SQL log functions and some settings were restricted. The retained extract excludes raw SQL and secrets. The original databases were not rebuilt or reseeded to manufacture evidence, and unrelated database permissions were not changed.

The GitHub repository's current schema/application query were read through connected tools at commit `d369a457ce2dc88a024428513360f0ad76473f43`; source-query provenance is in [08_source_query.txt](evidence/08_source_query.txt). The local object inventory aligns with its five-table design; identical repository history is not claimed.

AI assistance inspected the PDF and prior reports, reviewed source, prepared and executed SQL and the journal-filter script, interpreted results and drafted these files. Validation used direct independent logins, session/current-user evidence, catalog privileges, actual command output, maintenance completion messages, fresh-session counters, unchanged exact row counts and the real application's SELECT text. Generated conclusions were checked against those outputs. One invalid initial privilege probe is disclosed in Part B and corrected in the final script. No synthetic incidents, benchmark rows, passwords or hashes are included.

## Repository handoff

The repository portion of Part F is organized in this folder: [README and reproduction instructions](README.md), SQL scripts, timestamped command evidence, source provenance, a filtered journal review and an [owner feedback draft](owner-feedback.md). No feedback has been sent. Tracker/log updates and PDF preparation were excluded at the user's request; the full administrative submission process is therefore not claimed complete.
