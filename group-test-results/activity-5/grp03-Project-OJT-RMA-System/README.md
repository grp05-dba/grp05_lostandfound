# Activity 5 – Group 3 OJT Management System

Group 5's monitoring and maintenance package for the existing local `ojt_managementdb`, executed **6 November 2026**. Start with [Part E](part_e.md) for results and recommendations.

| Required part | File |
|---|---|
| A – Database health and activity | [part_a.md](part_a.md) |
| B – Logs and issues | [part_b.md](part_b.md) |
| C – Routine maintenance | [part_c.md](part_c.md) |
| D – Query performance | [part_d.md](part_d.md) |
| E – Findings/report and AI declaration | [part_e.md](part_e.md) |

## Part F – Repository materials

All work is kept in our group's own per-project results folder. The owning group's source was read from a clean temporary checkout, refreshed using `git fetch origin`; no application source was edited. Reviewed repository: [swvenz/Project-OJT-RMA-System](https://github.com/swvenz/Project-OJT-RMA-System), `main`, commit `6a899fbc5882c2916be0af3a91457b1c0c54084b`. The current local database retains the schema compatibility additions documented in Activity 4.

| Reproducible material | Actual evidence |
|---|---|
| [sql/01_health.sql](sql/01_health.sql) – auditor checks, role comparison, objects and counts | [01_health.txt](evidence/01_health.txt), before maintenance |
| [sql/02_logging.sql](sql/02_logging.sql) – DBA logging/settings access | [02_logging_access.txt](evidence/02_logging_access.txt), including two expected denials |
| [sql/03_maintenance.sql](sql/03_maintenance.sql) – all 12 table maintenance commands | [03_maintenance.txt](evidence/03_maintenance.txt) |
| [sql/04_query_plan.sql](sql/04_query_plan.sql) – real student My requirements SELECT | [04_query_plan.txt](evidence/04_query_plan.txt) |
| [sql/05_verify.sql](sql/05_verify.sql) – fresh auditor verification | [05_verify.txt](evidence/05_verify.txt) |
| OS log access notes | [06_service_log_access.txt](evidence/06_service_log_access.txt) |
| [review_service_logs.py](review_service_logs.py) – existing OS access, safe project-scoped diagnostics | [07_service_log_review.txt](evidence/07_service_log_review.txt) |
| Source commit, file blob and query/caller excerpt | [08_source_query.txt](evidence/08_source_query.txt) |
| Package validation | [09_validation.txt](evidence/09_validation.txt) |
| Prepared findings for owners | [owner-feedback.md](owner-feedback.md), unsent draft |

## Reproduction

From this project folder, using the existing Activity 4 database/roles and PostgreSQL 18:

```sh
psql -X -w -a -U grp03_ojt_auditor -d ojt_managementdb -f sql/01_health.sql
psql -X -w -a -U grp03_ojt_dba -d ojt_managementdb -f sql/02_logging.sql
psql -X -w -a -U grp03_ojt_dba -d ojt_managementdb -f sql/03_maintenance.sql
psql -X -w -a -U grp03_ojt_app -d ojt_managementdb -f sql/04_query_plan.sql
psql -X -w -a -U grp03_ojt_auditor -d ojt_managementdb -f sql/05_verify.sql
python3 review_service_logs.py
```

The connections used the default local Unix socket on port 5432. `-w` disables password prompts; use approved private credential configuration where required, without secrets in committed files or command arguments. Do not substitute a superuser when a project account encounters a permission limit.

Review current state and effective ownership/maintenance privilege before repeating maintenance. VACUUM must run standalone: never add `--single-transaction`. This routine does not seed the database or alter grants/schema. It does change statistics and physical storage and may take locks. Query analysis runs a safe SELECT inside a read-only transaction, selecting an existing non-deleted student ID. If no such profile exists, the script's `\gset` fails under ON_ERROR_STOP; document the setup limitation rather than creating artificial records without an appropriate plan.

The logging SQL intentionally continues after expected permission errors. Inspect its per-statement results; a zero process exit status does not mean all statements succeeded. Other SQL scripts stop on unexpected errors. The Python tool only reads the current OS user's accessible service journal and emits a redacted, project-scoped extract; it does not change log files, settings or access.

Evidence retains echoed SQL, stdout/stderr, timestamps and direct account identities. Trailing whitespace and blank lines at EOF were trimmed for version control without changing results. Save later reruns separately so this baseline remains reviewable; timings and counters will vary.

## Version control and deferred steps

Keep the activity commit scoped to `group-test-results/activity-5/grp03-Project-OJT-RMA-System/`, excluding unrelated work. Use a descriptive message such as `Document grp03 Activity 5 monitoring and maintenance`. From the repository root, inspect history with:

```sh
git log --oneline -- group-test-results/activity-5/grp03-Project-OJT-RMA-System
```

Per the user's instructions, **no tracker or tracking-log update and no PDF documentation** were prepared. Owner feedback is an unsent draft. No source-repository changes, external messages or push are claimed. The reports/evidence are ready for any separately requested submission step. AI use and validation are declared in Part E.
