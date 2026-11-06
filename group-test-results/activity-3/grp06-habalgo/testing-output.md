# HabalGo Testing Output

## Project tested

Group 6 - HabalGo - Ride and Booking Management System

## Testing group

Group 5

## Repository cloned

https://github.com/jeanaroyo/HabalGo.git

The existing checkout was verified as a valid clone. `git remote -v` showed the HabalGo repository above. The working tree was clean before testing. The remote branch refresh command could not reach GitHub from this environment, so the local origin refs were used as the available repository state.

## Branch and commit tested

Branch: main (tracking origin/main; repository default ref origin/HEAD -> origin/main)

Commit: c523913b6ffa57dae754a7fb6e4d6ffed4ac7070 - Delete db-backup-recovery directory - 2026-11-05 23:22:49 +08:00

Available remote branches observed locally: origin/main and origin/db-access-control.

## Activity 3 testing procedure

1. Verify the HabalGo remote, available branches, default branch, latest commit, and local working-tree state.
2. Review README.md, all PHP/HTML/CSS/JavaScript files, both schema copies, both seed files, configuration, and available documentation.
3. Review the official COMP018 Activity 3 instructions and the supplied Park-It report only for the required procedure and report format.
4. Identify prerequisites, dependencies, PostgreSQL version, database name, configuration variables, startup command, initialization commands, sample data, roles, and automated tests.
5. Create a new isolated PostgreSQL database named habalgo_activity3_20261106 in a separate PostgreSQL 18.6 test cluster on port 55433. No Park-It, OJT, BrewPOS, or other project database was used.
6. Execute the README-documented root schema.sql and sample data.sql files without changing them.
7. Start the PHP built-in server with the documented PHP command, the documented environment-variable names, and the required pdo_pgsql extension enabled for the test process.
8. Exercise the dashboard and every API resource exposed by api.php. Check retrieval plus create, update, and delete operations for customers, vehicles, bookings, payments, and ratings.
9. Check PHP syntax, automated-test inventory, documentation files, and the default configuration behavior.
10. Remove the isolated test cluster and temporary server logs after the test. No application source, schema, migration, or seed file was changed.

## Required software, dependencies, and configuration

- PostgreSQL 15 or higher is required by README.md. PostgreSQL 18.6 was used for this test.
- PHP 8.0 or higher with pdo_pgsql is required. PHP 8.2.12 from XAMPP was used; pdo_pgsql was not enabled in the default CLI module list and was enabled only for the test process.
- Apache through XAMPP/WAMP or the PHP built-in web server is supported. The PHP built-in server was started on 127.0.0.1:8086 for testing.
- Git is required for cloning.
- No npm package.json or Composer composer.json is present, and no external application dependency installation is documented.
- README.md documents database name grp00_habalgodb, schema habalgo, host localhost, port 5432, PostgreSQL user postgres, and the environment variables DB_HOST, DB_PORT, DB_NAME, DB_SCHEMA, DB_USER, and DB_PASS.
- config.php actually reads DB_HOST, DB_PORT, DB_NAME, DB_USER, and DB_PASS. It does not read DB_SCHEMA and instead sets the PostgreSQL search path to habalgo in api.php.
- README.md instructs the tester to copy .env.example to .env, but .env.example is absent from the tested commit. The application was therefore run with the documented variable names supplied directly to the test process; no source file was edited.
- README.md startup command: php -S localhost:8000. The equivalent test command used port 8086 to avoid an existing port conflict.
- README.md initialization commands: create the documented database, run schema.sql, then run sample data.sql with psql.
- Root sample data.sql inserts 10 drivers. The alternate database/02_seed.sql inserts two drivers and two customers, but it is not the seed file named by the README.
- No sample login accounts or application authentication are documented or implemented in the reviewed code.

## Documentation review

- README.md reviewed: project overview, prerequisites, environment configuration, database initialization, seed procedure, startup options, and pdo_pgsql guidance.
- No PDF progress documentation is present in the tested repository, although the official Activity 3 instructions require a PDF progress document.
- No separate user-role document is present. The reviewed application has no login/session or role-handling workflow; it exposes dashboard and CRUD API functions without authentication.
- schema.sql and database/01_schema.sql define the same eight-table habalgo schema: customer, driver, vehicle, driver_vehicle, location, booking, payment, and rating_feedback, with foreign keys, uniqueness rules, checks, and indexes.
- database/03_roles_and_privileges.sql is an Activity 4 role/privilege script, not referenced by the Activity 3 README. It contains database-role setup and committed password literals, contrary to the official instruction not to commit real passwords or credentials; the values are not reproduced in this report and the script was not executed.
- README.md says the application has CRUD capabilities, and api.php/app.js expose CRUD for customers, vehicles, bookings, payments, and ratings. There is no documented application-role-to-PostgreSQL-role mapping.

## Setup result

Successfully reproduced with documentation issues.

