
# Part B – Identify Users, Group Roles, and Privileges

## 1. Objective

This part identifies the different types of database access required by the Park It application.

Based on the application's existing functionality and database operations, appropriate PostgreSQL group roles and login accounts will be planned.

The access-control design follows the principle of least privilege. Each role should receive only the permissions required to perform its intended responsibilities.

## 2. Distinction Between Application Roles and PostgreSQL Roles

Park It has two application-level roles:

- Administrator
- Staff

These roles are stored in the `staff_user` table and are used by the PHP application for user authentication and session management.

However, both application users currently access PostgreSQL through the same database connection configured in `config/database.php`.

Therefore, PostgreSQL does not automatically distinguish an application administrator from an application staff member.

Separate PostgreSQL accounts are intended for database-level responsibilities, rather than automatically mirroring every application user.

## 3. Identified Database Access Requirements

The following database access categories are considered for Park It.

### 3.1 Database Administrator

**Purpose:** Provision, configure, and maintain the PostgreSQL database.

Responsibilities include:

- Creating and configuring the project database.
- Creating and managing PostgreSQL roles.
- Assigning and revoking privileges.
- Managing database objects when necessary.
- Performing database maintenance.

The administrative account should be separate from the account used by the application.

Elevated privileges should only be assigned when justified by the administrative task.

### 3.2 Application Runtime

**Purpose:** Allow the PHP application to perform its normal database operations.

The application runtime account is responsible for:

- Authenticating application users.
- Registering vehicles.
- Creating parking transactions.
- Updating parking occupancy.
- Processing payments.
- Recording vehicle exits.
- Retrieving dashboard and monitoring information.
- Retrieving payment and transaction history.

This account should have the required access to the operational tables without receiving PostgreSQL superuser privileges.

### 3.3 Read-Only User / Auditor

**Purpose:** Allow authorized users to inspect database records without modifying them.

Potential responsibilities include:

- Viewing registered vehicles.
- Inspecting parking transactions.
- Reviewing payment records.
- Checking parking-zone information.
- Performing database reporting and verification.

This account should receive SELECT privileges only on the approved tables.

A separate read-only application feature is not currently established in the reviewed project. This role is therefore intended for database inspection and testing, unless additional application requirements are identified.

## 4. Proposed PostgreSQL Group Roles

The following group roles are proposed:

| Group role | Intended responsibility |
|---|---|
| `park_it_runtime_grp` | Provides the privileges required by the PHP application's normal database operations. |
| `park_it_readonly_grp` | Provides read-only access to approved database tables. |
| `park_it_admin_grp` | Provides administrative privileges for authorized database management tasks. |

Group roles will be created with `NOLOGIN`. Individual login accounts will be assigned to the appropriate group roles.

## 5. Proposed Login Accounts

| Login role | Assigned group role | Purpose |
|---|---|---|
| `park_it_app` | `park_it_runtime_grp` | Database account used by the PHP application. |
| `park_it_auditor` | `park_it_readonly_grp` | Account used for read-only inspection and verification. |
| `park_it_dba` | `park_it_admin_grp` | Account used for authorized database administration. |

These are proposed database account names. Actual passwords will be configured locally and will not be included in the repository or documentation.

## 6. Proposed Table Privileges

The application runtime requires access to the following database objects:

| Table | SELECT | INSERT | UPDATE | DELETE |
|---|---|---|---|---|
| `parking_zone` | Yes | Setup only | Yes | No |
| `vehicle` | Yes | Yes | Yes | Yes |
| `staff_user` | Yes | Setup only | No | No |
| `transaction` | Yes | Yes | Yes | No |
| `payment` | Yes | Yes | Yes | No |

### Privilege considerations

- `parking_zone`: The application retrieves parking information and updates current occupancy. Initial zone creation is performed by the setup process.
- `vehicle`: The application registers, retrieves, updates, and deletes vehicle records when permitted by the application's business rules.
- `staff_user`: The application retrieves user records during authentication. Initial user creation is handled by the setup process.
- `transaction`: The application creates parking transactions and updates their status, exit time, and lost-ticket information.
- `payment`: The application records payments, retrieves payment history, and allows payment-method corrections.

The application does not provide normal deletion operations for completed transactions or payment records. These records should be preserved for audit purposes.

Column-level UPDATE privileges may be used where appropriate to further restrict changes to sensitive records.

## 7. Sequence Privileges

The application uses PostgreSQL sequences to generate primary-key values.

The runtime role must receive the necessary sequence privileges for the sequences used by its permitted INSERT operations.

The following sequences must be reviewed:

- `parking_zone_zone_id_seq`
- `vehicle_vehicle_id_seq`
- `staff_user_user_id_seq`
- `transaction_transaction_id_seq`
- `payment_payment_id_seq`

Sequences used only during initial database setup may be restricted to the account responsible for provisioning.

## 8. Database and Schema Privileges

The proposed role structure must also account for privileges beyond individual tables.

### Database-level access

- Grant CONNECT to the database only to accounts that require access.
- Avoid granting unnecessary access to unrelated databases.

### Schema-level access

- Grant USAGE on the `public` schema to roles that need to access its objects.
- Do not assume schema access automatically grants table or sequence access.

### Object-level access

- Grant table privileges according to each role's responsibilities.
- Grant sequence privileges where generated identifiers are required.
- Review default privileges for objects created in the future.

## 9. Access-Control Design Summary

| Account | Database access | Intended permissions |
|---|---|---|
| `park_it_app` | Application runtime | Required SELECT, INSERT, UPDATE, and DELETE operations |
| `park_it_auditor` | Read-only inspection | SELECT on approved tables |
| `park_it_dba` | Database administration | Administrative privileges appropriate to the task |

The administrative account will not be used by the application for ordinary operations.

The runtime account will be used by the PHP application's database connection after the access-control implementation is completed.