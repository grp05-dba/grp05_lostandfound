# Restaurant Online Ordering and Table Reservation System Testing Output

## Project tested

MESA - Order and Reserve

## Testing group

Group 5

## Repository cloned

https://github.com/kathlenmaecallos11-arch/Restaurant-Online-Ordering-Table-Reservation-System

The supplied checkout was verified as a Git repository. The repository remote, branch list, latest commit, and working tree were checked before testing. The pre-test working tree was clean: `## main...origin/main`.

## Branch and commit tested

Branch: `main`

Commit: `e5b691fd3058bb680e550344b0e5e97474c118a5` - resolved - 2026-11-05 12:11:41 UTC

Available branches: `main`, `origin/main`, and `origin/HEAD -> origin/main`.

Remote: `origin` points to the GitHub repository above for fetch and push.

## Activity 3 testing procedure

1. Verified the repository metadata and recorded the exact branch and commit tested.
2. Reviewed the README, the PDF progress documentation, progress Markdown, user-role documents, database documentation, troubleshooting guide, local run guide, connection guide, environment example, PHP configuration, migrations, seed script, setup scripts, database-role scripts, and SQL tests.
3. Identified the documented PostgreSQL, PHP, dependency, configuration, database, role, sample-account, startup, migration, seed, and test procedures.
4. Created an isolated PostgreSQL 18.6 cluster on local port 55435 and a separate database named `rors_activity3_first_test_20261106`. It was not a Park-It, OJT, BrewPOS, HabalGo, CampusSafe, or other project database.
5. Applied migrations `001_create_tables.sql` through `004_indexes.sql` and loaded `database/seeds/001_seed_data.sql`. Migration `000_create_database.sql` was not used because it hardcodes the documented database name instead of accepting the setup script's `-DbName` value.
6. Ran `tests/crud_tests.sql` against the isolated database.
7. Configured a local, uncommitted `.env` with safe local values and used the documented quick-look PostgreSQL account because the documented role-password file is missing. PHP PostgreSQL extensions and a writable session directory were enabled only for the diagnostic run; repository source, migrations, seed files, and schema were not modified.
8. Started the PHP development server on localhost:8001 and exercised the application through HTTP requests.
9. Tested customer registration/login, customer ordering and checkout, table availability and reservation cancellation, staff login and order-status update, administrator login and menu/table management, and role restrictions.
10. Recorded setup blockers, application warnings, documentation gaps, and results below. The isolated test database and temporary runtime files were used only for this first-time test.

## Required software, dependencies, and configuration

