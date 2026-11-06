# BoardTrack Testing Output

## Project tested

Group 11 - BoardTrack Boarding House and Rental Management System, Node.js/Express/PostgreSQL application

## Testing group

Group 5

## Repository cloned

https://github.com/karlrobertc-art/BoardTrack

The checkout is a valid Git repository. The remote was verified with `git remote -v`. The working tree was clean before testing. Dependencies installed by `npm ci` were ignored generated files; no tracked source, schema, migration, seed, or documentation file was changed during testing.

## Branch and commit tested

Branch: main

Commit: 568446d18d122db8d7d224eb4d6c9361a096ec8a - Create act-report - 2026-11-05 23:59:30 +08:00

Working-tree evidence before testing: `## main...origin/main` with no changes.

## Activity 3 testing procedure

1. Verified the Git repository, `origin` remote, available branches, latest commit, and working-tree state.
2. Reviewed the README, all Markdown documentation, source routes/views, configuration examples, migration, seed, bundled SQL setup, startup scripts, package files, and available tests.
3. Extracted and followed the official COMP 018 Activity 3 requirements: use a separate local PostgreSQL database, run migrations or initialization, load sample data, start the application, test essential database operations and documented roles, and do not modify the original repository to make it work.
4. Confirmed Node.js and npm versions and used PostgreSQL 18. A new temporary PostgreSQL 18 cluster was initialized on port 55435 with a new database named `boardtrack_activity3_test_20261106`. It was not the existing PostgreSQL service or any Park-It, OJT, BrewPOS, HabalGo, CampusSafe, restaurant, or other project database.
5. Installed the committed dependencies with `npm ci`.
6. Applied the documented configuration variables from `.env.example` in the test process, using a safe local test session secret and a database URL with no password because the isolated cluster used local trust authentication. No `.env` containing credentials was committed.
7. Ran `npm run db:migrate` and `npm run db:seed`, then started the application with `npm start` equivalent (`node src/server.js`) on port 3017.
8. Tested the database connection, dashboard, all documented application pages, landlord CRUD workflows, the lease-overlap rule, role permissions, and tenant row filtering through HTTP requests against the running app.
9. Ran the available automated-test command and recorded its result.

## Required software, dependencies, and configuration

- Node.js 20.12 or newer. The test machine provided Node.js v24.15.0.
- npm. The project uses `package-lock.json`; `npm ci` installed 94 packages and reported 0 vulnerabilities.
- PostgreSQL 13 or newer; the README says the project is written for PostgreSQL 18 and uses features available since 13. The test used PostgreSQL 18 in a separate temporary cluster.
- Node dependencies: Express 4.19.2, EJS 3.1.10, express-session 1.18.0, and `pg` 8.12.0 as specified by `package.json`.
- Database name: `boardtrack_db` by default in `.env.example`, configurable through `DATABASE_URL`. The tested database was `boardtrack_activity3_test_20261106`.
- Environment variables: `DATABASE_URL`, `PORT`, `SESSION_SECRET`, `AUTO_CREATE_DB`, `AUTO_SETUP`, and `AUTO_SEED`. The report does not include credentials or connection secrets.
- Startup command: `npm start`.
- Database commands: `npm run db:setup`, `npm run db:migrate`, `npm run db:seed`, and `npm run db:reset`; the test used `db:migrate` and `db:seed` before startup.
- Required PostgreSQL extensions: `btree_gist` for the lease overlap exclusion constraint and `pgcrypto` for password hashing. Both were created successfully by the migration.
- Sample accounts: `landlord` (admin), `caretaker` (staff), and `juan` (tenant, tenant ID 1). Passwords are intentionally omitted from this report.

## Documentation review

- README reviewed: project purpose, prerequisites, automatic setup, optional launchers, database commands, demo accounts, quick test workflow, layout, and documentation links.
- Database documentation reviewed: tables, relationships, keys, checks, exclusion constraint, triggers, view, indexes, and migration tracking.
- User-role documentation reviewed: Administrator, Staff, Tenant, and application runtime roles, plus intended PostgreSQL group roles for Activity 4.
- Troubleshooting documentation reviewed: database creation, missing tables, extension permissions, port, login, and overlap-rule guidance.
- How-it-works documentation reviewed: request flow, permission table, route structure, setup, and migration/seed locations.
- AI usage documentation reviewed: it explicitly says the group still needs to run every script on a clean PostgreSQL install and complete the validation declaration.
- Migration and seed review: `db/migrations/001_schema.sql`, `db/seeds/001_sample_data.sql`, and `db/boardtrack_full_setup.sql` define the schema, triggers, view, sample records, and demo accounts.
- PDF progress documentation: no PDF file is present in this repository, although the official Activity 3 instructions require a PDF progress document.
- Automated tests: no test files are present and `package.json` has no `test` script.

## Setup result

Successfully reproduced with documentation issues. The clean isolated PostgreSQL database was created, the migration and seed commands both exited 0, the application started on the first run, and the documented accounts and workflows were exercised. The application reported the migration as applied and skipped reseeding on its subsequent startup, as documented.