The isolated PostgreSQL 18.6 cluster and database habalgo_activity3_20261106 were created successfully. Root schema.sql created the habalgo schema and eight tables without errors. Root sample data.sql completed successfully and inserted 10 drivers. A direct database check confirmed the isolated database and seeded driver count.

The application started successfully with PHP 8.2.12, pdo_pgsql enabled for the process, and DB_HOST/DB_PORT/DB_NAME/DB_USER/DB_PASS set to the isolated test database. The dashboard endpoint returned HTTP 200 and database-backed JSON. The literal README step `cp .env.example .env` cannot be completed because .env.example is missing. The default PHP CLI also reports no pdo_pgsql module until it is enabled.

PHP syntax verification passed for api.php and config.php. No automated test files or test command are present; npm test and Composer test commands are not applicable.

## Essential functions verification

| Essential function | Expected result | Status |
|---|---|---|
| Database connection | Application connects to the configured PostgreSQL database. | Working in the isolated test process: dashboard returned HTTP 200 and JSON statistics from habalgo_activity3_20261106. |
| Retrieve dashboard | Dashboard statistics and recent bookings are returned. | Working: HTTP 200; empty initial dashboard returned customers 0, active 0, revenue 0. |
| Retrieve application resources | Customers, vehicles, bookings, payments, and ratings can be listed. | Working: all five GET endpoints returned HTTP 200. |
| Customer CRUD | A customer can be created, retrieved, updated, and deleted. | Working: POST, GET, PUT, and DELETE completed with HTTP 200. |
| Vehicle CRUD and driver assignment | A vehicle can be created, updated with a driver assignment, and deleted. | Working: POST, PUT, and DELETE completed with HTTP 200. |
| Booking CRUD | A booking can be created and updated through the application. | Working: POST and PUT to Completed completed with HTTP 200; the booking was later deleted after dependent records were removed. |
| Payment CRUD | A payment can be created, updated, and deleted. | Working: POST, PUT, and DELETE completed with HTTP 200. |
| Rating CRUD | A completed booking can receive a rating that can be updated and deleted. | Working: POST, PUT, and DELETE completed with HTTP 200. |
| Dashboard after activity | Dashboard remains database-backed after test activity. | Working: final dashboard request returned HTTP 200 and reflected the remaining seeded/test-linked customer state. |
| Invalid or constrained input handling | Database and API constraints reject invalid data. | Not separately exercised through the HTTP test run; schema constraints were reviewed but no success claim is made for this function. |

## Application roles checked

No documented application roles or sample accounts were available to exercise. The repository has no login page, authentication code, session handling, or role-specific UI/API authorization in the reviewed files. The database/03_roles_and_privileges.sql file describes intended PostgreSQL groups and login accounts for a later Activity 4, but it is not application-role documentation and was not executed.

Result: role verification could not be performed. This is a documentation and implementation gap under the Activity 3 requirements.

## Issues found

- README.md requires .env.example, but the file is missing from the tested commit; the literal documented configuration procedure therefore fails.
- config.php supports DB_HOST, DB_PORT, DB_NAME, DB_USER, and DB_PASS, but ignores the documented DB_SCHEMA variable; api.php hardcodes the habalgo search path.
- The README database name is grp00_habalgodb, while the application default is habalgo. The application default database does not match the README.
- PHP 8.2.12 is available, but pdo_pgsql is disabled in the default CLI module list and requires a manual extension override or php.ini change.
- No PDF progress document is included.
- No application user-role documentation, sample accounts, login workflow, or mapping to intended PostgreSQL roles is included.
- No automated test suite or automated test command is included.
- Two schema scripts and two seed scripts exist with different documented/actual seed contents; the README does not explain which alternate database scripts should be used.
- database/03_roles_and_privileges.sql contains committed credential literals and hardcodes the README database name. It is not safe to use as a portable Activity 3 setup script without correction and secure local credential replacement.
- The README describes an interactive system but does not document the API endpoints, the request fields, or how to verify the CRUD workflows from a browser.
- The repository uses an external Google Fonts URL in index.html; the application’s core CRUD API does not depend on it, but the UI appearance may vary without internet access.

## Feedback

Add a placeholder-only .env.example, reconcile the README database name with config.php, document DB_SCHEMA behavior, choose and explain one schema/seed path, enable/validate pdo_pgsql in setup instructions, add the required PDF and user-role documentation, remove committed credential literals from the Activity 4 script, and add automated tests or a documented API verification procedure.

## Reproduction result

Successfully reproduced with documentation issues. The HabalGo application initialized and ran against a newly created, isolated PostgreSQL 18.6 database. The dashboard and all five exposed resource collections worked, and customer, vehicle, booking, payment, and rating create/update/delete operations were actually exercised with HTTP 200 results. The project cannot be reproduced by following the README literally because .env.example is missing, the documented and default database names disagree, pdo_pgsql is disabled by default, and application roles/accounts are not documented or implemented.

## Last updated

2026-11-06
