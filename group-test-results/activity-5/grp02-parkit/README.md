# Activity 5 – Group 2 Park It

Group 5's monitoring and maintenance work for the existing local `grp_parkitdb`, executed **6 November 2026**. Start with [Part E](part_e.md) for findings and priorities.

| Required part | File |
|---|---|
| A: health and activity | [part_a.md](part_a.md) |
| B: logs and issues | [part_b.md](part_b.md) |
| C: maintenance | [part_c.md](part_c.md) |
| D: query performance | [part_d.md](part_d.md) |
| E: maintenance report and AI declaration | [part_e.md](part_e.md) |

## Part F – Repository materials

This per-project folder is the repository evidence package. All scripts and results stay in our group's repository. No other group's repository was edited.

| Script/material | Captured evidence |
|---|---|
| [sql/01_health.sql](sql/01_health.sql) – auditor health/roles, table/index review | [01_health.txt](evidence/01_health.txt), before maintenance |
| [sql/02_logging.sql](sql/02_logging.sql) – DBA log settings and expected access denials | [02_logging_access.txt](evidence/02_logging_access.txt) |
| [sql/03_maintenance.sql](sql/03_maintenance.sql) – actual ANALYZE and ordinary VACUUM | [03_maintenance.txt](evidence/03_maintenance.txt) |
| [sql/04_query_plan.sql](sql/04_query_plan.sql) – runtime EXPLAIN then safe SELECT analysis | [04_query_plan.txt](evidence/04_query_plan.txt) |
| [sql/05_verify.sql](sql/05_verify.sql) – fresh auditor verification | [05_verify.txt](evidence/05_verify.txt) |
| OS filesystem and journal-access checks | [06_service_log_access.txt](evidence/06_service_log_access.txt) |
| [review_service_logs.py](review_service_logs.py) – scoped read-only journal review | [07_service_log_review.txt](evidence/07_service_log_review.txt) |
| Reviewed repository commit and actual query excerpt | [08_source_query.txt](evidence/08_source_query.txt) |
| Findings prepared for owners, not sent | [owner-feedback.md](owner-feedback.md) |

The Activity 5 PDF was read from the parent activity folder. The supplied source is [HelloP0/PARK-IT-DATABASE-MANAGEMENT-SYSTEM](https://github.com/HelloP0/PARK-IT-DATABASE-MANAGEMENT-SYSTEM), reviewed on `main` at `d369a457ce2dc88a024428513360f0ad76473f43`. Earlier Activity 4 documentation references a different URL; Part A records this distinction.

## Reproducing the checks

From this project folder, with PostgreSQL 18 and the existing Activity 4 database/roles available:

```sh
psql -X -w -a -U park_it_auditor -d grp_parkitdb -f sql/01_health.sql
psql -X -w -a -U park_it_dba -d grp_parkitdb -f sql/02_logging.sql
psql -X -w -a -U park_it_dba -d grp_parkitdb -f sql/03_maintenance.sql
psql -X -w -a -U park_it_app -d grp_parkitdb -f sql/04_query_plan.sql
psql -X -w -a -U park_it_auditor -d grp_parkitdb -f sql/05_verify.sql
python3 review_service_logs.py
```

Connections used the local default Unix socket on port 5432. `-w` prevents password prompting; if authentication requires credentials, configure them privately through the approved local mechanism rather than putting secrets in SQL, connection URLs or committed files. Direct logins preserve the role boundaries. No superuser fallback is part of this procedure.

Review current database state and effective maintenance permissions before rerunning maintenance. Never add `--single-transaction` to the maintenance command. It performs no grants or seed writes; table maintenance still changes statistics/storage and may take locks. The query plan script executes its safe SELECT in a read-only transaction. Only the logging script intentionally continues through expected permission errors: psql exit code alone is not proof that all its statements succeeded.

Original captures contain echoed statements plus stdout/stderr, with timestamps and account identities. Trailing whitespace and blank lines at EOF were trimmed for version control; result content was retained. A later rerun produces different counters/timings and should be saved as separate evidence rather than replacing this baseline. The Python script reads only accessible service logs and emits a sanitized project extract; it never changes logs or logging configuration.

## Version control and deferred submission steps

Keep changes scoped to `group-test-results/activity-5/grp02-parkit/`. Review the diff and staged paths so unrelated existing work stays outside the activity commit. Use a descriptive commit such as `Document Park-It Activity 5 checks and maintenance`, preserving this package's real execution evidence. History can be reviewed from the repository root with:

```sh
git log --oneline -- group-test-results/activity-5/grp02-parkit
```

Per the user's explicit scope, **no tracker or tracking-log updates and no PDF documentation were prepared**. Owner feedback is a draft only; it was not posted, emailed or sent. These external/submission steps remain deferred. The repository files provide the reusable material for them if requested later. AI use and validation are declared in Part E.
