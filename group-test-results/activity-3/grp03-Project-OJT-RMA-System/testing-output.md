# OJT Management System Testing Output

## Project tested

Grpuo 3 - Project-OJT-RMA-System

## Testing group

Group 5

## Repository cloned

https://github.com/swvenz/Project-OJT-RMA-System.git

Branch tested: `main`

## Activity 3 testing procedure

1. Open the class tracker and clone the repository of every other group, excluding your own group, using the listed repository URLs.
2. For each project, review the README, PDF progress documentation, and user-roles documentation. Identify the required software, dependencies, and configuration.
3. Configure the application and its own PostgreSQL database locally. Keep each project database separate from the others.
4. Execute the database migrations or SQL initialization scripts.
5. Load the provided sample data.
6. Start the application, test its essential functions, and verify that the documented user roles can be exercised, such as by logging in with sample accounts.
7. Record missing instructions, configuration errors, database inconsistencies, and other issues for each project in the Activity 3 Testing Log tab of the tracker.
8. Send feedback to each project’s original developers and record whether the project can be successfully reproduced in the Activity 3 Testing Log.

## Required software, dependencies, and configuration

- Java. Java 25 was available locally and the Java source compiled successfully with `javac`.
- PostgreSQL. PostgreSQL 18.6 was available locally and the service was running.
- PostgreSQL JDBC driver. The repository does not include a JDBC driver JAR, dependency manifest, or documented classpath setup for one.
- The repository contains compiled classes under `target/classes`, including `db.properties`.
- The README describes PostgreSQL and a Java environment only. It does not document a build command, dependency installation command, or application start command.
- `target/classes/db.properties` points to `jdbc:postgresql://localhost:5432/OJT_Mangementdb` and contains a PostgreSQL username and password. The application reads this generated classpath file, not the root `.env` file.

## Documentation review

- README reviewed: it describes the OJT Management System and general PostgreSQL setup, but does not identify the Java framework, JDBC dependency, build command, startup command, migration filename, seed filename, or sample login accounts.
- PDF progress documentation: no PDF progress document was present in the supplied repository.
- User roles documentation: no dedicated user-roles document was present. The source code references `ADMIN`, `STUDENT`, `ACADEMIC_SUPERVISOR`, `COMPANY_SUPERVISOR`, and `OJT_COORDINATOR`, but their permissions and test accounts are not documented in the README.
- Database documentation: the supplied database archive is a PostgreSQL custom-format dump, despite the README describing it as an SQL migration script.

## Setup result

**Failed with blocking configuration and database inconsistencies.** A separate local database was created and the supplied custom-format archive was restored successfully with `pg_restore`. The restored database contained the `lending` schema with `customers` and `loans` tables and two sample customer rows and two sample loan rows.

Database initialization command tested: `pg_restore --no-owner --no-acl --exit-on-error "OJT Database.sql"`  
Database initialization result: **successful, but schema does not match the application**  
Source compilation command tested: `javac -d <temporary-output> system\\*.java`  
Source compilation result: **successful**  
Application startup: **failed**  
Database connection verification: **failed**  
Automated test command: **not available**

The Java application code expects tables including `requirements`, `users`, `companies`, `students`, `academic_supervisors`, and `company_supervisors`. The restored archive provides only `lending.customers` and `lending.loans`. The repository also lacks the PostgreSQL JDBC driver and a documented runtime classpath, so the compiled application cannot establish its database connection from the supplied repository alone.

## Essential functions verification

| Essential function | Expected result | Status |
|---|---|---|
| Database connection | The application connects to its PostgreSQL database. | Failed |
| Database schema initialization | Application tables are created from the supplied initialization resource. | Failed: dump contains unrelated `lending` tables |
| Sample data loading | Sample records support immediate application testing. | Failed: sample data is for customers and loans, not OJT entities |
| Application startup | The Java application opens its sign-in window. | Failed |
| User login | A documented sample account can sign in. | Not testable |
| Role-specific workflows | Each documented application role can exercise its permitted functions. | Not testable |
| Student workflow | Student records and OJT functions are available. | Not testable |
| Supervisor workflow | Academic and company supervisor functions are available. | Not testable |
| Administrator workflow | User and system administration functions are available. | Not testable |

## Application roles checked

No role could be exercised because the application could not complete database initialization or startup. Roles referenced by the source include `ADMIN`, `STUDENT`, `ACADEMIC_SUPERVISOR`, `COMPANY_SUPERVISOR`, and `OJT_COORDINATOR`, but no sample usernames or passwords are documented.

## Issues found

- The supplied PostgreSQL dump is for a `lending` schema with `customers` and `loans`, not the OJT schema expected by the Java application.
- The README database names are inconsistent: it mentions `ojt_managementdb` and `ojt_management`, while `db.properties` uses the misspelled `OJT_Mangementdb`.
- The database password is stored in the generated `target/classes/db.properties`; the repository provides no safe, documented configuration process for a fresh environment.
- The root `.env` is not read by the Java source, so the README’s `.env` configuration does not configure the application.
- No PostgreSQL JDBC driver JAR, Maven/Gradle build file, dependency list, or classpath instructions are included.
- No application startup command is documented.
- No executable migration script matching the application tables is included.
- No executable seed script matching the application tables is included.
- No PDF progress documentation was supplied.
- No user-roles documentation, role-to-database-role mapping, or sample login accounts were supplied.
- No automated test suite or test command is supplied.

## Feedback

Replace the unrelated lending dump with an OJT schema and seed script; standardize the database name; remove committed/generated credentials; add `.env.example`; include the PostgreSQL JDBC dependency and build/run instructions; document roles and sample accounts; add the required progress PDF and automated tests; and verify the repository from a clean environment before marking it ready for testing.

## Reproduction result

**Not successfully reproduced.** The Java source compiles and the supplied database archive restores, but the restored schema is incompatible with the application and the repository does not provide the runtime JDBC dependency or complete configuration required to start the application.

## Last updated

2026-11-06
