# Part B - Identify Users, Group Roles, and Privileges

## 1. Objective

Assign PostgreSQL responsibilities according to actual BrewPOS features, separately from the demo application's CASHIER/MANAGER labels. The plan below was selected before provisioning the test roles and is implemented in [Part C and D](part_cd.md).

## 2. Accounts, groups and responsibilities

| Login / account | NOLOGIN group | Application role served | Responsibility and required privileges |
|---|---|---|---|
| `brewpos_app` | `brewpos_runtime_grp` | Shared Spring Boot service for register and manager-menu features | CONNECT, schema USAGE, the exact table privileges below, and USAGE on three insert sequences |
| `brewpos_auditor` | `brewpos_readonly_grp` | External inspection/reporting; not an implemented web login | CONNECT, schema USAGE, SELECT on the five approved tables; no writes or sequence access |
| `brewpos_dba` | `brewpos_owner_grp` | Database administration, not the store-manager dropdown | Project database/schema/object ownership through the owner group; maintenance, DDL and approved data repair |
| Local `postgres` provisioning account | None required | No ordinary application role | Initialize the isolated cluster, databases, passwords and cluster-wide roles; not used by Spring Boot |

Each project login has only its designated group membership, no ADMIN OPTION, and no SUPERUSER, CREATEDB, CREATEROLE, REPLICATION or BYPASSRLS attributes. The group roles also have none of those elevated attributes. `INHERIT` makes group object privileges available to logins; `SET ROLE brewpos_owner_grp` is reserved to the DBA for owner-scoped migrations.

The DBA is deliberately a trusted **project owner**, with authority to alter/drop project objects and override ordinary data restrictions. It is not a PostgreSQL cluster administrator and cannot create databases or roles. A store manager is not given this account. Provisioning remains a separate responsibility.

## 3. Runtime and auditor table matrix

| Table | Runtime SELECT | INSERT | UPDATE | DELETE | Auditor |
|---|---|---|---|---|---|
| `staff` | Yes | No | No | No | SELECT only |
| `menu_category` | Yes | Yes | Yes | Yes | SELECT only |
| `menu_item` | Yes | Yes | Yes | No | SELECT only |
| `order_ticket` | Yes | Yes | No | No | SELECT only |
| `order_line_item` | Yes | Yes | No | No | SELECT only |

TRUNCATE, REFERENCES, TRIGGER, MAINTAIN, ownership and grant authority are not assigned to the runtime or auditor. Staff names and roles are approved auditor data in this demo; `staff` contains no password column. If future staff records add private fields, SELECT permissions must be reviewed rather than automatically extended to new tables.

No separate cashier PostgreSQL login is configured because the current application has one connection pool and needs the combined register/menu capabilities. Adding a cashier login without changing how connections or authorized operations are selected would not enforce per-user separation. Production separation requires server-side authorization and, if desired, separate service roles or carefully scoped database routines.

## 4. Sequence matrix

| Sequence | Runtime | Auditor | Reason |
|---|---|---|---|
| `menu_category_category_id_seq` | USAGE | None | New categories |
| `menu_item_item_id_seq` | USAGE | None | New menu items |
| `order_ticket_order_id_seq` | USAGE | None | New orders |
| `staff_staff_id_seq` | None | None | Staff provisioning belongs to the DBA |

USAGE supplies generated IDs through `nextval` and permits `currval`; runtime `setval` is not granted. SELECT on sequences is not needed for the application operations. The owner group controls all four sequences.

## 5. Database, schema and future objects

- Only the two service/inspection groups receive explicit CONNECT on `grp_brewposdb`; the DBA inherits owner access. Runtime and auditor receive schema USAGE, with no database/schema CREATE or database TEMPORARY privilege.
- PUBLIC project database, schema, table and sequence access is revoked. Existing membership and object ownership are inspected alongside explicit grants.
- The unrelated test database, `postgres` and `template1` are closed to project logins in this isolated lab. These defaults must be assessed independently on any shared server; project-database grants alone do not restrict other databases.
- Future objects receive no automatic runtime/auditor table or sequence grants. Migrations run with `SET ROLE brewpos_owner_grp`; new objects require reviewed explicit grants.
- PUBLIC execution of future owner-created functions is revoked with global owner default privileges. These defaults apply to that creator, not every possible role. A DBA creating objects as itself must also review its defaults.

## 6. Security rationale and scope

The plan allows the current application to create orders, manage categories, edit prices and deactivate products without a superuser connection. It excludes staff writes, historical UPDATE/DELETE, unnecessary sequence control, object creation and cluster administration from the runtime.

This is a privilege boundary, not a complete business-integrity system. Direct INSERT can attach line items to existing orders and can supply sold prices independently of the Java service's price checks. The application also relies on an unauthenticated demo selector. These limitations are documented, not represented as solved by GRANT/REVOKE.
