# PUP-SPOT — Campus Lost and Found

PUP-SPOT is a campus Lost and Found system for browsing found items, submitting lost-item reports, requesting claims, and tracking submissions using reference codes.

This guide covers setting up a local copy of the project.

## Requirements

Install the following:

- **Git**
- **PHP 8.0 or later**
- **PostgreSQL**
- **PHP PostgreSQL extensions:** `pdo_pgsql` and `pgsql`
- A PostgreSQL client such as **pgAdmin** or **psql**

TextBee and EmailJS are optional. They are only needed if you want the application to send SMS and email notifications.

## 1. Clone the repository

Open a terminal and run:

```bash
git clone https://github.com/grp05-dba/grp05_lostandfound.git
cd grp05_lostandfound
```

## 2. Create and initialize the database

Start PostgreSQL, then create the project database:

```sql
CREATE DATABASE grp05_lostandfounddb;
```

Connect to `grp05_lostandfounddb` and run the SQL scripts in this order:

1. **`sql/grp05_lostandfounddb_script.sql`** — creates the database tables.
2. **`sql/grp05_lostandfounddb_necessary_data_script.sql`** — inserts the categories required by the application.
3. **`sql/grp05_lostandfounddb_role_creation_sample_script.sql`** — creates the database roles and grants their permissions.

The role-creation script must be run by a PostgreSQL administrator. Before running it, replace both occurrences of `enter_your_password_here` with passwords you choose. Keep these passwords private.

To load optional demonstration records, run **`sql/grp05_lostandfounddb_demo_data_script.sql`** after the schema and necessary data scripts. This script is intended for a clean demo database; do not run it repeatedly on a database that already contains its sample records.

You can run the scripts through pgAdmin's Query Tool or with `psql`. For example, from the repository root:

```bash
psql -U postgres -d grp05_lostandfounddb -f sql/grp05_lostandfounddb_script.sql
psql -U postgres -d grp05_lostandfounddb -f sql/grp05_lostandfounddb_necessary_data_script.sql
psql -U postgres -d grp05_lostandfounddb -f sql/grp05_lostandfounddb_role_creation_sample_script.sql
```

Run the optional demo-data script separately only if you want sample records:

```bash
psql -U postgres -d grp05_lostandfounddb -f sql/grp05_lostandfounddb_demo_data_script.sql
```

## 3. Configure PHP

Check that PHP is installed:

```bash
php -v
```

Check that the required PostgreSQL extensions are enabled:

```bash
php -m
```

The output must include:

```text
pdo_pgsql
pgsql
```

If either extension is missing, enable it in the `php.ini` used by your PHP installation, then run `php -m` again. To locate the active configuration file, run:

```bash
php --ini
```

## 4. Configure environment variables

Create your local `.env` file from the provided example.

**Linux/macOS:**

```bash
cp .env.example .env
```

**Windows PowerShell:**

```powershell
Copy-Item .env.example .env
```

Open `.env` and enter the database credentials you configured in the previous step:

```ini
DB_HOST=localhost
DB_PORT=5432
DB_NAME=grp05_lostandfounddb

DB_USER=lostandfound_app
DB_PASSWORD=your_app_role_password

DB_PUBLIC_USER=lostandfound_public
DB_PUBLIC_PASSWORD=your_public_role_password
```

Use the same passwords you entered in the role-creation SQL script. The database host and port may differ depending on your PostgreSQL installation.

### Optional: Enable notifications

SMS and email notifications require provider credentials. If you do not configure these integrations, the core application can still be used, but notifications will not be delivered.

To enable them, add your TextBee and EmailJS credentials to `.env`:

```ini
TEXTBEE_API_KEY=your_textbee_api_key
TEXTBEE_BASE_URL=https://api.textbee.dev

EMAILJS_BASE_URL=https://api.emailjs.com
EMAILJS_SERVICE_ID=your_emailjs_service_id
EMAILJS_TEMPLATE_ID=your_emailjs_template_id
EMAILJS_PUBLIC_KEY=your_emailjs_public_key
```

See [TextBee](https://textbee.dev/) and [EmailJS](https://www.emailjs.com/) for provider account setup and credentials.

**Never commit your `.env` file or share real credentials publicly.** The repository's `.gitignore` excludes `.env`.

## 5. Run the application locally

The project has separate public and admin interfaces. They use ports **8000** and **8001**, respectively.

The PHP built-in server needs a router script so it can serve the interface's static files and forward API requests to the correct PHP entry point. Create a file named `dev-router.php` in the repository root with the following contents:

```php
<?php

$port = (int) $_SERVER['SERVER_PORT'];
$documentRoot = $port === 8000
    ? __DIR__ . '/public'
    : __DIR__ . '/admin';

$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?? '/';
$file = $documentRoot . $path;

// Let PHP's built-in server serve existing frontend files (HTML, CSS, JS, images).
if ($path !== '/' && is_file($file)) {
    return false;
}

// Forward API requests to the matching entry point.
require $documentRoot . '/index.php';
```

Open two terminals from the repository root.

**Terminal 1 — Public interface and API:**

```bash
php -S 127.0.0.1:8000 -t public dev-router.php
```

Open the public interface at:

- http://127.0.0.1:8000/app.html

**Terminal 2 — Admin interface and API:**

```bash
php -S 127.0.0.1:8001 -t admin dev-router.php
```

Open the admin interface at:

- http://127.0.0.1:8001/app.html

Keep both server terminals running while using the application.

## Troubleshooting

| Issue | What to check |
|---|---|
| `php` command not found | Install PHP or add its executable directory to your system's `PATH`. |
| `could not find driver` | Enable the `pdo_pgsql` extension in the active PHP configuration. |
| PostgreSQL connection failed | Confirm PostgreSQL is running and verify the database credentials in `.env`. |
| Database does not exist | Create `grp05_lostandfounddb` before running the SQL scripts. |
| Relation/table does not exist | Run the schema script against the correct database. |
| Categories are missing | Run the necessary-data script after the schema script. |
| API returns `404` | Confirm both PHP servers are running and that you are using the correct interface URL and API port. |
| Notifications are not sent | Check the TextBee or EmailJS credentials in `.env`. |
