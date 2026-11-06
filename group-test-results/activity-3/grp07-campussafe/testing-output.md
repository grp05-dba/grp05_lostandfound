# CampusSafe Testing Output

## Project tested

CampusSafe: Campus Hazard & Safety Reporting System, PHP/PostgreSQL application.

## Testing group

Group 5

## Repository cloned

Repository remote verified with `git remote -v`:

`https://github.com/jeffersonorpesa2-ops/grp07-campussafe`

The requested path `C:\Users\Emmanuel\ACTIVITY 5 GROUP 7 - CAMPUSSAFE` did not exist at the start of testing. The available checkout tested was `C:\Users\Emmanuel\grp07-campussafe`. It is a valid Git repository, not a folder without Git metadata. The working tree was clean before test configuration.

## Branch and commit tested

Branch: `main`

Commit: `454cfd1` - `feat: add 1-click web installer wizard, automated setup.bat, and start.bat launcher for zero-effort classmate installation`

The checkout reported `main...origin/main`; `origin/main`, `origin/HEAD`, and `origin/G05_Act_4,5,6` pointed at the tested commit.

## Activity 3 testing procedure

1. Verified the Git remote, available branches, tested branch, commit, and working-tree state.
2. Reviewed `README.md`, `HOW_IT_WORKS.md`, the progress log, all files under `docs/`, the database SQL scripts, `database/seed_users.php`, configuration files, PHP source, and public application routes.
3. Read the official `COMP018_Activity_3.docx` instructions and used the supplied Park-It `testing-output.md` only as the report-format reference.
4. Created the isolated PostgreSQL database `grp07_campussafe_activity3_test_20261106`. No Park-It, OJT, BrewPOS, HabalGo, or other project database was used.
5. Ran `database/01_schema.sql`, `database/02_seed.sql`, `database/03_roles_and_privileges.sql`, and `database/verify.sql` without changing those files.
6. Configured a local `.env` with the isolated database and started the documented PHP built-in server. Diagnostic runtime overrides were needed for the missing `pdo_pgsql` extension and unwritable PHP session directory; these overrides were not source changes.
7. Exercised every documented demo account and the main hazard-report lifecycle through the web application.
8. Checked the PHP files for syntax errors and searched for automated test manifests/files.

## Required software, dependencies, and configuration

