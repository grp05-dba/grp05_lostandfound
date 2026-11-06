# Part A - Database Setup and Assessment

## 1. Objective and review scope

Set up Group 4's BrewPOS database, inventory its objects and application operations, and identify access requirements before applying roles. This report follows Parts A-D of the Activity 4 assignment; the verification required by PDF Part E is in [part_d.md](part_d.md), using the filename requested for this submission.

Reviewed on **6 November 2026 (Asia/Manila)**. All work is in Group 5's local repository. The owning group's repository was cloned for inspection and was not edited or pushed to.

| Item | Verified value |
|---|---|
| Project | BrewPOS - Cafe Point-of-Sale System, Group 4 |
| Repository | [https://github.com/Nycri/brewpos](https://github.com/Nycri/brewpos) |
| Reviewed branch | `main` |
| Reviewed commit | `f2af982d7cd2709ebcb0e0f0fd00af27bc4286d4` |
| Database | `grp_brewposdb` |
| Schema | `public` |
| Database server and client | PostgreSQL 18.6, Windows x64; `psql` |
| Test endpoint | `127.0.0.1:55432`; separate, locally initialized test cluster |
| Authentication | SCRAM-SHA-256; independently authenticated login sessions |
| Backend | Java 17 target; Spring Boot 4.1.1 declared in `pom.xml` |
| Local JDK | Eclipse Temurin 25.0.2 |
| Ordinary application account | `brewpos_app`, not the provisioning superuser |

## 2. Sources and setup procedure

The review used the assignment PDF in the parent Activity 4 directory, Group 2's report structure, and these pinned upstream sources:

- [Setup guide](https://github.com/Nycri/brewpos/blob/f2af982d7cd2709ebcb0e0f0fd00af27bc4286d4/README.md) and [database administration guide](https://github.com/Nycri/brewpos/blob/f2af982d7cd2709ebcb0e0f0fd00af27bc4286d4/database/README.md).
- [Database documentation](https://github.com/Nycri/brewpos/blob/f2af982d7cd2709ebcb0e0f0fd00af27bc4286d4/database/DATABASE_DOCUMENTATION.md), [schema](https://github.com/Nycri/brewpos/blob/f2af982d7cd2709ebcb0e0f0fd00af27bc4286d4/database/schema.sql) and [seed data](https://github.com/Nycri/brewpos/blob/f2af982d7cd2709ebcb0e0f0fd00af27bc4286d4/database/seed.sql).
- [Application/database role documentation](https://github.com/Nycri/brewpos/blob/f2af982d7cd2709ebcb0e0f0fd00af27bc4286d4/docs/user-roles.md) and [upstream runtime-role script](https://github.com/Nycri/brewpos/blob/f2af982d7cd2709ebcb0e0f0fd00af27bc4286d4/database/05_create_app_role.sql).
- [Application configuration](https://github.com/Nycri/brewpos/blob/f2af982d7cd2709ebcb0e0f0fd00af27bc4286d4/src/main/resources/application.properties) and the Java controllers, services, repositories and entities.

The repository's clean-install procedure is to create `grp_brewposdb`, execute `database/schema.sql`, and then execute `database/seed.sql`. Alternative numbered schema/seed files were not run in addition to the consolidated files, avoiding duplicate object creation.

The existing Windows PostgreSQL service on port 5432 required a password unavailable to this session. Instead of changing that server, a new cluster was initialized under the workspace's `work/brewpos-lab` directory, listening only on loopback port 55432. Random local passwords were assigned without writing them into submitted SQL or evidence. This lab is independent of databases on port 5432.

Executed sequence:

1. Provision the NOLOGIN groups, three login accounts, project database and unrelated isolation-test database using [01_roles_database.sql](sql/01_roles_database.sql).
2. Connect as the provisioning administrator to `grp_brewposdb`, execute `SET ROLE brewpos_owner_grp`, then load the upstream `database/schema.sql` and `database/seed.sql` unchanged.
3. Reset to the provisioning administrator and run [02_privileges.sql](sql/02_privileges.sql).
4. Assign passwords locally and configure the scratch BrewPOS checkout's ignored `.env` to use `brewpos_app`, port 55432, and HTTP port 18081.
5. Connect independently as each account and execute the privilege checks recorded in [Part D](part_d.md).

The roles differ deliberately from running the optional upstream `05_create_app_role.sql`: this evaluation uses project-specific groups and grants fewer menu-item and sequence permissions. The optional upstream script was reviewed, not executed on top of the evaluated grants.

**Setup result: Success with issues.** Database initialization and application startup succeeded. [Setup output](evidence/setup.txt) contains the executed SQL and actual results; [catalog output](evidence/catalog.txt) verifies ownership, constraints, roles, ACLs and row counts. The unmodified application was packaged with Maven 3.10.0, started on loopback HTTP port 18081 and validated through populated API reads, checkout, receipt and daily-sales retrieval. PostgreSQL activity confirmed its connections used `brewpos_app`. The supplied Maven Wrapper hit a transport error; invoking the same declared Maven distribution directly resolved the build. The upstream JUnit suite was not run (`-DskipTests`). [Application validation](evidence/application_validation.txt) records the HTTP checks and cleanup; no browser interaction is claimed. Security limitations are recorded below.

## 3. Database structure

| Table | Primary key | Purpose | Seeded rows after test cleanup |
|---|---|---|---:|
| `staff` | `staff_id` | Demo cashier/manager identities and role labels | 2 |
| `menu_category` | `category_id` | Product categories | 3 |
| `menu_item` | `item_id` | Names, category, price and active status | 11 |
| `order_ticket` | `order_id` | Staff attribution, timestamp and payment method | 5 |
| `order_line_item` | `(order_id, item_id)` | Quantity and price captured at sale | 9 |

Four SERIAL sequences exist: `staff_staff_id_seq`, `menu_category_category_id_seq`, `menu_item_item_id_seq` and `order_ticket_order_id_seq`. Line items use a composite key and have no separate sequence. There are **nine indexes**: five primary-key indexes, two indexes enforcing the category-name and category/item-name unique constraints, and two query-support indexes (`idx_order_ticket_timestamp`, `idx_order_line_item_item_id`). The catalog is the authoritative inventory.

There are no application-defined views, materialized views, stored functions, procedures or triggers in the imported schema. System catalog objects and built-in routines are not counted as application objects. Temporary future-object probes were removed after testing.

Foreign keys connect category to item, staff to ticket, and ticket/item to line item. Default `NO ACTION` foreign-key behavior protects referenced parents. CHECK constraints restrict staff roles to `CASHIER`/`MANAGER`, payment methods to `CASH`/`ONLINE`, quantities to positive values, and prices to nonnegative values. Required columns are NOT NULL. Totals are derived as `SUM(quantity * sold_price)` rather than stored in a ticket total column.

Seeded sales totals were verified as **915.50 for 6 November (3 orders)** and **440.00 for 5 November (2 orders)**. The seed uses database-local `CURRENT_DATE`; the test cluster's timezone was explicitly set to Asia/Manila.

## 4. Application operations and access requirements

| Feature / reviewed implementation | Required database operations |
|---|---|
| Staff selector / `StaffService` | SELECT `staff`; there is no employee login screen |
| Category management / `MenuCategoryService` | SELECT, INSERT, UPDATE, DELETE `menu_category`; referenced categories cannot be deleted |
| Menu maintenance / `MenuItemService` | SELECT, INSERT, UPDATE `menu_item`; update includes active status and price |
| Register menu / `MenuQueryService` | SELECT categories and active items |
| Checkout / `OrderService.create` | SELECT staff/items; INSERT ticket and line items in one transaction |
| Receipts and history / `OrderService` | SELECT tickets, lines, staff and items |
| Daily sales / `SalesReportService` | SELECT and aggregate tickets and line items |

`MenuItemController` has no DELETE endpoint, and `MenuItemService` explicitly deactivates items. Completed-order controllers have no UPDATE/DELETE endpoints. JPA is configured with `ddl-auto=validate`; the application does not need schema creation privileges.

## 5. Initial findings and remaining issues

1. The configuration falls back to `postgres` unless `DB_USERNAME` is supplied. The local application configuration explicitly selects `brewpos_app`.
2. `docs/user-roles.md` describes groups, auditor and catalog-admin accounts, but claims they are automated by a script that actually creates only a direct-grant `brewpos_app` login with `NOINHERIT`. Our evaluated implementation creates the required groups and logins explicitly with inheritance enabled.
3. The upstream runtime script grants menu-item DELETE for test cleanup and USAGE/SELECT on every sequence. Production feature code needs no menu-item deletion and no staff-ID generation, so those privileges are omitted here.
4. Cashier and manager are demo application role labels, selected in a dropdown. One shared service login cannot enforce separate cashier/manager database permissions. The reviewed menu controller methods contain no server-side authentication/authorization checks. The UI selector is not a security boundary.
5. Denying UPDATE/DELETE on sales tables does not make whole receipts immutable: INSERT can append a missing item to an existing ticket. This was reproduced and rolled back; see [the historical append finding](evidence/historical_append_gap.txt).

**Scope status:** database initialized and the implemented role plan verified; the historical-append and application-authorization limitations remain. Recommendations are documented for owner feedback, but no feedback was sent, no tracker was edited, and no consolidated course-submission PDF was created in this four-report task.