Database evidence after setup: database `boardtrack_activity3_test_20261106`; migration `001_schema.sql`; tables `app_user`, `lease`, `payment`, `property`, `room`, `schema_migrations`, `tenant`, and `utility_bill`; seeded accounts `landlord`, `caretaker`, and `juan`; seeded counts of 2 properties, 6 rooms, 4 tenants, 4 leases, 6 payments, and 4 utility bills.

The application served the login page with HTTP 200 and started at `http://localhost:3017`. The test used the repository's committed setup and application files without source, schema, migration, or seed changes.

## Essential functions verification

| Essential function | Expected result | Status |
|---|---|---|
| Database connection and startup | App connects to PostgreSQL, applies setup, and starts. | Working: migration and seed exited 0; app started and served login/dashboard. |
| Dashboard and summary | Authenticated user sees dashboard counts and financial summary. | Working: landlord, caretaker, and Juan dashboard requests returned HTTP 200; lease summary view returned seeded totals. |
| Retrieve/list properties, rooms, tenants, leases, payments, and bills | Authenticated users with read permission can view records. | Working: landlord and applicable staff/tenant requests returned HTTP 200. |
| Property CRUD | Administrator can create, retrieve, update, and delete properties. | Working: test property was created, retrieved, updated, and deleted through the application. |
| Room CRUD | Administrator can create, retrieve, update, and delete rooms. | Working: test room was created, retrieved, updated, and deleted. |
| Tenant CRUD | Administrator can create, retrieve, update, and delete tenants. | Working: test tenant was created, retrieved, updated, and deleted. |
| Lease CRUD and room-status trigger | Administrator can create, retrieve, update, and delete leases; room status follows active leases. | Working: test lease was created, updated to TERMINATED, and deleted; seeded room statuses and the summary view were consistent. |
| Payment CRUD and totals | Administrator can create, retrieve, update, and delete payments; lease totals change. | Working: test payment was created, retrieved, updated, and deleted; seeded lease totals were returned by `v_lease_summary`. |
| Utility-bill CRUD and totals | Administrator can create, retrieve, update, and delete utility bills; lease utility totals change. | Working: test bill was created, retrieved, updated, and deleted; seeded utility totals were returned by `v_lease_summary`. |
| Overlapping active lease rejection | Database blocks overlapping ACTIVE leases for one room. | Working: the documented overlap attempt returned HTTP 400 and no conflicting lease was added. |
| Role permissions and tenant filtering | Staff and tenant access matches documented permissions. | Working: caretaker received HTTP 403 for property creation; Juan received HTTP 200 for dashboard/own leases/payments/bills and HTTP 403 for properties, rooms, and tenants. |
| Search, filtering, and separate reports | Documented or implemented search/filter/report screens work. | Not implemented or documented as a separate feature: no search/filter/report routes or controls were found; the available reporting behavior is the dashboard and lease summary view. |

## Application roles checked

- Administrator (`landlord`): login succeeded; dashboard and all seven documented pages were reachable; full CRUD tests passed for properties, rooms, tenants, leases, payments, and utility bills; overlap validation returned HTTP 400.
- Staff (`caretaker`): login succeeded; dashboard, properties read-only, rooms update-capable, tenants/leases/payments/bills create-read-update pages were reachable; property creation correctly returned HTTP 403.
- Tenant (`juan`): login succeeded; dashboard and tenant-filtered leases, payments, and bills were reachable; properties, rooms, and tenants correctly returned HTTP 403.
- Application runtime/PostgreSQL roles: the documentation describes intended Activity 4 database roles, but those roles are explicitly not executed in Activity 3. No separate PostgreSQL login was created for end users.

No passwords, API keys, tokens, or secret connection strings are included in this report.

## Issues found

- No PDF progress document is included, despite the Activity 3 repository requirement.
- No automated test suite is included. `npm test` failed with `Missing script: "test"`.
- The AI usage document still contains a group-completion placeholder stating that clean-install testing and corrections must be recorded.
- The README documents database setup and essential CRUD/constraint workflows, but it does not identify a separate search/filter/report feature. Source inspection found no search or filter implementation beyond tenant row filtering and no separate report route.
- The README says `psql` must be available; on the test machine it was not on PATH, so the full PostgreSQL 18 client path was required. The application itself did not depend on `psql` for the tested migration/seed commands.
- The default database name in `.env.example` is generic (`boardtrack_db`). The documentation correctly states that `DATABASE_URL` is configurable, but a first-time tester must choose a unique database name to avoid collisions with any existing local BoardTrack database.
- The user-role document maps intended PostgreSQL roles to Activity 4 and correctly says they are not executed in Activity 3; no database role/privilege verification was therefore applicable to this activity.

## Feedback

Add the required PDF progress document, add an automated test command and test coverage for constraints and role permissions, complete the AI usage validation declaration, clarify whether search/filter/reporting is out of scope, and add a short warning to use a unique local database name during cross-group testing.

## Reproduction result

Successfully reproduced with documentation issues. BoardTrack was installed from the tested `main` commit, configured against a new isolated PostgreSQL database, migrated, seeded, started for the first time, and exercised through the documented application roles and essential CRUD/database workflows. The remaining issues are repository/documentation/test-suite gaps, not setup or runtime failures.

## Last updated

2026-11-06
