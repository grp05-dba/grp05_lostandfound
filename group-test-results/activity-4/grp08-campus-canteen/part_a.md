# Part A - Database Setup and Assessment

## 1. Scope and source identity

Group 5 evaluated **Group 8 - Campus Canteen Pre-Order and Queue Management System** on **6 November 2026 (Asia/Manila)**. The assignment is `COMP018_Activity_4.docx-1.pdf` in the parent folder. Group 2's reports were used as a structural reference, with completed verification recorded here rather than copying its pending setup status.

| Item | Verified value |
|---|---|
| Source repository | [G08 repository](https://github.com/EclipseChan/bwisIT-Solutions---Campus-Canteen-Pre-Order-and-Queue-Management-System) |
| Branch / reviewed commit | `main` / `5056cb1c1cddca71c0641dd01fc7b82082f1c3ed` |
| Upstream default database | `canteen_db`, schema `public` |
| Isolated evaluation database | `canteen_g05_activity4` |
| Local endpoint | `127.0.0.1:55408`, PostgreSQL **18.3** server/client, SCRAM-SHA-256 |
| Backend | Java 21; Spring Boot 3.4.1 declared by `pom.xml` |
| Local build tools | Eclipse Temurin 21.0.13+9; Maven 3.9.15 |
| HTTP evaluation endpoint | `127.0.0.1:18088` |
| Application database login | `canteen_app`; no superuser/owner membership |

Reviewed sources: [setup instructions](https://github.com/EclipseChan/bwisIT-Solutions---Campus-Canteen-Pre-Order-and-Queue-Management-System/blob/5056cb1c1cddca71c0641dd01fc7b82082f1c3ed/README.md), [application roles](https://github.com/EclipseChan/bwisIT-Solutions---Campus-Canteen-Pre-Order-and-Queue-Management-System/blob/5056cb1c1cddca71c0641dd01fc7b82082f1c3ed/docs/user-roles.md), [database role design](https://github.com/EclipseChan/bwisIT-Solutions---Campus-Canteen-Pre-Order-and-Queue-Management-System/blob/5056cb1c1cddca71c0641dd01fc7b82082f1c3ed/docs/database-roles.md), [privilege matrix](https://github.com/EclipseChan/bwisIT-Solutions---Campus-Canteen-Pre-Order-and-Queue-Management-System/blob/5056cb1c1cddca71c0641dd01fc7b82082f1c3ed/db-access-control/README.md), migrations, seed data, configuration, Java entities/controllers/services and upstream role scripts. No own-project progress PDF was found in the cloned source. The owning repository's tracked files were not changed or pushed.

## 2. Database and application setup

The documented order is roles/memberships, database creation, migrations `001_create_tables.sql` and `002_auth_columns.sql`, sample data `001_sample_data.sql`, database/schema/table/sequence/default grants, then API startup. Both root `add_auth_columns.sql` and migration 002 contain the authentication changes; only the numbered migration was executed.

For this evaluation, a **new loopback-only cluster** was initialized at `D:/Data Administration/course-review/g08-activity4-lab/pgdata`. Existing servers/databases were not accessed or modified. New project-specific security objects prevent collisions with roles in other labs.

Executed sequence:

1. Run [01_roles_database.sql](sql/01_roles_database.sql) as the lab provisioning administrator in `postgres`.
2. Assign separate random local passwords to the three login roles without recording them in SQL, logs or submissions.
3. In `canteen_g05_activity4`, use `SET ROLE canteen_owner_grp` and execute the upstream migrations 001 and 002 and seed 001 **unchanged**.
4. Apply [02_privileges.sql](sql/02_privileges.sql) to the target database and [03_lab_isolation.sql](sql/03_lab_isolation.sql) to this dedicated cluster only.
5. Package the unmodified backend using JDK 21 and `mvn -B package`. Build succeeded; Maven reported **No tests to run**, so build success is not an automated application-test claim.
6. Start the generated JAR with process-local `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER=canteen_app`, private `DB_PASSWORD` and private `JWT_SECRET`. Bind HTTP to loopback port 18088. Spring Boot reads environment values; merely copying `.env` is insufficient when launching `java -jar` directly.
7. Execute independent psql logins and real HTTP checks. Evidence: [setup](evidence/setup.txt), [build](evidence/build.txt), [startup](evidence/application-startup.txt), [runtime identity](evidence/application-runtime.txt), [HTTP results](evidence/application-tests.json), and [catalog](evidence/catalog.txt).

**Setup result: Success with issues.** Schema, sample data, backend startup and essential HTTP workflows worked using the evaluated restricted runtime login. This is an adapted, tested access-control implementation, not a claim that upstream scripts were all executed unchanged. The optional React client and browser interaction were not tested.

## 3. Object inventory

| Table | Purpose | SERIAL sequence | Seed rows |
|---|---|---|---:|
| `student` | Student/admin identities and authentication | `student_student_id_seq` | 3 |
| `vendor` | Stalls, activity and vendor authentication | `vendor_vendor_id_seq` | 4 |
| `menu_item` | Vendor menu, price and availability | `menu_item_item_id_seq` | 10 |
| `customer_order` | Student/vendor order, pickup time, status | `customer_order_order_id_seq` | 2 |
| `order_item` | Order lines and captured price | `order_item_order_item_id_seq` | 2 |
| `queue_entry` | Daily queue number and service status | `queue_entry_queue_id_seq` | 2 |
| `notification` | Order messages and read status | `notification_notification_id_seq` | 3 |

Seven tables and seven sequences were inventoried. No application views, user-defined functions or non-internal triggers remain after the temporary probes. Primary/unique keys, foreign keys and CHECK constraints are listed in [catalog evidence](evidence/catalog.txt). Important restrictions include valid order/queue statuses, positive line quantities, nonnegative menu prices, unique account emails and unique daily queue numbers.

## 4. Database operations observed in source

| Feature / component | Required operations |
|---|---|
| Student/vendor registration and login (`AuthService`) | SELECT on both account tables; INSERT on student/vendor |
| Public stalls and menus | SELECT vendor/menu_item |
| Menu management (`MenuService`) | SELECT/INSERT/UPDATE/DELETE menu_item; read vendor and order_item |
| Place an order (`OrderService`) | Read accounts/menu; INSERT customer_order/order_item/queue_entry/notification; advisory transaction lock for queue numbering |
| Order lifecycle and notification reads | UPDATE customer_order, queue_entry, notification; SELECT related rows |
| Administrator stall management | SELECT/UPDATE vendor |
| Sales reports (`ReportService`) | Column-limited SELECT vendor/menu_item/customer_order/order_item |

The API protects student/vendor/admin routes with JWT and application ownership checks. All these workflows share `canteen_app`; separate end-user database logins or PostgreSQL row-level security are not implemented. See [Part B](part_b.md) for the access plan and [verification](part_d.md) for tested limits.
