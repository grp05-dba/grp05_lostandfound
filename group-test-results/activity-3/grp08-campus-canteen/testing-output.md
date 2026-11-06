# Campus Canteen Testing Output

## Project tested

Group 8 - Campus Canteen Pre-Order and Queue Management System, Spring Boot/PostgreSQL Activity 3 project

## Testing group

Group 5

## Repository cloned

https://github.com/EclipseChan/bwisIT-Solutions---Campus-Canteen-Pre-Order-and-Queue-Management-System

The repository remote was verified with `git remote -v`. This checkout contains the Campus Canteen README, Spring Boot backend, React client, PostgreSQL scripts, and Campus Canteen documentation. It is not the Park-It project or another project clone.

## Branch and commit tested

Branch: `main`

Commit: `0c4aaf3f7bce1e29d38224b0d7a2b3e5d005fd1c` - Revise AI usage description in README - 2026-11-04 10:05:27 +08:00

Remote default branch evidence: `origin/HEAD -> origin/main`. Available remote branches were `origin/main`, `origin/activity-4`, and `origin/activity-5+6`. The README and the repository tracker file both specify `main` for testing.

Working-tree evidence before testing: `## main...origin/main` with no local changes. Source code, migrations, and seed files were not modified during testing.

## Activity 3 testing procedure

1. Verified the repository remote, available branches, default branch, latest commit, and working-tree state.
2. Confirmed the clone identity by reviewing the remote URL, README, package names, Java package names, frontend title, and database/documentation content.
3. Selected the documented/default `main` branch and recorded commit `0c4aaf3f7bce1e29d38224b0d7a2b3e5d005fd1c`.
4. Reviewed README.md, the progress tracker file, all files under docs/, pom.xml, frontend/package.json, frontend configuration, application.properties, backend scripts, database initialization/migration/seed/reset files, and the committed smoke test.
5. Identified prerequisites, configuration variables, sample accounts, application roles, startup commands, database setup commands, and documented API workflows.
6. Created an isolated PostgreSQL 18.6 cluster on localhost port 55434 and a new database named `canteen_activity3_test_20261106`. This database was separate from Park-It, OJT, BrewPOS, HabalGo, and all other project databases.
7. Created a local `.env` from `.env.example` using safe test-only placeholders for the database password and JWT secret. No repository source, schema, migration, or seed file was changed.
8. Ran the committed initialization, migration, and seed SQL in documented order. The interactive `database/setup.ps1` was then run successfully against the same isolated database after PostgreSQL bin was placed on PATH.
9. Started the API with Java 21, Maven 3.9.16, the documented environment variables, and Spring Boot on port 8080. The API connected to PostgreSQL 18.6 and returned seeded vendors.
10. Exercised public access, login, role checks, vendor menu CRUD and availability, student orders, queue assignment, status transitions, cancellation, notifications, admin stall controls, reports, and the committed `test-flow.ps1` smoke test.
11. Ran Maven `test` and recorded the automated-test result.
12. Recorded documentation gaps, setup-script and environment issues, unimplemented payment/transaction functionality, and all observed results below.

## Required software, dependencies, and configuration

