# Database reference

Authoritative schema: [grp05_lostandfounddb_script.sql](../sql/grp05_lostandfounddb_script.sql), reviewed at `17dfae5`. Intended database name: `grp05_lostandfounddb`; tables use the public schema in the verified local setup.

## Tables and fields

| Table | Columns and constraints |
| --- | --- |
| categories | category_id SERIAL primary key; name VARCHAR(100) NOT NULL |
| items | item_id SERIAL primary key; category_id INT nullable FK; title VARCHAR(255) NOT NULL; description TEXT; location_found VARCHAR(255); date_found DATE; time_found TIME; status VARCHAR(50) |
| lost_reports | report_id SERIAL primary key; report_code VARCHAR(50) UNIQUE NOT NULL; category_id INT nullable FK; title VARCHAR(255) NOT NULL; description TEXT; location_lost VARCHAR(255); date_lost DATE; time_lost TIME; full_name VARCHAR(150) NOT NULL; student_number VARCHAR(50); email VARCHAR(150) NOT NULL; phone_number VARCHAR(50); status VARCHAR(50); created_at TIMESTAMP |
| claims | claim_id SERIAL primary key; claim_code VARCHAR(50) UNIQUE NOT NULL; item_id INT nullable FK; full_name VARCHAR(150) NOT NULL; student_number VARCHAR(50); email VARCHAR(150) NOT NULL; phone_number VARCHAR(50); status VARCHAR(50); created_at TIMESTAMP |
| potential_matches | match_id SERIAL primary key; report_id INT nullable FK; item_id INT nullable FK |

Fields not marked NOT NULL are nullable in this SQL, including status and created_at. The primary keys use PostgreSQL INTEGER sequences through SERIAL. Category names are not unique, and potential_matches has no unique constraint on the report/item pair.

| Table | Status default | CHECK allows |
| --- | --- | --- |
| items | unclaimed | unclaimed, claimed, archived |
| lost_reports | active | active, resolved, cancelled |
| claims | pending | pending, approved, rejected |

The status CHECK constraints do not prohibit NULL. Both created_at columns default to CURRENT_TIMESTAMP, but the columns remain nullable.

## Relationships and deletion

| Foreign key | Target | On target deletion |
| --- | --- | --- |
| items.category_id | categories.category_id | SET NULL |
| lost_reports.category_id | categories.category_id | SET NULL |
| claims.item_id | items.item_id | CASCADE |
| potential_matches.report_id | lost_reports.report_id | CASCADE |
| potential_matches.item_id | items.item_id | CASCADE |

A category can have many items and reports. An item can have many claims. Reports and items are linked through potential_matches, with duplicate pairs currently possible. Nullable foreign keys permit records without those links. These are descriptions of the SQL, not changes to the original proposal.

## Schema and sample initialization

The schema file creates five tables; it does not create the database, users, application privileges, triggers or matching functions. No incremental migration framework is configured.

The [sample script](../sql/grp05_lostandfounddb_test_data_script.sql) starts with SELECT statements, contains a destructive claims TRUNCATE, and then inserts one sample record into each table. It assumes fresh category/item/report IDs and uses fixed unique reference codes. It is not safe to treat it as an idempotent seed or run it against valued data. Generated dates/times depend on execution time.

See [setup](setup.md) for initialization order. Review [roles](user-roles.md) for permissions and sequence access.

## Design and implementation gaps to track

- Current entity constructors require several values represented as nullable in SQL; they are not wired into retrieval yet.
- Reference-code generation, ownership verification and cancellation are not implemented in the reviewed handlers.
- The SQL has no notification-delivery history or pair-uniqueness constraint, so storing a potential match alone does not prove notification deduplication.
- Photo fields mentioned by entity comments are absent from this schema.

Record proposed changes separately and obtain the lead's agreement before altering the schema or submitted proposal.
