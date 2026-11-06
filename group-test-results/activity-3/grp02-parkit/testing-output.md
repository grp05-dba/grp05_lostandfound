# Park-It Testing Output

## Project tested

Group 2 - Park-It: Smart Parking System

## Testing group

Group 5

## Repository cloned

https://github.com/millerdevera6-glitch/park-it-database

The repository remote was verified with git remote -v. The existing checkout was on main and had unrelated local changes, so the final branch was tested from the exact remote ref origin/final without switching or overwriting the working tree.

## Final branch and commit tested

Branch: final (origin/final)

Commit: 55efc8a98cfaaba9523a9b529a329de4138304d - Initial commit - 2026-11-05 12:54:51 +08:00

The final ref contains the PHP/XAMPP application, schema.sql, and config/seed.php. It does not contain the Node/Express files, npm package files, testing.guide, or the old seed.sql referenced by the previous report.

Working-tree evidence before testing: ## main...origin/main, with local modifications and untracked files. No application source or database script in the final branch was changed.

## Activity 3 testing procedure

1. Verify the repository remote, final branch ref, final commit, and local working-tree state.
2. Review the final README, all final-branch PHP application files, schema.sql, the seed script, configuration, and available documentation.
3. Identify prerequisites, dependencies, database name, connection settings, startup instructions, seed procedure, sample accounts, and application roles.
4. Create an isolated PostgreSQL database named park_it_final_test_20261106, separate from the documented/shared grp_parkitdb database.
5. Execute the final branch schema.sql with PostgreSQL 18.6.
6. Run the final branch config/seed.php in a temporary test copy after correcting only the temporary copy's hardcoded database target and enabling the existing PHP pdo_pgsql extension. The original repository files were not modified.
7. Start the PHP application in a temporary local server and exercise the available web workflows.
8. Check database monitoring, login, vehicle entry, invalid input, and capacity-limit behavior. Check whether the requested parking-zone CRUD functions exist in the final application.
9. Check for automated tests and exercise both documented sample accounts without recording passwords.
10. Record reproducibility blockers, documentation gaps, database/configuration inconsistencies, and functional results.

## Required software, dependencies, and configuration

- PostgreSQL 18.6, running on the local PostgreSQL 18 service.
- PHP 8.2.12 supplied by XAMPP, Apache supplied by XAMPP, and a web browser.
- PHP PDO PostgreSQL support (pdo_pgsql) and the PostgreSQL extension. The DLLs exist in XAMPP, but pdo_pgsql is disabled in the default CLI configuration (pdo_pgsql=disabled).
- The documented database name is grp_parkitdb.
- The final branch does not use environment variables or include .env.example. config/database.php hardcodes DB_HOST=localhost, DB_PORT=5432, DB_NAME=grp_parkitdb, DB_USER=postgres, and a placeholder DB_PASS value.
- README startup procedure: copy the project under C:\xampp\htdocs\park-it, enable pdo_pgsql/pgsql in php.ini, start Apache, open config/seed.php, then open the login page.
- No npm dependencies, package.json, Composer file, or automated test command is present in the final branch.

## Documentation review

- README reviewed: describes PHP, PostgreSQL 18.6, pgAdmin, XAMPP, schema setup, the seed URL, login URL, vehicle entry, payments/exits, monitoring, troubleshooting, and stop instructions.
- PDF progress documentation: no Park-It PDF is present in the final branch. The final branch contains no PDF files.
- Database documentation: schema.sql defines parking_zone, payment, staff_user, transaction, and vehicle, with primary keys, unique constraints, foreign keys, and a capacity check constraint.
- Seed/sample data: no standalone seed SQL file is present. config/seed.php creates Main Parking Lot with capacity 50 and creates the Admin and Staff accounts.
- User roles: the README documents Administrator and Staff accounts. It does not provide a separate user-role document or map application roles to intended PostgreSQL group roles/privileges. Source inspection shows login/session roles and a defined isAdmin() helper, but no separate role-specific database privilege setup.
- README/database inconsistency: the README instructs the tester to create grp_parkitdb, while config/database.php hardcodes that same database and cannot be configured through environment variables. This prevents an unmodified copy from targeting a separate test database.

## Setup result

Failed to reproduce from the unmodified final branch. PostgreSQL 18.6 was available and the schema executed successfully in an isolated database. However, the unmodified application configuration points to grp_parkitdb and contains the literal placeholder password Your Passcode; it has no environment-variable support. The default XAMPP PHP CLI also has pdo_pgsql disabled. Therefore the final branch cannot be started against the separate test database using only its committed files and documented setup.

For diagnostic functional testing only, a temporary copy was configured with the local test database and PHP was launched with -d extension=pdo_pgsql and a writable session path. That temporary copy was not part of the repository and was deleted after testing. The isolated database was also removed after testing. The documented/shared database was not reused for the final functional run; a uniquely tagged accidental test record created during the initial configuration check was removed immediately.

