# BrewPOS Testing Output

## Project tested

Group 4 - BrewPOS Cafe Point-of-Sale System

## Testing group

Group 5

## Repository cloned

https://github.com/Nycri/brewpos

The directory was already a valid Git clone. The repository default branch was `main` (`origin/HEAD -> origin/main`). Available remote branches included `origin/main` and `origin/G02_Act_4,5,6`, `origin/G03_Act_4,5,6`, `origin/G05_Act_4,5,6`, `origin/G06_Act_4,5,6`, `origin/G07_Act_4,5,6`, `origin/G08_Act_4,5,6`, and `origin/G10_Act_4,5,6`. No tracker branch value was available in the supplied project, so the default branch was selected.

Branch tested: `main`  
Commit tested: `7afdd4d27b76f4bdac4a447d703a78f04f10f95f` (`chore: ignore local PDF documentation drafts`)

## Activity 3 testing procedure

1. Verify the repository remote, branches, default branch, and latest commit.
2. Review the README, testing guide, PDF progress documentation, user-role documentation, dependency/configuration files, SQL scripts, and automated tests.
3. Create and use a separate PostgreSQL database and local application configuration for BrewPOS.
4. Execute the documented schema and seed scripts.
5. Start BrewPOS using the documented Maven command.
6. Verify the database connection, seeded data, documented role views, menu management, orders, reports, validation, and CRUD behavior.
7. Run the repository automated tests.
8. Record setup gaps and results without modifying source code, schema, migrations, or seed files.

## Required software, dependencies, and configuration

- Git.
- Java Development Kit 17 or newer. The test machine used Java 25 (`javac 25`).
- PostgreSQL 16, 17, or 18; the test used PostgreSQL 18.6.
- A modern web browser.
- Internet access for the Maven Wrapper's first dependency download.
- Java Spring Boot 4.1.1, Spring Data JPA, Bean Validation, Spring Web MVC, and the PostgreSQL JDBC driver, declared in `pom.xml`.
- The included Maven Wrapper (`mvnw.cmd`).
- Documented database name: `grp_brewposdb`, schema `public`.
- Documented environment variables: `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`, and `SERVER_PORT`.
- Tested local configuration used an isolated PostgreSQL 18.6 cluster on port `55432`, database `grp_brewposdb`, database user `postgres`, and application port `8081`. No real credential was used or recorded.
- Startup command: `.\mvnw.cmd spring-boot:run`.
- Database initialization commands: create the database, then run `database/schema.sql` and `database/seed.sql`.
- Automated test command: `.\mvnw.cmd test`.
- Sample staff records: `Demo Cashier` (`CASHIER`) and `Demo Manager` (`MANAGER`). The application has no login screen; the top-right selector changes the demo UI view.

## Documentation review

- README reviewed: covers prerequisites, PostgreSQL setup, environment variables, startup, troubleshooting, and the four main screens.
- `TESTING_GUIDE.md` reviewed: documents the browser walkthrough, sample data expectations, role-view checks, order workflow, reports, validation, and automated test command.
- `docs/user-roles.md` reviewed: documents Store Manager, Cashier, Viewer/Auditor, and Application Runtime mappings to intended PostgreSQL roles.
- `database/README.md` and `database/DATABASE_DOCUMENTATION.md` reviewed: document the five tables, keys, constraints, indexes, database name, seed behavior, and optional `brewpos_app` role.
- `pom.xml` and `src/main/resources/application.properties` reviewed.
- SQL setup reviewed: `schema.sql`, `seed.sql`, standalone SQL files, verification queries, and the optional application-role script.
- Automated tests reviewed: 19 JUnit tests across application context, controller, service, and transaction rollback coverage.
- PDF progress documentation: no PDF progress document is present in the repository at the tested commit.

## Setup result

**System operational after setup.** The isolated PostgreSQL cluster started successfully; `database/schema.sql` created the five tables and indexes; `database/seed.sql` inserted two staff records, three categories, eleven menu items, and five sample orders. The application started successfully on port 8081 and connected to PostgreSQL 18.6 with Hibernate schema validation enabled.

Database verification returned exactly these five public tables: `menu_category`, `menu_item`, `order_line_item`, `order_ticket`, and `staff`.

Command tested: `.\mvnw.cmd spring-boot:run`  
Result: **successful**; Spring Boot reported `Started BrewPosApplication` and Tomcat port 8081.

