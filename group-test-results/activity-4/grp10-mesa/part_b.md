# Part B - Identify Users, Group Roles, and Privileges

## 1. Planned accounts and responsibilities

The plan was derived from Group 10's current code before creating users/grants. Implemented on 6 November 2026. Application identities are distinct from PostgreSQL accounts.

| Login account | NOLOGIN group | Application role served | Responsibility and privileges |
|---|---|---|---|
| `rors_app` | `rors_runtime_grp` | Public/customer/staff/administrator via PHP | CONNECT; schema USAGE; exact runtime matrix below; required sequence/function access |
| `rors_report` | `rors_readonly_grp` | Approved reporting/audit; not an end-user app login | CONNECT; schema USAGE; approved read objects only; no writes/sequences |
| `rors_dba` | `rors_owner_grp` | Database maintenance, not the application's administrator | Explicit SET ROLE owner for migrations/object administration; no cluster role/database creation |

The separate `lab_admin` provisioning superuser creates the fresh cluster's database and roles and assigns local passwords. It is not used for ordinary application traffic. All six project roles are NOSUPERUSER/NOCREATEDB/NOCREATEROLE/NOREPLICATION/NOBYPASSRLS. Runtime/reporting memberships inherit only their own group; owner membership requires explicit SET ROLE and has INHERIT FALSE. No membership has ADMIN OPTION.

## 2. Privilege matrix and rationale

| Object | Runtime group | Reporting group | Rationale |
|---|---|---|---|
| `customer` | SELECT, INSERT, UPDATE | None on base table; directory view allowed | Register/login/profile changes |
| `staff` | SELECT, INSERT, UPDATE, DELETE | None on base table; directory view allowed | Admin manages application staff; login reads hashes |
| `menu_item`, `restaurant_table`, `reservation` | SELECT, INSERT, UPDATE, DELETE | SELECT | Menu/table CRUD and reservation management |
| `orders`, `payment` | SELECT, INSERT, UPDATE | SELECT | Checkout/status/reconciliation; no history DELETE |
| `order_item` | SELECT, INSERT | SELECT | Capture line quantities/prices; no direct update/delete |
| `v_order_summary`, `v_reservation_schedule` | SELECT | SELECT | Operational reports |
| `v_customer_directory`, `v_staff_directory` | None | SELECT | Approved directories without hashes |

The four upstream views run with their owner rights. A report login can read their approved directory fields without base-table customer/staff SELECT. Directory views still contain approved names/email/phone; hash exclusion is not anonymization, and the reporting login is a trusted reporting account.

## 3. Sequences, functions and schemas

The runtime receives **USAGE only** on 7 required SERIAL sequences:

- `customer_customer_id_seq`
- `staff_staff_id_seq`
- `menu_item_menu_item_id_seq`
- `restaurant_table_table_id_seq`
- `orders_order_id_seq`
- `reservation_reservation_id_seq`
- `payment_payment_id_seq`

USAGE supports generated IDs and currval; raw sequence SELECT and setval are not required and are denied. All seven ID sequences correspond to runtime inserts. Reporting receives no sequence privileges.

PUBLIC execution is revoked for functions in the application schema; runtime is explicitly granted the three application trigger functions. Neither ordinary group receives schema CREATE, database CREATE/TEMPORARY, TRUNCATE, REFERENCES, TRIGGER, MAINTAIN or grant options. The owner group owns project objects; maintenance assumes it deliberately for DDL. New objects do not automatically receive runtime/reporting grants. Global creator-specific function defaults remove PUBLIC EXECUTE for owner and maintenance creators.

## 4. Differences from the upstream sketch and scope limits

The upstream project documents extra monitoring/maintenance/backup groups and predefined cluster-wide roles for later activities. This Activity 4 evaluation provisions only the runtime, reporting and object-maintenance accounts needed here. No pg_monitor, pg_maintain or pg_read_all_data membership is introduced. A real backup/maintenance rollout needs its own scope review. A separate owner group gives the DBA actual project DDL ownership without making the app or reporter an owner.

These are service-process privileges, not per-end-user database isolation. The shared runtime can directly change a staff row to admin; the rolled-back boundary probe confirms that its credential is trusted infrastructure. PHP authorization must protect that account-management operation. No owner-approved schema redesign or RLS implementation was made.
