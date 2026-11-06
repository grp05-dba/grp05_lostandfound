# Activity 5 – Group 4 BrewPOS

Group 5's database monitoring package for the existing local `grp_brewposdb`, inspected **6 November 2026**. Start with [Part E](part_e.md) for findings and recommendations.

**Status:** health, available-log review and query analysis completed; maintenance remains blocked by the existing account permissions. PostgreSQL skipped the ANALYZE/VACUUM attempts. The missing Activity 4 role setup is documented, not bypassed.

| Required part | File |
|---|---|
| A – Health, activity and role comparison | [part_a.md](part_a.md) |
| B – Logs and issues | [part_b.md](part_b.md) |
| C – Maintenance purpose, skipped attempts and next steps | [part_c.md](part_c.md) |
| D – Daily-sales query analysis | [part_d.md](part_d.md) |
| E – Findings/report and AI declaration | [part_e.md](part_e.md) |

## Part F – Repository materials

This folder keeps our group's work separate from the owning group's source. The supplied repository is [Nycri/brewpos](https://github.com/Nycri/brewpos), `main`, reviewed at commit `f2af982d7cd2709ebcb0e0f0fd00af27bc4286d4` through connected GitHub read tools. No owning-group repository files were edited and no schema/seed/role setup was rerun.

| Reproducible material | Actual evidence |
|---|---|
| [sql/01_health.sql](sql/01_health.sql) – existing runtime's permitted inspection | [01_health.txt](evidence/01_health.txt), before maintenance probes |
| [sql/02_logging.sql](sql/02_logging.sql) – visible settings and expected log-function denials | [02_logging_access.txt](evidence/02_logging_access.txt) |
| [sql/03_maintenance.sql](sql/03_maintenance.sql) – one-table maintenance-limit demonstration | [03_maintenance.txt](evidence/03_maintenance.txt), both operations skipped |
| [sql/04_query_plan.sql](sql/04_query_plan.sql) – safe SQL translation of daily-sales JPQL | [04_query_plan.txt](evidence/04_query_plan.txt) |
| [sql/05_verify.sql](sql/05_verify.sql) – fresh runtime verification | [05_verify.txt](evidence/05_verify.txt), unchanged counts/maintenance state |
| Existing OS log access notes | [06_service_log_access.txt](evidence/06_service_log_access.txt) |
| [review_service_logs.py](review_service_logs.py) – project-scoped service-journal reader | [07_service_log_review.txt](evidence/07_service_log_review.txt) |
| Source JPQL/caller and provenance | [08_source_query.txt](evidence/08_source_query.txt) |
| Package validation | [09_validation.txt](evidence/09_validation.txt) |
| Findings prepared for owners | [owner-feedback.md](owner-feedback.md), unsent draft |

## Reproducing current-state checks

From this folder, against the existing local database and current runtime grants:

```sh
psql -X -w -a -U brewpos_app -d grp_brewposdb -f sql/01_health.sql
psql -X -w -a -U brewpos_app -d grp_brewposdb -f sql/02_logging.sql
psql -X -w -a -U brewpos_app -d grp_brewposdb -f sql/03_maintenance.sql
psql -X -w -a -U brewpos_app -d grp_brewposdb -f sql/04_query_plan.sql
psql -X -w -a -U brewpos_app -d grp_brewposdb -f sql/05_verify.sql
python3 review_service_logs.py
```

Connections used the default local Unix socket on port 5432. `-w` disables password prompting; configure credentials privately through the approved local mechanism if required, without putting secrets into commands, SQL, reports or repository files. No superuser fallback is part of this procedure.

Review permissions/state before rerunning. The maintenance script documents the current limitation and is not a successful-maintenance recipe for this account. Never add `--single-transaction`: ordinary VACUUM must be standalone. If an authorized maintenance role is later provided, follow Part C's instructions, rerun proportionate work under that role, and retain new evidence separately.

Logging/maintenance scripts intentionally continue to capture expected errors or warning-only skips. A zero process exit code or ANALYZE/VACUUM tag does not prove the table was maintained. The other scripts stop on unexpected SQL errors. The query script uses a read-only transaction and an existing order date (today only if empty); it translates the real JPQL without claiming literal ORM SQL capture. The journal tool reads only existing OS access and emits redacted scoped messages without modifying logs or settings.

Evidence contains echoed commands, stdout/stderr, direct identities and timestamps. Trailing whitespace/blank lines at EOF were trimmed without changing results. Preserve this baseline; later execution changes counters/timings and should produce separate captures.

## Version control and deferred steps

Keep the commit scoped to `group-test-results/activity-5/grp04-brewpos/`, with a message reflecting the observed limit, such as `Document BrewPOS Activity 5 checks and maintenance limits`. Inspect history from the repository root with:

```sh
git log --oneline -- group-test-results/activity-5/grp04-brewpos
```

Per the user's instructions, **no tracker or tracking-log updates and no PDF documentation** were prepared. Owner feedback remains an unsent draft. No external message or push is claimed. The missing access-control prerequisite and successful maintenance are outstanding; the repository material records that state explicitly. AI use and validation are declared in Part E.