Automated command tested: `.\mvnw.cmd test`  
Result: **19 tests run, 0 failures, 0 errors, 0 skipped; BUILD SUCCESS**.

The first test run without a real-looking `DB_PASSWORD` marker skipped 10 database-conditional tests because of the repository's `DbTestCondition`; rerunning with a local non-secret marker enabled all 19 tests. This is recorded as a test-configuration observation, not a source change.

## Essential functions verification

| Essential function | Expected result | Status |
|---|---|---|
| Database connection | Application connects to the separate BrewPOS PostgreSQL database. | Working; live startup and Hibernate connection succeeded. |
| Application root/static page | `GET /` serves the BrewPOS page. | Working; HTTP 200. |
| Retrieve staff/sample accounts | Demo Cashier and Demo Manager are returned. | Working; both returned by `GET /api/staff`. |
| Retrieve active menu | Three categories and active items are returned. | Working; inactive Pumpkin Spice Latte was absent from active menu. |
| Create category | New category can be created. | Working; HTTP 201. |
| Retrieve/update category | Category data can be retrieved and renamed. | Working; live create/update verified. |
| Delete category | Unused category can be deleted. | Working; HTTP 204. |
| Create menu item | New item can be added to a category. | Working; HTTP 201. |
| Retrieve/update menu item | Item details and price can be updated. | Working; live update verified. |
| Activate/deactivate menu item | Item visibility can be toggled without deleting history. | Working; live false/true transitions verified. |
| Create order/transaction | A valid order is recorded with payment method and line items. | Working; order 10 created with two units and total 219.98. |
| Retrieve order/receipt | Created order and line items can be retrieved. | Working; order 10 retrieved with one merged line. |
| Daily sales report | Daily total and completed order count are returned. | Working; live report returned total sales 1135.48 and four orders after the test order. |
| Duplicate category validation | Duplicate category is rejected. | Working; HTTP 409 for `Coffee`. |
| Invalid order validation | Invalid payment/empty order is rejected. | Working; HTTP 400. |
| Role-based UI view | Cashier view is read-only and Manager view exposes menu controls. | Not directly exercised in a browser because the computer-use browser host was unavailable. The source and HTML document these demo views; the API has no authentication boundary. |

## Application roles checked

The seeded `Demo Cashier` and `Demo Manager` records were retrieved and used for live API operations. The repository documents a `Viewer / Auditor` role and an Application Runtime database account, but provides no corresponding end-user login or sample account for either. The README explicitly states that the selector is a demo UI switch and that login/authentication is outside scope.

The role-specific browser visibility check was not claimed as passed because browser automation was unavailable. API endpoints do not require authentication, so this test does not establish security enforcement between Cashier and Manager.

## Issues found

- No PDF progress document is present in the repository, although Activity 3 requires one.
- The documented application roles are demo UI modes rather than authenticated user roles; the API has no login or authorization path.
- The documented Viewer/Auditor role has no application login or sample account to exercise.
- `docs/user-roles.md` describes `app_runtime_grp`, `app_readonly_grp`, and `app_admin_grp`, but `database/05_create_app_role.sql` creates/configures only the `brewpos_app` login and its direct grants. The additional group-role and auditor/admin accounts are documented as intended mappings, not executable setup supplied by that script.
- The testing guide says the project includes 19 automated tests, but database-conditional tests are skipped unless `DB_PASSWORD` is a non-placeholder value. The reason is visible in `src/test/java/com/brewpos/DbTestCondition.java` but is not highlighted in the testing guide.
- Visual browser role switching could not be independently verified in this environment because the browser automation host was unavailable; this is an environment limitation and is not presented as a project success.

## Feedback

Commit the required PDF progress document, clarify that Cashier/Manager are demo view modes rather than authentication, either implement/document the Viewer/Auditor workflow or mark it out of scope, and align `docs/user-roles.md` with the actual role-creation SQL script.

## Reproduction result

**Successfully reproduced with documentation issues.** BrewPOS was initialized in a separate PostgreSQL database, seeded, started for the first time, connected successfully, and its live API CRUD/order/report workflows and all 19 automated tests passed. The missing PDF, incomplete executable role setup, lack of authentication, and unavailable direct browser role check prevent a clean documentation/role-verification result.

## Last updated

2026-11-06