- PostgreSQL 18 recommended; the tested server was PostgreSQL 18.6.
- PHP 8.1 or newer; the tested PHP was XAMPP PHP 8.2.12.
- PHP `pdo_pgsql` and `pgsql` extensions, plus `psql` on PATH. Both extensions were present but disabled in the default PHP CLI configuration. `psql` and `php` were not on the initial PATH, although the installed executables were available at the documented-style local installation locations.
- PostgreSQL extensions `btree_gist` and `pgcrypto`; both migrations and seed loading completed successfully in the isolated cluster.
- Documented database name: `grp_binarysisters_projectdb`. The test database was intentionally separate: `rors_activity3_first_test_20261106`.
- Documented environment variables: `APP_NAME`, `APP_BRAND`, `APP_DEBUG`, `APP_TIMEZONE`, `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, and `DB_SSLMODE`. No real credentials are included in this report.
- Documented application command: `php -S localhost:8000 -t app/public`.
- Documented setup command: `database/setup.ps1 -WithRoles`; quick-look setup without roles is also documented.
- Documented connection check: `php tools/test-connection.php`.
- Seed command: `database/seeds/001_seed_data.sql`, normally invoked by the setup script.
- Sample application roles/accounts documented: Administrator, Staff, and Customer. The report does not reproduce sample passwords.

## Documentation review

- `README.md` documents the PHP application, PostgreSQL setup, environment variables, startup command, sample roles, sample accounts, and browser smoke test.
- `docs/RUN_LOCALLY.md` documents prerequisite checks, database setup, `.env` configuration, connection testing, startup, customer/staff/admin smoke tests, and troubleshooting.
- `docs/DATABASE_CONNECTION.md` maps forms and routes to PostgreSQL operations and documents the expected `/health` response.
- `docs/user-roles.md` separates Customer, Staff, Administrator, and application-runtime roles and maps them to intended PostgreSQL roles. It also documents sample application accounts.
- `docs/user-role-setup.md` documents intended group roles, login roles, grants, and privilege checks, but references a missing `database/roles/03_set_passwords.psql` file.
- `docs/progress/BinarySisters_Progress_Documentation.pdf` and the companion progress Markdown were reviewed. The progress materials contain several `[TO COMPLETE]` placeholders and do not provide completed cross-group testing evidence.
- The repository includes migrations, seed data, a database setup script, a `.env.example`, database-role scripts, and `tests/crud_tests.sql`. No Composer file, package manager manifest, or separate PHP automated-test framework was found.
- `database/setup.ps1` accepts `-DbName`, but `database/migrations/000_create_database.sql` always creates/comments `grp_binarysisters_projectdb`; the setup command therefore cannot consistently build an arbitrary isolated database without manual intervention.

## Setup result

The unmodified documented setup did not complete cleanly. The setup script's database-creation migration hardcodes `grp_binarysisters_projectdb`, the required role-password script is absent, `php` and `psql` were not on PATH initially, and the default PHP CLI had both PostgreSQL extensions disabled. The default PHP session directory also denied writes when the server was first started.

The database and application were successfully reproduced for diagnostic functional testing after using only documented configuration concepts: an isolated PostgreSQL database, a local `.env`, the documented quick-look `postgres` account, temporary PHP extension activation, a writable session directory, and the documented PHP built-in server. The connection check then returned `OK` for PostgreSQL 18.6 and all eight tables. `/health` returned status `ok` with the isolated database and eight reachable tables.

Migration results: `001_create_tables.sql`, `002_integrity_logic.sql`, `003_views.sql`, and `004_indexes.sql` all exited successfully.

Seed result: successful. Row counts after seeding were 51 customers, 10 staff, 50 menu items, 20 restaurant tables, 60 orders, 167 order lines, 56 payments, and 50 reservations.

Automated database test result: `tests/crud_tests.sql` completed with 25 `PASS` results and `failed = 0`, then rolled back its test transaction.

No separate automated PHP test suite or package-manager test command is present.

## Essential functions verification

| Essential function | Expected result | Status |
|---|---|---|
| Database connection | PHP connects to the isolated PostgreSQL database. | Working in the diagnostic run; `/health` returned HTTP 200 and the connection tool reported all 8 tables. The default CLI needed `pdo_pgsql` enabled and the app used the quick-look `postgres` account. |
| Customer registration | A new customer account can be created. | Working: a new synthetic test customer was registered and redirected to the menu. |
| Customer login | A customer can authenticate and access customer workflows. | Working: documented sample Customer account login succeeded. |
| Menu retrieval/search | Menu items are displayed and searchable. | Working: `/menu` returned HTTP 200 and menu data; menu search route was available. |
| Cart operations | Items can be added to the cart. | Working: two menu items were added and displayed in `/cart`. |
| Checkout/order creation | A cart can be converted into an order and payment record. | Working: checkout returned the order view and a new pending order was created. |
| Order status update | Staff can change an order status. | Working: Staff changed a pending order to confirmed through `/admin/orders/view` and the status endpoint. |
| Table availability | Available tables are listed for a selected date, time, and guest count. | Working: the availability page listed eligible tables. |
| Reservation creation | A customer can reserve an available table. | Working: a reservation was created for a future date/time. |
| Reservation update/status | A reservation can be operationally changed. | Not fully verified as a customer edit workflow; the application documents staff/admin reservation-status actions, while customer workflow exposes cancellation rather than general editing. |
| Reservation cancellation | A customer can cancel an own reservation. | Working: the newly created reservation was cancelled successfully. |
| Menu item create/update/delete | Administrator can manage menu items. | Working: administrator created, updated, and deleted a synthetic menu item. |
| Table create/update/delete | Administrator can manage tables. | Create and delete routes were exercised with a synthetic table; the first update/delete attempt exposed an incorrect test ID selection and a foreign-key error for an existing referenced table. The intended isolated synthetic table was then removed. |
| Customer/staff/admin workflows | Documented roles have distinct access. | Working with issues: Customer, Staff, and Administrator logins succeeded. Staff access to `/admin/staff` returned HTTP 403; Administrator accessed `/admin/staff` and menu/table management. |
| SQL create/retrieve/update/delete and constraints | Database operations and business rules pass. | Working: 25/25 PASS, 0 failed, rolled back. |

## Application roles checked

- Customer: documented sample customer login succeeded; registration, menu access, cart, checkout, reservation availability, reservation creation, and cancellation were exercised.
- Staff: documented sample staff login succeeded; dashboard/order/menu/table/reservation/payment pages were reachable; order status update succeeded; `/admin/staff` returned HTTP 403 as documented.
- Administrator: documented sample administrator login succeeded; menu create/update/delete, table management pages, and staff administration were exercised.
- Application runtime/database account: the application connected in the diagnostic run as `postgres` because the documented role-password setup file is missing. The intended least-privilege `rors_app` login was not exercised.

## Issues found

- `database/migrations/000_create_database.sql` hardcodes `grp_binarysisters_projectdb`, so `database/setup.ps1 -DbName <separate-name>` does not consistently create and initialize the requested database.
- `database/setup.ps1 -WithRoles` and `docs/user-role-setup.md` reference `database/roles/03_set_passwords.psql`, but that file is absent from the repository. The full least-privilege role setup cannot be completed from the supplied repository.
- `php` and `psql` are not initially on PATH in the tested Windows environment, despite the documentation assuming they are available.
- XAMPP PHP 8.2.12 reports `pdo_pgsql` and `pgsql` disabled by default. The documentation says to enable them but does not include a repository-local PHP configuration or a validation result for the supplied environment.
- The default PHP session directory `C:\xampp\tmp` denied writes for the first server run, producing session warnings. A writable local session path was required for functional login testing.
- The documented setup defaults to a `postgres` quick-look connection if roles are skipped; the fully documented least-privilege runtime account could not be tested because its password setup script is missing.
- The progress PDF/Markdown contains incomplete `[TO COMPLETE]` sections, placeholder repository/tracker values, and incomplete evidence tables.
- The application database has a foreign-key restriction preventing deletion of a table referenced by reservation history. The application should handle this consistently; one test produced a server-side HTTP 500 rather than a user-facing error when the referenced table was selected.
- No separate automated PHP test suite, Composer configuration, or package-manager test command is included.
- The project documentation describes reservation creation and cancellation clearly but does not provide a complete customer reservation-edit procedure.

## Feedback

Parameterize database creation, restore or remove the missing role-password script reference, document PATH and PHP extension validation, provide a writable-session setup note, complete the progress evidence, use the least-privilege runtime account in the reproducible path, handle restricted table deletion without HTTP 500, and add automated application tests.

## Reproduction result

Successfully reproduced with documentation issues. The isolated PostgreSQL schema, seed data, SQL CRUD suite, PHP connection, browser-facing application, customer registration/login, staff login, administrator login, ordering, checkout, order status update, reservation availability/create/cancel, menu CRUD, and documented role restrictions were exercised successfully in a diagnostic run. The repository's documented first-time setup is not reproducible without resolving the hardcoded database-name conflict, missing role-password script, local PATH/extension configuration, and session-directory permissions. No source code, schema, migration, or seed file was modified.

## Last updated

2026-11-06