- PostgreSQL 16 or newer; the test used PostgreSQL 18.6.
- JDK 21; the test used Temurin/OpenJDK 21.0.13. Java 25 was initially present but was not used for the final run because the README requires Java 21.
- Maven 3.9 or newer; Maven 3.9.16 was used. Maven was not installed on PATH initially, so a temporary official Maven binary was used for the test.
- Node.js 18 or newer for the optional React client; Node.js 24.15.0 was available. The backend/API and committed smoke test were the primary Activity 3 test surface; the README marks the web client optional.
- Spring Boot 3.4.1, Spring Data JPA, Spring Security/JWT, PostgreSQL JDBC driver, validation, Lombok, and Spring Boot test dependency are declared in `pom.xml`.
- React 18, Vite, and the declared frontend packages are in `frontend/package.json`.
- PostgreSQL database variables documented by the project: `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, and `JWT_SECRET`.
- Test configuration: `DB_HOST=localhost`, `DB_PORT=55434`, database name `canteen_activity3_test_20261106`, runtime login `canteen_admin`, and safe local placeholders for secret values. The actual secret values are omitted here.
- Database setup command: `powershell -ExecutionPolicy Bypass -File .\database\setup.ps1` after `.env` is created and PostgreSQL `bin` is available on PATH.
- Backend startup command: `powershell -ExecutionPolicy Bypass -File .\scripts\run-backend.ps1`. Direct `mvn spring-boot:run` with the documented environment variables was used for the successful functional run because the wrapper requires Maven to be available in the child process environment.
- Optional frontend command: `cd frontend`, `npm install`, then `npm run dev`.
- Sample account passwords are documented in the repository but are intentionally not repeated in this report.

## Documentation review

- README.md reviewed: identifies the Campus Canteen purpose, branch `main`, Java 21/Spring Boot/PostgreSQL stack, `.env` setup, database setup, startup, sample accounts, API checks, role checks, and smoke test.
- Progress documentation reviewed: the repository contains the `Tracker of Progress in Github` text file, but no PDF progress document is present in the clone.
- Database documentation reviewed: `docs/database.md` describes seven public tables, the migration order, seed data, constraints, and reset procedure.
- User-role documentation reviewed: `docs/user-roles.md` documents Public, Student, Vendor, Administrator, and Application runtime roles and maps end-user roles to the runtime database account.
- Database-role documentation reviewed: `docs/database-roles.md` documents the current Activity 3 owner account and sketches intended Activity 4 group roles; the separate Activity 4 roles were not created by the Activity 3 setup.
- API documentation reviewed: `docs/api-endpoints.md` lists authentication, vendor/menu, student order, vendor order, notification, admin, and report endpoints.
- Configuration reviewed: `.env.example` contains placeholders only; `application.properties` reads database and JWT environment variables.
- Automated-test review: `test-flow.ps1` is a committed end-to-end smoke script. Maven reports no test classes to run.

## Setup result

Successfully reproduced with documentation issues.

The isolated PostgreSQL cluster and database were created successfully. The committed initialization, migrations, and seed data completed successfully and produced the seven expected tables. The interactive `database/setup.ps1` completed with `Done. Database 'canteen_activity3_test_20261106' is ready.` after the PostgreSQL bin directory was placed on PATH. The API started successfully with Java 21 and connected to PostgreSQL 18.6. The API returned HTTP 200 for the public vendor endpoint.

The unmodified setup script's documented `-Psql` full-path option is defective in this environment: its `Get-Command` check rejected the full `psql.exe` path even though the path existed. The README's alternative of putting PostgreSQL `bin` on PATH worked. The backend wrapper also requires Maven to be available to the child process; with the fresh shell's Maven/JAVA setup, direct `mvn spring-boot:run` was used for the successful run. No source or database files were changed to address these issues.

Schema evidence: PostgreSQL reported successful creation of seven tables: `customer_order`, `menu_item`, `notification`, `order_item`, `queue_entry`, `student`, and `vendor`.

Seed evidence: the sample accounts, four vendors, menus, orders, queues, and notifications were available to the API. Re-running the documented setup completed without errors.

Automated test evidence: `mvn test` completed with `BUILD SUCCESS` and `No tests to run.` The committed `test-flow.ps1` completed with `All steps ran.`

## Essential functions verification

| Essential function | Expected result | Status |
|---|---|---|
| Database connection | API connects to the configured PostgreSQL database. | Working: Spring Boot logged a Hikari connection and PostgreSQL database version 18.6; `GET /api/vendors` returned HTTP 200. |
| Public vendor/menu retrieval | Active stalls and menu items are returned. | Working: HTTP 200; three active stalls and menu items were returned. |
| User login | Documented accounts authenticate and return roles. | Working: Administrator, three active Vendors, and two Students returned HTTP 200 with roles ADMIN, VENDOR, or STUDENT. The documented inactive Waffles Vendor returned HTTP 401 as expected. |
| Role-based access | Protected routes reject unauthenticated or mismatched users. | Working: anonymous orders, Student-to-Vendor orders, and Vendor-to-Admin calls returned HTTP 401. Admin, Vendor, and Student routes worked for their documented roles. |
| Vendor menu create | Vendor can add a menu item. | Working: HTTP 201; a test item was created. |
| Vendor menu retrieve | Vendor can retrieve their menu. | Working: HTTP 200. |
| Vendor menu update | Vendor can edit a menu item. | Working: HTTP 200; name and price changed. |
| Canteen item availability | Vendor can hide/show an item. | Working: HTTP 200; availability changed to false. |
| Vendor menu delete | Vendor can delete a newly created menu item. | Working: HTTP 200. |
| Pre-order creation | Student can place an order with quantity, pickup time, total, and queue number. | Working: HTTP 201; queue number and total were returned. |
| Order retrieval | Student and Vendor can retrieve applicable orders. | Working: both returned HTTP 200 with order records. |
| Queue management | Orders receive ordered queue numbers and people-ahead counts. | Working: committed smoke test returned sequential queue numbers 5 and 6 and people-ahead count 1 for the second order. |
| Order status updates | Vendor can move an order through preparing, ready, and completed. | Working: all three PATCH operations returned HTTP 200; backward transition returned HTTP 409. |
| Order cancellation | Student can cancel a pending order. | Working: cancellation returned HTTP 200 and status `cancelled`. |
| Notifications | Student receives order status notifications. | Working: HTTP 200; placement, preparing, ready, completed, and cancellation notifications were returned. |
| Admin stall management | Administrator can switch a stall off/on and see the public list change. | Working: both PATCH operations returned HTTP 200; public active-stall count changed from 3 to 4 and back to 3. |
| Sales reports | Vendor and Administrator can retrieve sales reports. | Working: both report endpoints returned HTTP 200 with order totals/revenue data. |
| Payment or transaction records | Payment/transaction data is persisted and accessible. | Not implemented/documented: the database contains no payment or transaction table and the documented API has no payment/transaction endpoint. |
| Generic order delete | An order can be deleted. | Not implemented as delete; the documented workflow provides cancellation instead. |
| Frontend client | Optional React client starts on port 5173. | Not exercised in this first-time API verification; README marks the web client optional. |

## Application roles checked

The documented sample accounts were exercised without recording their password:

- Administrator - `admin@canteen.test`: login HTTP 200, role ADMIN; admin vendor list, stall availability, and canteen sales report worked.
- Vendor - `nena@vendor.test`: login HTTP 200, role VENDOR; menu CRUD, availability, vendor orders, status changes, and vendor report worked.
- Vendor - `jun@vendor.test`: login HTTP 200, role VENDOR.
- Vendor - `merienda@vendor.test`: login HTTP 200, role VENDOR.
- Vendor - `waffles@vendor.test`: login HTTP 401; the documented stall is inactive, so this result matches the documentation.
- Student - `maria@student.test`: login HTTP 200, role STUDENT; order creation, retrieval, cancellation, notifications, and unauthorized vendor-route check were exercised.
- Student - `juan@student.test`: login HTTP 200, role STUDENT.

The Public role was also checked through unauthenticated vendor/menu retrieval. The Application runtime connection used the documented Activity 3 `canteen_admin` database login. The intended Activity 4 group roles were documented but not created by the Activity 3 setup.

## Issues found

- No PDF progress document is present in the repository, although the official Activity 3 instructions require one.
- The repository tracker text says the group number is TBD and does not provide a linked PDF progress document or testing-log row.
- `database/setup.ps1 -Psql "full path"` is documented but rejected the full path in its own `Get-Command` check. Putting the PostgreSQL bin directory on PATH worked.
- The backend startup wrapper requires Maven on PATH and inherits the local Maven repository environment. In the fresh shell it attempted to use inaccessible `C:\.m2\repository`; direct Maven startup worked after providing the documented prerequisites explicitly.
- The clone does not bundle Maven or JDK 21, so a clean machine must install both before setup/startup. This is stated in the README, but no Maven wrapper is included.
- Maven `test` has no test classes; the only executable automated verification is the committed PowerShell smoke script.
- The database has no payment, transaction, or payment-record table and the API has no corresponding endpoint, while payment/transaction validation is a possible Activity 3 essential-function category. This scope is not called out as an intentional omission in the README.
- Activity 3 database setup uses the owner login `canteen_admin` as the application runtime account. The documented least-privilege `canteen_app` and group roles are deferred to Activity 4.
- The root `add_auth_columns.sql` duplicates the migration file, creating two possible paths for the same schema change.
- The optional frontend was not part of the API-first functional run; no claim is made here about its browser workflows.

## Feedback

Include the required PDF progress document and tracker links, fix the setup script's full-path check, make the backend wrapper's Maven/JAVA prerequisites clearer or add a Maven wrapper, add automated test classes or label the smoke script as the primary test, document whether payment/transaction functionality is out of scope, and complete the Activity 4 database-role setup when required. Do not commit real passwords or secrets.

## Reproduction result

Successfully reproduced with documentation issues. The Campus Canteen database initialized in an isolated PostgreSQL 18.6 database, sample data loaded, the Spring Boot API started on Java 21, all documented application accounts were checked, core student/vendor/administrator workflows passed, and the committed smoke test ended with `All steps ran.` The report does not claim payment/transaction support because no such table or endpoint exists, and the optional React client was not exercised.

## Last updated

2026-11-06
