# Part C – Database Roles and Privileges

## 1. Overview

This part implements role-based access control (RBAC) in the Park-It PostgreSQL database. It establishes separate database roles for application operations, read-only access, and database administration.

## 2. SQL Implementation

The following SQL script creates the group roles and login roles, assigns role memberships, and grants the required database, schema, table, and sequence privileges.

```sql
-- =========================================
-- GROUP ROLES
-- =========================================

CREATE ROLE park_it_runtime_grp NOLOGIN;
CREATE ROLE park_it_readonly_grp NOLOGIN;
CREATE ROLE park_it_admin_grp NOLOGIN;


-- =========================================
-- LOGIN ROLES
-- =========================================

CREATE ROLE park_it_app
    LOGIN
    PASSWORD 'CHANGE_THIS_APP_PASSWORD';

CREATE ROLE park_it_auditor
    LOGIN
    PASSWORD 'CHANGE_THIS_AUDITOR_PASSWORD';

CREATE ROLE park_it_dba
    LOGIN
    PASSWORD 'CHANGE_THIS_DBA_PASSWORD';


-- =========================================
-- ROLE MEMBERSHIPS
-- =========================================

GRANT park_it_runtime_grp TO park_it_app;
GRANT park_it_readonly_grp TO park_it_auditor;
GRANT park_it_admin_grp TO park_it_dba;


-- =========================================
-- DATABASE AND SCHEMA ACCESS
-- =========================================

GRANT CONNECT ON DATABASE grp_parkitdb
TO park_it_runtime_grp,
   park_it_readonly_grp,
   park_it_admin_grp;

GRANT USAGE ON SCHEMA public
TO park_it_runtime_grp,
   park_it_readonly_grp;

GRANT USAGE, CREATE ON SCHEMA public
TO park_it_admin_grp;


-- =========================================
-- 5. RUNTIME ROLE PRIVILEGES
-- =========================================

-- Read access to all tables, including staff_user
-- for application authentication.

GRANT SELECT ON ALL TABLES IN SCHEMA public
TO park_it_runtime_grp;

-- Insert records into operational tables.

GRANT INSERT ON
    public.vehicle,
    public."transaction",
    public.payment
TO park_it_runtime_grp;

-- Update operational records.

GRANT UPDATE ON
    public.vehicle,
    public.parking_zone,
    public."transaction",
    public.payment
TO park_it_runtime_grp;

-- Delete vehicles when permitted by application logic.

GRANT DELETE ON public.vehicle
TO park_it_runtime_grp;

-- Allow generated IDs for inserted records.

GRANT USAGE, SELECT ON SEQUENCE
    public.vehicle_vehicle_id_seq,
    public.transaction_transaction_id_seq,
    public.payment_payment_id_seq
TO park_it_runtime_grp;


-- =========================================
-- 6. READ-ONLY ROLE PRIVILEGES
-- =========================================

GRANT SELECT ON
    public.parking_zone,
    public.vehicle,
    public."transaction",
    public.payment
TO park_it_readonly_grp;

-- Allow viewing staff information without
-- exposing password hashes.

GRANT SELECT (user_id, username, role)
ON public.staff_user
TO park_it_readonly_grp;


-- =========================================
-- 7. ADMIN ROLE PRIVILEGES
-- =========================================

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public
TO park_it_admin_grp;

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public
TO park_it_admin_grp;

GRANT ALL PRIVILEGES ON DATABASE grp_parkitdb
TO park_it_admin_grp;
```

## 3. Role Summary

| Login Role | Group Role | Access Level |
|---|---|---|
| `park_it_app` | `park_it_runtime_grp` | Application read/write operations |
| `park_it_auditor` | `park_it_readonly_grp` | Restricted read-only access |
| `park_it_dba` | `park_it_admin_grp` | Administrative privileges |

## 4. Implementation Notes

- Group roles centralize privilege assignments.
- Login roles inherit privileges through group membership.
- The runtime role receives permissions required for normal application operations.
- The auditor role is restricted to reading permitted records and cannot access staff password hashes.
- The administrative role receives broader privileges over the database's existing objects.
- The PHP application's database connection must use the `park_it_app` credentials for the runtime privileges to take effect.

## 5. Least Privilege Review (Part D)

The assigned privileges were reviewed to ensure that each database account only has the permissions necessary for its intended responsibilities.

- The application uses a dedicated runtime account instead of a PostgreSQL superuser.
- The runtime and auditor accounts are not granted unnecessary database creation or role-management privileges.
- The auditor account is restricted to read-only access.
- Database access, inherited role memberships, and publicly available privileges are reviewed to prevent unintended access.

These restrictions follow the principle of least privilege and help protect the database from unauthorized operations.