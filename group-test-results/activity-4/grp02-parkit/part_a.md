
# Part A – Database Setup and Assessment

## 1. Objective

This part covers the setup and assessment of the Park It application from the Activity 3 repository.

The purpose is to understand the existing database structure, identify the application's database operations, determine which users and system components require database access, and prepare an access-control plan before implementing PostgreSQL roles and privileges.

The assessment follows the principle of least privilege. Each database account should receive only the permissions necessary for its intended responsibilities.

## 2. Project Information

| Item | Details |
|---|---|
| Project | Park It – Database Management System |
| Repository | https://github.com/millerdevera6-glitch/park-it-database |
| Branch reviewed | `final` |
| Application language | PHP |
| Database platform | PostgreSQL 18.6 |
| Database administration tool | pgAdmin 4 |
| Local web server | Apache (XAMPP) |
| Database name | `grp_parkitdb` |
| Database schema | `public` |

## 3. Application Setup

The project documentation specifies the following setup requirements:

- PostgreSQL 18.6
- pgAdmin 4
- XAMPP with Apache and PHP
- Enabled PHP PostgreSQL extensions (`pdo_pgsql` and `pgsql`)
- A web browser

### Database initialization

1. Create a PostgreSQL database named `grp_parkitdb`.
2. Use the provided `schema.sql` file to create the database objects.
3. Verify that the database tables were created successfully.
4. Configure the connection details in `config/database.php`.
5. Place the project folder inside the XAMPP `htdocs` directory.
6. Start Apache and run the application's initial setup script when required.

The repository's setup instructions specify `postgres` as the database connection account. This will be reviewed as part of the access-control assessment because ordinary application operations should not use an unrestricted PostgreSQL superuser account.

**Setup status:** Pending local verification.

## 4. Database Structure Assessment

The database uses the `public` schema and contains five tables and five associated sequences.

### 4.1 Tables

| Table | Purpose |
|---|---|
| `parking_zone` | Stores parking zone names, maximum capacity, and current occupancy. |
| `vehicle` | Stores vehicle license plates and vehicle types. |
| `staff_user` | Stores staff and administrator login information, password hashes, and application roles. |
| `transaction` | Stores vehicle entry and exit records, parking zones, timestamps, and transaction status. |
| `payment` | Stores payment amounts, payment methods, and payment timestamps. |

### 4.2 Sequences

| Sequence | Associated table |
|---|---|
| `parking_zone_zone_id_seq` | `parking_zone` |
| `vehicle_vehicle_id_seq` | `vehicle` |
| `staff_user_user_id_seq` | `staff_user` |
| `transaction_transaction_id_seq` | `transaction` |
| `payment_payment_id_seq` | `payment` |

These sequences generate identifiers for newly inserted records.

### 4.3 Relationships

The database contains the following foreign-key relationships:

- `transaction.vehicle_id` references `vehicle.vehicle_id`.
- `transaction.zone_id` references `parking_zone.zone_id`.
- `payment.transaction_id` references `transaction.transaction_id`.

### 4.4 Constraints and restrictions

The schema includes:

- Primary keys for all five tables.
- Unique license plates in `vehicle`.
- Unique usernames in `staff_user`.
- Unique parking zone names in `parking_zone`.
- A unique transaction reference in `payment`.
- A non-negative payment amount constraint.
- A parking capacity check that prevents the current occupancy from exceeding the maximum capacity.

## 5. Application Database Operations

The application's PHP modules were reviewed to identify the database operations required by its features.

| Application feature | Database operations | Tables involved |
|---|---|---|
| User authentication | SELECT | `staff_user` |
| Vehicle registration | SELECT, INSERT | `vehicle`, `transaction`, `parking_zone` |
| Active parking monitoring | SELECT, UPDATE | `transaction`, `vehicle`, `parking_zone` |
| Vehicle directory | SELECT, UPDATE, DELETE | `vehicle` |
| Parking payment and exit | SELECT, INSERT, UPDATE | `payment`, `transaction`, `parking_zone`, `vehicle` |
| Payment history | SELECT, UPDATE | `payment`, `transaction`, `vehicle`, `parking_zone` |
| Dashboard | SELECT | All operational tables |

The application uses database transactions when registering vehicles and processing payments to keep related changes consistent.

## 6. Application User Roles

The project identifies two application-level user roles:

| Application role | Responsibility |
|---|---|
| Administrator | Uses the administrative account to access the system's available management functions. |
| Staff | Uses the staff account to perform ordinary parking operations. |

These are application roles stored in `staff_user.role`. They are distinct from PostgreSQL login roles and group roles.

The application's PHP code establishes a database connection through `config/database.php`. Consequently, the application users do not automatically connect to PostgreSQL using separate database accounts.

## 7. Initial Access-Control Findings

The following findings will be considered when preparing the access-control plan:

1. The application currently connects to PostgreSQL using the `postgres` account.
2. The application requires access to all five database tables for its existing features.
3. The application uses generated identifiers, so the required sequence privileges must also be considered.
4. Staff and administrator accounts are authenticated by the application through `staff_user`.
5. Application-level roles do not automatically restrict PostgreSQL privileges.
6. The initial database setup script inserts records into `parking_zone` and `staff_user`.

The use of the PostgreSQL superuser account for normal application access is a security concern that must be addressed.