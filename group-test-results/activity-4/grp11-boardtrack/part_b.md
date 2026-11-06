# Part B - Identify Users, Group Roles, and Privileges

## 1. Planned accounts and responsibilities

The plan was derived from Group 11's current code before creating users/grants. Implemented on 6 November 2026. Application identities are distinct from PostgreSQL accounts.

| Login account | NOLOGIN group | Application role served | Responsibility and privileges |
|---|---|---|---|
| `boardtrack_app` | `boardtrack_runtime_grp` | Landlord/staff/tenant via Express | CONNECT; schema USAGE; exact runtime matrix below; required sequence/function access |
| `boardtrack_report` | `boardtrack_readonly_grp` | Approved reporting/audit; not an end-user app login | CONNECT; schema USAGE; approved read objects only; no writes/sequences |
| `boardtrack_dba` | `boardtrack_owner_grp` | Database maintenance, not the application's administrator | Explicit SET ROLE owner for migrations/object administration; no cluster role/database creation |

The separate `lab_admin` provisioning superuser creates the fresh cluster's database and roles and assigns local passwords. It is not used for ordinary application traffic. All six project roles are NOSUPERUSER/NOCREATEDB/NOCREATEROLE/NOREPLICATION/NOBYPASSRLS. Runtime/reporting memberships inherit only their own group; owner membership requires explicit SET ROLE and has INHERIT FALSE. No membership has ADMIN OPTION.

## 2. Privilege matrix and rationale

| Object | Runtime group | Reporting group | Rationale |
|---|---|---|---|
| `property`, `room`, `tenant`, `lease`, `payment`, `utility_bill` | SELECT, INSERT, UPDATE, DELETE | None on base tables | Administrator features through the shared runtime |
| `app_user` | SELECT only | None | Login lookup and hash comparison; no account-management endpoint |
| `schema_migrations` | None | None | Provisioning only; AUTO_SETUP=false at runtime |
| `v_lease_summary` | SELECT | SELECT | Approved balance/report view, including tenant display name |

Reporting is deliberately limited to the existing summary view. It includes a tenant display name and tenant/lease identifiers approved for this report role, not contact numbers, valid-ID numbers or password hashes. It is not a tenant-specific database login and can inspect all rows in the approved view. Application tenants continue to be filtered separately by tenant_id.

## 3. Sequences, functions and schemas

The runtime receives **USAGE only** on 6 required SERIAL sequences:

- `property_property_id_seq`
- `room_room_id_seq`
- `tenant_tenant_id_seq`
- `lease_lease_id_seq`
- `payment_payment_id_seq`
- `utility_bill_utility_bill_id_seq`

USAGE supports generated IDs and currval; raw sequence SELECT and setval are not required and are denied. app_user_user_id_seq is reserved for provisioning and its runtime use is explicitly rejected. Reporting receives no sequence privileges.

PUBLIC execution is revoked for functions in the application schema; runtime is explicitly granted crypt(text,text) for login and the two application trigger functions. Neither ordinary group receives schema CREATE, database CREATE/TEMPORARY, TRUNCATE, REFERENCES, TRIGGER, MAINTAIN or grant options. The owner group owns project objects; maintenance assumes it deliberately for DDL. New objects do not automatically receive runtime/reporting grants. Global creator-specific function defaults remove PUBLIC EXECUTE for owner and maintenance creators.

## 4. Differences from the upstream sketch and scope limits

The upstream document is an Activity 4 plan, not a tested installed configuration. Its illustrative blanket ALL TABLES grants would include authentication/metadata tables. This implementation replaces those with a project-specific runtime matrix and report view only; no generic app_runtime_grp or app_readonly_grp collision is introduced. Automatic application setup is disabled so the runtime does not need DDL/CREATEDB.

These are service-process privileges, not per-end-user database isolation. The shared runtime can directly read all tenant rows; a probe returned all four. Tenant isolation is enforced in the app, not by PostgreSQL RLS. Database-level login/hash read permission is necessary for the current crypt-based authentication query. No owner-approved schema redesign or RLS implementation was made.
