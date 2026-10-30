# Local setup

Reviewed against `17dfae5`. Use a disposable local database for the supplied sample script.

## Requirements

- Git and access to the private repository.
- PHP with PDO PostgreSQL support. The existing README requests `pgsql` and `pdo_pgsql`; the integration clients also call PHP cURL functions.
- PostgreSQL server and a client such as psql or pgAdmin.
- Postman, Thunder Client, or another HTTP client for requests.

The previously verified local environment used PHP 8.5.10 and PostgreSQL 18.3. These are tested versions, not declared minimum versions.

## Clone and inspect configuration

```powershell
git clone https://github.com/grp05-dba/grp05_lostandfound.git
cd grp05_lostandfound
php -v
php --ini
php -m
```

The clone directory follows the repository name. The root README's example `lost-and-found-dba` directory is a placeholder and may not match your checkout.

Enable the required extensions in the PHP configuration used by the CLI:

```ini
extension=pdo_pgsql
extension=pgsql
extension=curl
```

If your PHP installation uses a separate configuration, supply its path using `php -c "C:\path\to\php.ini"`. Check the module list using the same configuration before starting the server.

## Initialize the database once

Create an empty database named `grp05_lostandfounddb` as the database administrator. Then run:

```powershell
psql -h localhost -p 5432 -U your_database_owner -d postgres -c "CREATE DATABASE grp05_lostandfounddb;"
psql -h localhost -p 5432 -U your_database_owner -d grp05_lostandfounddb -v ON_ERROR_STOP=1 -f sql/grp05_lostandfounddb_script.sql
psql -h localhost -p 5432 -U your_database_owner -d grp05_lostandfounddb -v ON_ERROR_STOP=1 -f sql/grp05_lostandfounddb_test_data_script.sql
```

Use your own host, port and owner name. Do not rerun CREATE DATABASE if it already exists. The schema script is not an idempotent migration: it uses plain CREATE TABLE statements.

The sample script contains `TRUNCATE TABLE claims RESTART IDENTITY CASCADE`. It also assumes referenced category/item IDs are 1 and inserts fixed unique report/claim codes. Run it only for a fresh disposable initialization; rerunning it can delete claims and fail on existing records. It is not a backup or maintenance script. See [database details](database.md).

## Create the ignored environment file

Create `.env` in the repository root. This is an INI-style file read by `parse_ini_file()`, not a shell script:

```ini
DB_HOST="localhost"
DB_PORT=5432
DB_NAME="grp05_lostandfounddb"
DB_USER="your_application_login"
DB_PASSWORD="your_local_password"
TEXTBEE_API_KEY=""
TEXTBEE_BASE_URL="https://api.textbee.dev"
```

Set DB_USER to a dedicated application login provisioned by your DBA. The schema script does not create this login or grant its permissions. It needs database CONNECT, schema USAGE and SELECT on the tables for the current retrieval routes. See [role mapping](user-roles.md) before granting access for future writes.

Database-backed routes do not require a working TextBee account. Constructing the TextBee client does not send a request; its configuration is read when a gateway method is called. Gateway requests require real service configuration. The client appends `/api/v1/gateway/...`, so do not include that path in the base URL.

The separate, currently unwired EmailJS client reads EMAILJS_BASE_URL, EMAILJS_SERVICE_ID, EMAILJS_TEMPLATE_ID and EMAILJS_PUBLIC_KEY when called. Obtain their actual values from the team's service configuration; no live email test is implied by local startup.

Never commit `.env`, passwords, real service keys or database dumps. The existing `.gitignore` already excludes `.env`.

## Start and check the API

```powershell
php -S 127.0.0.1:8000 -t public
```

Keep this terminal running. For a separate PHP configuration, put `-c "C:\path\to\php.ini"` before `-S`. Bind locally for development: both public and staff route namespaces share this server.

In another terminal:

```powershell
Invoke-RestMethod http://127.0.0.1:8000/api/admin/test
Invoke-RestMethod http://127.0.0.1:8000/api/public/categories
```

The first response is `{"message":"its working! :D"}`. The second should return a JSON array of database categories. This checks connectivity and retrieval, not the entire application or notification delivery.

Stop the development server with Ctrl+C. Keep database shutdown separate from the PHP process.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Missing PDO driver | CLI php.ini and pdo_pgsql module |
| Database connection failed | Host, port, database, login, password, and grants; inspect local PHP log |
| Table does not exist | Schema ran in the database named in .env |
| PHP cURL function missing | curl extension in the same CLI configuration |
| Duplicate key during sample load | Seed data already exists; do not repeatedly rerun the script |
| Route returns 404 | Exact method and path in [API reference](api.md); query strings affect matching |
| Browser shows JSON | Expected: this checkout currently serves an API, not a frontend |
