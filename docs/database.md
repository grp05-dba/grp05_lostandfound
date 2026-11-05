# Database reference

Authoritative schema: [sql/grp05_lostandfounddb_script.sql](../sql/grp05_lostandfounddb_script.sql). The application database is grp05_lostandfounddb and uses PostgreSQL.

## Tables

| Table | Purpose and key fields |
| --- | --- |
| categories | category_id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL |
| items | item_id primary key; nullable category FK; title, description, found location/date/time and status |
| lost_reports | report_id primary key; unique required report_code; category FK; lost-item details; reporter/contact details; contact preference, status and creation timestamp |
| claims | claim_id primary key; unique required claim_code; item FK; claimant/contact details; contact preference, status and creation timestamp |
| potential_matches | match_id primary key; report and item FKs; required similarity score from 0 to 100; creation timestamp |
| item_images | item_image_id primary key; required item FK, storage key, MIME type and timestamp |
| lost_report_images | report_image_id primary key; required report FK, storage key, MIME type and timestamp |
| claim_images | claim_image_id primary key; required claim FK, storage key, MIME type and timestamp |

## Important columns and constraints

- Items default to unclaimed; allowed values are unclaimed, claimed and archived.
- Lost reports default to active; allowed values are active, resolved and cancelled.
- Claims default to pending; allowed values are pending, approved and rejected.
- Lost reports and claims have a contact_preference default of email, restricted to email or sms.
- Each report and claim must provide at least one contact channel: email or phone number. The schema does not require both.
- Potential-match similarity scores must be between 0 and 100 inclusive.
- Primary keys use PostgreSQL SERIAL sequences. The schema does not define a unique constraint for a report/item potential-match pair.
- Image metadata requires a storage key and MIME type. The database does not store image bytes.

## Relationships and deletion

| Foreign key | Target | On target deletion |
| --- | --- | --- |
| items.category_id | categories.category_id | SET NULL |
| lost_reports.category_id | categories.category_id | SET NULL |
| claims.item_id | items.item_id | CASCADE |
| potential_matches.report_id | lost_reports.report_id | CASCADE |
| potential_matches.item_id | items.item_id | CASCADE |
| item_images.item_id | items.item_id | CASCADE |
| lost_report_images.report_id | lost_reports.report_id | CASCADE |
| claim_images.claim_id | claims.claim_id | CASCADE |

A category can be associated with multiple items and reports. An item can have multiple claims and images. A report can have multiple potential matches and images. Deleting a parent item/report/claim cascades to related rows listed above; category deletion sets the item/report category reference to NULL.

## Database roles and application connections

PUP-SPOT uses separate PostgreSQL application roles for the two interfaces:

| Application interface | Environment variables | Sample role | Access level |
| --- | --- | --- | --- |
| Public API | DB_PUBLIC_USER, DB_PUBLIC_PASSWORD | lostandfound_public | Restricted to database operations needed by public workflows |
| Admin API | DB_USER, DB_PASSWORD | lostandfound_app | Broader privileges for administrative workflows |

The public connection is used by the public API, while the admin connection is used by the admin API. The application should use these dedicated roles rather than the PostgreSQL postgres superuser. The SQL role-creation sample defines the roles and grants; replace its placeholder passwords before running it as a PostgreSQL administrator. Keep the tested grants unchanged unless application requirements change.

Database roles separate database privileges, but they do not identify individual students or staff members. PUP-SPOT does not implement an Admin login. Administrative access is intended to be restricted at the network/deployment level; see [user roles](user-roles.md).

## Initialization scripts

Run scripts in the order described in the [root README](../README.md):

1. grp05_lostandfounddb_script.sql creates the eight tables.
2. grp05_lostandfounddb_necessary_data_script.sql inserts required categories.
3. grp05_lostandfounddb_role_creation_sample_script.sql creates/grants the application roles; replace placeholder passwords before running as a PostgreSQL administrator.
4. grp05_lostandfounddb_demo_data_script.sql optionally loads demonstration records.

The demo script uses a transaction and removes only its own demo-coded records before recreating them. It also inserts example potential matches with illustrative scores. These are demonstration rows, not generated matching results. It does not insert image rows.

The schema script creates tables only. It does not create the database itself. There is no migration framework documented in the repository; changes to this schema should be coordinated and reflected in the SQL and application together.

## Image storage relationship

Image metadata is stored in the three image tables. The associated file is stored under the matching folder in storage/; storage_key identifies the relative file and mime_type determines the response content type. A database image row without its corresponding file cannot be served. Keep uploaded files and database records consistent when backing up or restoring the application.

## Implementation considerations

- Database permissions are assigned by the role-creation SQL script and enforced when the application connects with the corresponding role.
- Potential matches do not have a schema-level unique pair constraint. Do not assume duplicate prevention is guaranteed by the database.
- Image rows use cascading foreign keys, but filesystem cleanup is handled by application code rather than database constraints.
- Do not use demonstration SQL as a production backup or as a substitute for a migration/restore procedure.
