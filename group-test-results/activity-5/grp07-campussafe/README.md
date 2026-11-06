# Activity 5 – Group 7 CampusSafe

Group 5's CampusSafe setup/monitoring package, executed **6 November 2026**. Start with [Part E](part_e.md) for findings and priorities.

**Status:** missing local prerequisites installed with disclosed adaptations; ANALYZE/ordinary VACUUM completed on all nine tables through the documented non-superuser owner; all 129 seeded rows preserved. Unrelated-database CONNECT scope remains a follow-up.

| Required part | File |
|---|---|
| A – Health, activity and roles | [part_a.md](part_a.md) |
| B – Available logs and issues | [part_b.md](part_b.md) |
| C – Maintenance and verification | [part_c.md](part_c.md) |
| D – Application category-query analysis | [part_d.md](part_d.md) |
| E – Findings/report and AI declaration | [part_e.md](part_e.md) |

## Part F – Repository materials

Reviewed source: [jeffersonorpesa2-ops/grp07-campussafe](https://github.com/jeffersonorpesa2-ops/grp07-campussafe), `main`, commit `3684b97cfa8b8c6624d039eda461551ade774701`. The clean temporary clone was read without editing source. Our local setup adaptations and evidence stay in this group's own repository.

| Script/material | Captured evidence |
|---|---|
| Initial missing database/accounts and existing generic groups | [00_initial_inventory.txt](evidence/00_initial_inventory.txt) |
| [setup/01_database.sql](setup/01_database.sql) – fresh local database | [00_database_setup.txt](evidence/00_database_setup.txt) |
| [setup/02_schema.sql](setup/02_schema.sql) – source DDL with DROP reset statements removed | [00_schema_setup.txt](evidence/00_schema_setup.txt) |
| [setup/03_roles.sql](setup/03_roles.sql) – password-free plan, project-specific group names | [00_role_setup.txt](evidence/00_role_setup.txt) |
| Fresh source seed, temporary copy with TRUNCATE removed and no echo | [00_seed_setup.txt](evidence/00_seed_setup.txt) |
| [setup/04_owner.sql](setup/04_owner.sql) – implement documented non-superuser owner | [00_owner_setup.txt](evidence/00_owner_setup.txt) |
| [sql/00_runtime_counts.sql](sql/00_runtime_counts.sql) – aggregate-only auditor-excluded table counts | [Before](evidence/00_runtime_counts_before.txt) and [after](evidence/05_runtime_counts_after.txt) |
| [sql/01_health.sql](sql/01_health.sql) – reporting health, roles, objects and sanity checks | [01_health.txt](evidence/01_health.txt) |
| [sql/02_logging.sql](sql/02_logging.sql) – settings and expected log-function denials | [02_logging_access.txt](evidence/02_logging_access.txt) |
| [sql/03_maintenance.sql](sql/03_maintenance.sql) – nine explicit ANALYZE/VACUUM operations each | [03_maintenance.txt](evidence/03_maintenance.txt) |
| [sql/04_query_plan.sql](sql/04_query_plan.sql) – safe exact dashboard SELECT | [04_query_plan.txt](evidence/04_query_plan.txt) |
| [sql/05_verify.sql](sql/05_verify.sql) – fresh reporting verification | [05_verify.txt](evidence/05_verify.txt) |
| Existing OS log access notes | [06_service_log_access.txt](evidence/06_service_log_access.txt) |
| [review_service_logs.py](review_service_logs.py) – scoped service-journal reader | [07_service_log_review.txt](evidence/07_service_log_review.txt) |
| Query/caller, documented owner and setup source blobs | [08_source_query.txt](evidence/08_source_query.txt) |
| Evidence/package validation | [09_validation.txt](evidence/09_validation.txt) |
| Prepared findings for owners | [owner-feedback.md](owner-feedback.md), unsent draft |

## Prerequisite reproduction – fresh environment only

The target database and logins were absent initially and now exist locally. **Do not rerun the fresh-install steps blindly.** The original schema drops tables and the original seed truncates them; local copies removed those resets. The original role script also uses group names already present for HabalGo, so our copy prefixes them `campussafe_` without altering existing groups. Original password clauses were removed.

From this package folder, only after reviewing database/role absence in a fresh environment:

```sh
psql -X -w -a -U postgres -d postgres -f setup/01_database.sql
psql -X -w -a -U postgres -d grp07_campussafedb -f setup/02_schema.sql
psql -X -w -a -U postgres -d grp07_campussafedb -f setup/03_roles.sql
```

Next load the reviewed source `database/02_seed.sql` using a **temporary fresh-install copy with its TRUNCATE statement removed**, ON_ERROR_STOP and a single transaction. Do not echo the seed, because it contains credential hashes and personal sample records. The seed contents are not committed in this results package. Its captured output is command tags/sequence numbers only.

Then implement the owner named in source `docs/user-roles.md`:

```sh
psql -X -w -a -U postgres -d grp07_campussafedb -f setup/04_owner.sql
```

That script deliberately assigns actual project ownership, not just a table ALL grant, and aligns owner-created migration defaults with the supplied plan. The source installer omits this account. Setup administrator use is limited to prerequisites; checks/maintenance below use direct project accounts. Passwords are configured privately when required, using the approved local mechanism such as psql `\password`; no credentials are stored here. Local socket authentication was used, and remote/password authentication is not claimed.

## Reproducing Activity 5 checks

With the reviewed setup already present, from this folder:

```sh
psql -X -w -a -U campussafe_app -d grp07_campussafedb -f sql/00_runtime_counts.sql
psql -X -w -a -U campussafe_report -d grp07_campussafedb -f sql/01_health.sql
psql -X -w -a -U campussafe_report -d grp07_campussafedb -f sql/02_logging.sql
psql -X -w -a -U campussafe_owner -d grp07_campussafedb -f sql/03_maintenance.sql
psql -X -w -a -U campussafe_app -d grp07_campussafedb -f sql/04_query_plan.sql
psql -X -w -a -U campussafe_report -d grp07_campussafedb -f sql/05_verify.sql
psql -X -w -a -U campussafe_app -d grp07_campussafedb -f sql/00_runtime_counts.sql
python3 review_service_logs.py
```

Connections used the default local Unix socket on port 5432. `-w` disables password prompting; supply approved credentials privately if needed. The reporting account excludes user/role tables; runtime queries count them without outputting values. Review state/ownership before maintenance, and never add `--single-transaction` to VACUUM. Ordinary maintenance changes statistics/storage and can take locks; no FULL vacuum or new index is included.

The logging script intentionally continues after two expected privilege errors; inspect individual messages rather than treating process exit status as full success. Other SQL scripts stop on unexpected errors. Query analysis uses a read-only transaction and no personal output values. The journal script uses existing OS access and never changes logs/settings.

Evidence contains echoed statements, stdout/stderr, timestamps and direct account identities, with trailing whitespace/blank lines at EOF trimmed. Preserve the baseline; save reruns separately because counters/data/timing may change. Setup scripts also normalize source whitespace/comments without changing the disclosed DDL/grant semantics. The original reset-warning comment remains in the echoed schema evidence; the DROP statements were removed before execution.

## Version control and deferred steps

Keep this activity commit scoped to `group-test-results/activity-5/grp07-campussafe/`. From the repository root, review history with:

```sh
git log --oneline -- group-test-results/activity-5/grp07-campussafe
```

Per the user's instructions, **no tracker or tracking-log updates and no PDF documentation** were prepared. Owner feedback is an unsent draft; no external message or push is claimed. AI use/validation are declared in Part E.
