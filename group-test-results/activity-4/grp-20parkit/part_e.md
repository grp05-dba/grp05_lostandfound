# Part E – Role and Privilege Testing

## 1. Testing Overview

The following is an **illustrative psql session** prepared from the role definitions and GRANT statements in [Part C and Part D](part_cd.md). It shows expected PostgreSQL responses; it is not a record of commands executed against the project database.

The tests use the following login accounts:

- `park_it_app` – application runtime account
- `park_it_auditor` – read-only account
- `park_it_dba` – administrative account

## 2. Test Results

| # | Account used | SQL statement or operation | Expected result | Result |
|---|---|---|---|---|
| 1 | `park_it_app` | `SELECT * FROM public.vehicle LIMIT 5;` | Allowed | PASS – SELECT privilege is granted to the runtime group. |
| 2 | `park_it_app` | Check INSERT permission on `public.vehicle` | Allowed | PASS – INSERT privilege is granted to the runtime group. |
| 3 | `park_it_auditor` | `SELECT vehicle_id, license_plate, vehicle_type FROM public.vehicle;` | Allowed | PASS – SELECT is granted on the vehicle table. |
| 4 | `park_it_auditor` | Attempt to update a vehicle record | Denied | PASS – the read-only group has no UPDATE privilege. |
| 5 | `park_it_app` | `CREATE DATABASE park_it_test;` | Denied | PASS – the runtime role is not granted CREATEDB. |
| 6 | `park_it_app` | Connect to the unrelated `postgres` database | Denied after access is restricted | **NOT GUARANTEED** – PostgreSQL commonly grants CONNECT on databases to PUBLIC by default. The current script does not revoke that access. |
| 7 | `park_it_app` | Attempt to delete a payment record | Denied | PASS – the runtime group has no DELETE privilege on `public.payment`. |

## 3. psql Test Session

### Test 1 – Runtime SELECT access

```sql
-- Connected as park_it_app
SELECT * FROM public.vehicle LIMIT 5;

-- Expected: SELECT succeeds.
```

The SELECT operation is permitted because `park_it_runtime_grp` has SELECT access to all tables in the `public` schema.

### Test 2 – Runtime INSERT permission

```sql
-- Connected as park_it_app
SELECT has_table_privilege(
    current_user,
    'public.vehicle',
    'INSERT'
);

-- Expected: t
```

Expected psql response:
```text
 has_table_privilege
---------------------
 t
(1 row)
```

This checks the assigned INSERT privilege without inserting test data. A real INSERT test should use the required columns and valid values from the actual `vehicle` table schema.

### Test 3 – Auditor SELECT access

```sql
-- Connected as park_it_auditor
SELECT * FROM public.vehicle LIMIT 5;

-- Expected: SELECT succeeds.
```

The SELECT operation is permitted because `park_it_readonly_grp` has SELECT access to `public.vehicle`.

### Test 4 – Auditor UPDATE restriction

```sql
-- Connected as park_it_auditor
UPDATE public.vehicle
SET vehicle_id = vehicle_id
WHERE false;
```

Expected psql response:
```text
ERROR:  permission denied for table vehicle
```

Expected: UPDATE is denied. The WHERE condition matches no rows, but PostgreSQL still checks the required UPDATE privilege.

### Test 5 – Runtime cannot create databases

```sql
-- Connected as park_it_app
CREATE DATABASE park_it_test;
```

Expected psql response:
```text
ERROR:  permission denied to create database
```

Expected: The operation is denied because `park_it_app` is not assigned the CREATEDB attribute.

### Test 6 – Access to an unrelated database

The current role script grants CONNECT on `grp_parkitdb`, but does not revoke the default PUBLIC CONNECT privilege from other databases.

```sql
-- Attempt a separate connection as park_it_app:
-- psql -U park_it_app -d postgres
```

**Result:** Connection may succeed if the `postgres` database still grants CONNECT to PUBLIC. Therefore, the expected denial is **not established by the current Part C script**. The database's existing ACL must be inspected and restricted if the assignment requires this access to be denied.

### Test 7 – Runtime cannot delete payment records

```sql
-- Connected as park_it_app
DELETE FROM public.payment
WHERE false;
```

Expected psql response:
```text
ERROR:  permission denied for table payment
```

Expected: DELETE is denied because the runtime group was not granted DELETE on the payment table.

## 4. Additional Column-Level Access Check

The auditor role receives SELECT permission only for `user_id`, `username`, and `role` on `staff_user`.

```sql
-- Connected as park_it_auditor
SELECT user_id, username, role
FROM public.staff_user;

-- Expected: succeeds.

SELECT password_hash
FROM public.staff_user;

-- Expected: permission denied.
```

This verifies that the auditor can view permitted staff information without being granted access to stored password hashes.

## 5. Conclusion

The role definitions and GRANT statements provide the intended table-level restrictions: the runtime account can perform its assigned operations, while the auditor account is limited to read-only access. The runtime account is not granted database-creation privileges or permission to delete payment records.

The unrelated-database test requires additional ACL verification because PostgreSQL may allow database connections through the PUBLIC role. These results are illustrative and should be verified against the configured PostgreSQL database before being reported as executed test results.
