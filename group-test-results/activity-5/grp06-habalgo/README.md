# Activity 5 – Group 6 HabalGo

Group 5's local setup and monitoring package for `grp00_habalgodb`, executed **6 November 2026**. Start with [Part E](part_e.md) for findings and priorities.

**Status:** missing local source prerequisites installed; dedicated runtime/read-only checks completed; maintenance remains restricted by the supplied role plan. Both maintenance attempts were skipped by PostgreSQL and are not reported as successful.

| Required part | File |
|---|---|
| A – Health, activity, setup context and role comparison | [part_a.md](part_a.md) |
| B – Available logs and issues | [part_b.md](part_b.md) |
| C – Maintenance purpose, limitation and follow-up | [part_c.md](part_c.md) |
| D – Actual driver-dropdown query analysis | [part_d.md](part_d.md) |
| E – Findings/report and AI declaration | [part_e.md](part_e.md) |

## Part F – Repository materials

Source: [jeanaroyo/HabalGo](https://github.com/jeanaroyo/HabalGo), `main`, commit `c523913b6ffa57dae754a7fb6e4d6ffed4ac7070`. The clean temporary clone was read without editing the owning group's source. Our setup adaptation and evidence are kept in this group's own repository.

| Material | Captured evidence |
|---|---|
| Initial administrator inventory of missing database/roles | [00_initial_inventory.txt](evidence/00_initial_inventory.txt) |
| [setup/01_database.sql](setup/01_database.sql) – fresh local database only | [00_database_setup.txt](evidence/00_database_setup.txt) |
| [setup/02_schema.sql](setup/02_schema.sql) – supplied root schema | [00_schema_setup.txt](evidence/00_schema_setup.txt) |
| [setup/03_roles.sql](setup/03_roles.sql) – supplied role plan with PASSWORD clauses removed | [00_role_setup.txt](evidence/00_role_setup.txt) |
| Documented root `sample data.sql` from source | [00_seed_setup.txt](evidence/00_seed_setup.txt), INSERT 0 10; raw personal sample values not copied |
| [sql/01_health.sql](sql/01_health.sql) – read-only inventory, activity, role and privilege checks | [01_health.txt](evidence/01_health.txt) |
| [sql/02_logging.sql](sql/02_logging.sql) – visible settings and expected SQL log-function denials | [02_logging_access.txt](evidence/02_logging_access.txt) |
| [sql/03_maintenance.sql](sql/03_maintenance.sql) – runtime maintenance-boundary demonstration | [03_maintenance.txt](evidence/03_maintenance.txt), both operations skipped |
| [sql/04_query_plan.sql](sql/04_query_plan.sql) – runtime EXPLAIN then safe SELECT analysis | [04_query_plan.txt](evidence/04_query_plan.txt) |
| [sql/05_verify.sql](sql/05_verify.sql) – fresh read-only counts/counters | [05_verify.txt](evidence/05_verify.txt) |
| Existing OS log access notes | [06_service_log_access.txt](evidence/06_service_log_access.txt) |
| [review_service_logs.py](review_service_logs.py) – scoped, sanitized journal reader | [07_service_log_review.txt](evidence/07_service_log_review.txt) |
| Source query, setup blobs and provenance | [08_source_query.txt](evidence/08_source_query.txt) |
| Package validation | [09_validation.txt](evidence/09_validation.txt) |
| Prepared findings for owners | [owner-feedback.md](owner-feedback.md), unsent draft |

## Setup reproduction – fresh environment only

This setup was needed because the database and all four supplied roles were absent. They now exist locally: **do not rerun the fresh-install scripts blindly** or restore over them. Generic `app_runtime_grp`/`app_readonly_grp` names are cluster-wide; review existing roles before using this plan in another environment.

From this folder, only when the target database/roles are confirmed absent, the setup administrator can run:

```sh
psql -X -w -a -U postgres -d postgres -f setup/01_database.sql
psql -X -w -a -U postgres -d grp00_habalgodb -f setup/02_schema.sql
psql -X -w -a -U postgres -d grp00_habalgodb -f setup/03_roles.sql
psql -X -w -U postgres -d grp00_habalgodb -v ON_ERROR_STOP=1 -f '/path/to/HabalGo/sample data.sql'
```

Use the root seed at the reviewed source commit, as named by its README; the alternate `database/02_seed.sql` has different sample contents. No copy of the original password-bearing role script is committed. Configure passwords privately if needed, using the approved local mechanism such as interactive psql `\password`. This run used existing local socket authentication, with no actual password in SQL/evidence. It does not validate remote/password authentication.

The administrator's setup role is separate from the monitoring accounts below. No maintenance grant was added to make a restricted command succeed.

## Reproducing Activity 5 checks

After the supplied schema/roles are installed, run from this folder:

```sh
psql -X -w -a -U habalgo_readonly_user -d grp00_habalgodb -f sql/01_health.sql
psql -X -w -a -U habalgo_readonly_user -d grp00_habalgodb -f sql/02_logging.sql
psql -X -w -a -U habalgo_app_user -d grp00_habalgodb -f sql/03_maintenance.sql
psql -X -w -a -U habalgo_app_user -d grp00_habalgodb -f sql/04_query_plan.sql
psql -X -w -a -U habalgo_readonly_user -d grp00_habalgodb -f sql/05_verify.sql
python3 review_service_logs.py
```

Connections use the default Unix socket on port 5432. `-w` disables password prompting; use private local credential configuration when required. Review current grants/state before rerunning. The maintenance script demonstrates the existing limitation; never add `--single-transaction`, because VACUUM must run standalone. Do not reconnect as superuser to bypass the role result. Part C describes the proposed approved maintenance-role follow-up.

Logging/maintenance scripts intentionally record expected errors and warning-only skips. A zero exit code or ANALYZE/VACUUM tag is not a success test. The other check scripts stop on unexpected SQL errors. Query analysis executes the real safe SELECT in a read-only transaction, without printing driver records. The journal reader uses only existing OS access and never changes logs/settings.

Evidence preserves statements, stdout/stderr, timestamps and account identities, with trailing whitespace/blank lines at EOF trimmed for version control. Save later reruns separately instead of replacing the observed baseline; counters, data and timings may differ.

## Version control and deferred steps

Keep the commit scoped to `group-test-results/activity-5/grp06-habalgo/`, using a descriptive message that includes the setup and maintenance limitation. From the repository root:

```sh
git log --oneline -- group-test-results/activity-5/grp06-habalgo
```

Per the user's instructions, **no tracker or tracking-log update and no PDF documentation** was prepared. Owner feedback remains unsent. No external message or push is claimed. The package documents executed work and outstanding maintenance clearly; AI use and validation are declared in Part E.