Schema command result: PostgreSQL reported successful creation of all five tables, sequences, keys, and foreign keys.

Seed result in the isolated temporary configuration: Database initialization completed successfully; created Main Parking Lot with capacity 50 and the documented Admin and Staff accounts.

Application startup diagnostic result: PHP development server started successfully only with the temporary extension/session overrides. The default XAMPP PHP configuration reported pdo_pgsql=disabled.

Automated test result: no automated test files or test command are present in origin/final; npm test is not applicable because the final branch has no package.json.

## Essential functions verification

| Essential function | Expected result | Status |
|---|---|---|
| Database connection | Application connects to the configured PostgreSQL database. | Failed in unmodified branch: hardcoded database/password configuration and disabled pdo_pgsql; worked in temporary diagnostic copy after configuration correction. |
| Retrieve parking zones | Existing parking zones are displayed/returned. | Working in temporary diagnostic copy: Main Parking Lot and the monitoring JSON were returned. |
| Create a parking zone | A new parking zone can be added through the application. | Not implemented: no parking-zone create route or form exists in the final branch. |
| Update a parking zone | A parking-zone name/capacity can be updated through the application. | Not implemented: no parking-zone update route or form exists in the final branch. |
| Monitor occupied spaces | Current capacity and occupied count are returned. | Working in temporary diagnostic copy: monitoring JSON returned 50 total, 1 occupied, 49 available; full-capacity state also returned correctly. |
| Park a vehicle | A vehicle entry creates a vehicle/transaction and increments occupancy. | Working in temporary diagnostic copy: TEST-001 created an active transaction and occupancy changed from 0 to 1. |
| Enforce maximum capacity | A new vehicle is rejected when the zone is full. | Working in temporary diagnostic copy: after setting the isolated test zone to 1/1, TEST-002 was rejected with the full-capacity message. |
| Reject invalid input | Invalid license-plate input is rejected. | Working in temporary diagnostic copy: BAD@001 was rejected with HTTP 200 and the validation message that only letters, numbers, spaces, and hyphens are allowed. |
| Delete a parking zone | An existing parking zone can be deleted through the application. | Not implemented: no parking-zone delete route or form exists; direct deletion is also constrained by related records. |
| Check sample login accounts | Documented accounts can log in. | Admin and Staff accounts were created by the seed script; Admin login returned HTTP 302 to the dashboard and Staff login reached the authenticated monitoring workflow in the temporary diagnostic copy. |

## Application roles checked

The documented roles and sample usernames were checked without exposing passwords in this report:

- Administrator - username admin: seed account created and login succeeded in the temporary diagnostic copy; the final branch does not document distinct Administrator-only application functions or PostgreSQL privileges.
- Staff - username staff: seed account created and login succeeded in the temporary diagnostic copy; the final branch does not document distinct Staff-only application functions or PostgreSQL privileges.

Both roles can reach the same authenticated application modules in the inspected code. No separate role-to-database-role setup, group roles, or privilege grants are provided.

## Issues found

- The final branch hardcodes grp_parkitdb and a placeholder password in config/database.php; it does not use environment variables or provide .env.example.
- The hardcoded database name conflicts with the Activity 3 requirement to configure a separate local database and makes an unmodified final copy target the documented/shared database.
- XAMPP PHP reports pdo_pgsql=disabled by default, although the extension DLLs are present. The README instructs the user to enable extensions manually but does not provide a validation command.
- No standalone seed SQL file is included; sample data depends on running a PHP web script with a working database connection.
- No automated test suite or test command is included in the final branch.
- No Park-It PDF progress document is included.
- No dedicated user-role document, PostgreSQL role mapping, database account setup, or privilege documentation is included.
- Parking-zone create, update, and delete functions requested for this verification are not implemented in the final application. The available CRUD workflow is for vehicles, not parking zones.
- The README includes documented default passwords in the source guidance; the report omits them to avoid exposing credentials.
- The final branch README requires XAMPP/Apache but does not provide a command-line startup alternative or a clear way to configure a test database without editing source.

## Feedback

Replace hardcoded connection settings with environment-variable placeholders, add .env.example, add a standalone seed/migration procedure, document the PHP extension check, include the Park-It progress PDF and complete role/privilege mapping, add automated tests, and implement or clarify the parking-zone CRUD scope. Do not commit real passwords.

## Reproduction result

Failed to reproduce. The final branch schema and seed logic were usable in an isolated diagnostic copy, and several authenticated vehicle/monitoring functions worked after configuration overrides. The unmodified final branch could not satisfy the required separate-database setup because its connection settings are hardcoded, its password is a placeholder, and the default PHP PostgreSQL extension is disabled. The requested parking-zone create, update, and delete functions are also absent.

## Last updated

2026-11-06