- PHP 8.2 or higher. Installed: XAMPP PHP 8.2.12 (`C:\xampp\php\php.exe`).
- Required PHP extensions documented: `pdo`, `pdo_pgsql`, `pgsql`, `fileinfo`, and `session`.
- PostgreSQL 14 or higher. Tested with PostgreSQL 18.6 on `localhost:5432`.
- PHP built-in web server command documented: `php -S localhost:8000 -t public`.
- Database name documented by the project: `grp07_campussafedb`. The isolated test database used was `grp07_campussafe_activity3_test_20261106`.
- Documented environment variables: `APP_NAME`, `APP_ENV`, `APP_DEBUG`, `APP_URL`, `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `UPLOAD_DIR`, `MAX_UPLOAD_SIZE_MB`, and `DEMO_PASSWORD`.
- Documented initialization order: `database/01_schema.sql`, `database/02_seed.sql`, and `database/03_roles_and_privileges.sql`.
- Documented verification script: `database/verify.sql`.
- Documented database roles: `app_runtime_grp`, `app_readonly_grp`, and `app_backup_grp`, with login accounts `campussafe_app`, `campussafe_report`, and `campussafe_backup`.
- No Composer, npm, package, or framework dependency manifest is present. The application uses PHP standard functionality, PDO, and PostgreSQL.
- Sample usernames documented and tested: `demo_admin`, `demo_maint1`, `demo_maint2`, `demo_student`, `demo_faculty`, and `demo_auditor`. Passwords are intentionally omitted from this report.

## Documentation review

- `README.md` documents the technology stack, one-click and manual setup, environment variables, SQL script order, sample accounts, roles, and application modules.
- `docs/testing-guide.md` documents a broad manual testing matrix.
- `docs/user-roles.md`, `docs/db-user-role-setup.md`, `docs/database.md`, `docs/master-data-crud.md`, `docs/architecture.md`, `docs/erd.md`, and `docs/troubleshooting.md` were reviewed.
- `progress-report/PROGRESS_LOG.md` was reviewed as the project progress documentation. No PDF progress document is present in the repository.
- The repository includes SQL initialization and seed files rather than framework migrations.
- The README says the one-click installer can create the database, but the Activity 3 manual path requires a database already created by the tester.
- The committed role SQL contains hard-coded database-level statements for `grp07_campussafedb`, which conflicts with isolated database testing.

## Setup result

Failed to reproduce from the documented setup without environment corrections.

Evidence:

- PostgreSQL 18.6 was available and the isolated database was created successfully.
- `database/01_schema.sql` completed successfully.
- `database/02_seed.sql` completed successfully with 5 roles, 6 users, 6 categories, 10 locations, 16 hazard reports, 12 assignments, 60 history rows, 9 maintenance actions, and 5 attachments.
- `database/verify.sql` completed successfully. The unverified-report, missing-resolution-timestamp, and orphaned-assignment checks all returned zero.
- `database/03_roles_and_privileges.sql` reported errors for `REVOKE ALL ON DATABASE grp07_campussafedb` and `GRANT CONNECT ON DATABASE grp07_campussafedb` because the isolated test database has a different name. The script continued and applied table grants.
- XAMPP PHP 8.2.12 did not load `pdo_pgsql` or `pgsql` from its default `php.ini`; the server only connected after command-line extension overrides.
- The default PHP session directory `C:\xampp\tmp` was not writable by the server process; authentication and CSRF failed until a writable temporary session directory was supplied.
- After those diagnostic overrides, the application started and the HTTP homepage, login page, dashboards, and workflows returned successfully.
- All PHP files passed `php -l` syntax checks.

## Essential functions verification

| Essential function | Expected result | Status and evidence |
|---|---|---|
| Database connection | Application connects to the isolated PostgreSQL database. | Passed diagnostically: `campussafe_app` connected to `grp07_campussafe_activity3_test_20261106` and selected 16 seeded reports. Unmodified default PHP configuration failed because `pdo_pgsql` was not loaded. |
| User login | A documented account can sign in. | Passed with temporary writable session directory: all six documented accounts returned successful login redirects. |
| Role-based access | Routes are available only to appropriate roles. | Passed for the exercised routes: administrator dashboard, maintenance queue, reporter submission, and auditor statistics pages loaded for the intended accounts. |
| Create safety report | A reporter can submit a hazard. | Passed: student created isolated report #17; application redirected to its detail page with status `Submitted`. |
| Retrieve/view report | A signed-in user can view a report and history. | Passed: report #17 detail page showed the report, status, reporter, location, and audit history. |
| Update report | A reporter can update a pending report. | Passed: student updated report #17 description before verification. |
| Verify and prioritize report | Administrator can verify and assign priority. | Passed: administrator changed report #17 to `Verified` with priority `High`. |
| Assign maintenance work | Administrator can dispatch a verified report. | Passed: administrator assigned report #17 to a maintenance technician. |
| Start work and log action | Maintenance role can start work and record work. | Passed: maintenance account started work and opened the maintenance update workflow. |
| Resolve report | Maintenance role can mark work resolved with an action. | Passed: report #17 became `Resolved` with a resolution action and timestamp. |
| Close safety workflow | Administrator can close a resolved report. | Passed: report #17 became `Closed`; database query confirmed `resolved_at` was non-null and six history steps existed. |
| Dashboard/statistics | Dashboard and analytics pages load seeded data. | Passed diagnostically: home, administrator dashboard, maintenance queue, and administrator/auditor statistics pages loaded. |
| User/staff management | Administrator can access management module. | Access verified for administrator at `admin/users.php`; no create/update/deactivate mutation was performed during this first-time run. |
| Master data management | Administrator can access category/location CRUD modules. | Access verified for administrator at `admin/categories.php` and `admin/locations.php`; no mutation was performed during this first-time run. |
| Delete operations | Applicable deletes work or are documented. | Not claimed as passed. The application documents soft deactivation and restricted deletes; no delete mutation was executed during this run. |
| Automated tests | Project test suite runs. | Not available: no automated test suite, package manifest, Composer manifest, PHPUnit configuration, or test files were found. `docs/testing-guide.md` is manual documentation only. |

## Application roles checked

- Administrator - `demo_admin`: login passed; administrator dashboard, verification, assignment, reports close workflow, user management, master data pages, and statistics were exercised.
- Maintenance Lead - `demo_maint1`: login passed; work queue, start-work, update, and resolve workflow were exercised.
- Maintenance Tech - `demo_maint2`: login passed; maintenance work-queue route access was exercised.
- Student Reporter - `demo_student`: login passed; report create, retrieve, and update were exercised.
- Faculty Reporter - `demo_faculty`: login passed; reporter submission route access was exercised.
- Safety Auditor - `demo_auditor`: login passed; read-only statistics route access was exercised.

## Issues found

- The requested CampusSafe directory was missing; the available Git checkout was at a different path.
- The default XAMPP PHP CLI configuration lacks the required `pdo_pgsql` and `pgsql` extensions even though the DLLs are installed.
- The documented setup does not identify the PHP session-directory permission requirement. The default session directory caused authentication and CSRF failures.
- `database/03_roles_and_privileges.sql` hard-codes `grp07_campussafedb` for database-level revoke/grant statements, so its database-level setup is not portable to an isolated test database.
- The README and database documentation call the primary database `grp07_campussafedb`; they do not clearly describe a safe per-tester database-name substitution for all SQL scripts.
- No PDF progress document is included despite Activity 3 requiring one.
- No automated tests are included.
- The one-click installer and setup scripts are documented as modifying local PHP configuration and creating databases; the report did not use those automation paths because the first-time test followed the documented manual SQL procedure and preserved the committed files.
- The README contains a demonstration password and the seed SQL contains a password hash. This report does not reproduce either credential.

## Feedback

Parameterize the database name in all SQL scripts, document or avoid PHP session-directory permission assumptions, add a clear extension validation/fix step, include the required PDF progress document, and add automated tests. No source-code, schema, migration, or seed-file changes were made.

## Reproduction result

Failed to reproduce.

The isolated database schema and seed data were reproducible, and the main application workflows worked after diagnostic environment overrides. The unmodified documented setup did not start cleanly because `pdo_pgsql` was disabled in the supplied PHP configuration, the session directory was not writable, and the role script used a hard-coded database name that differed from the required isolated test database. These are sufficient setup blockers for a first-time Activity 3 reproduction, even though the application was functionally exercised after the environment was corrected.

## Last updated

2026-11-06
