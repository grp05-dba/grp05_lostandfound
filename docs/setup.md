# Local setup

Reviewed against `main` revision `9a803d2` (November 5, 2026). Follow the root [README](../README.md) for the short installation guide; this page adds implementation notes and troubleshooting.

## Requirements

- Git
- PHP 8.0 or later
- PostgreSQL
- PHP extensions: `pdo_pgsql`, `pgsql` and `curl`
- A PostgreSQL client such as pgAdmin or `psql`
- A browser; Postman or another HTTP client is useful for API checks

TextBee and EmailJS credentials are optional for local browsing and database-backed workflows. They are required for actual provider notifications.

Check the PHP CLI installation:

```powershell
php -v
php --ini
php -m
```

Make sure the required extensions are enabled in the active CLI `php.ini`.

## Clone and initialize

```powershell
git clone https://github.com/grp05-dba/grp05_lostandfound.git
cd grp05_lostandfound
```

Create the database `grp05_lostandfounddb`, then run the SQL files in the root README order. The schema script is a fresh database initializer, not a repeatable migration. The optional demo script is designed to replace its own demo records; still use a disposable database for demonstrations and testing.

## Configure `.env`

Copy `.env.example` to `.env` in the repository root. The application reads it using PHP `parse_ini_file()`, so use INI-style key/value lines.

```powershell
Copy-Item .env.example .env
```

Set the PostgreSQL host, port, database name, and database credentials to match the roles configured in your local database. The template also includes TextBee and EmailJS settings; leave provider credentials as placeholders if you are not testing notifications.

Never commit `.env`, provider keys, real passwords, uploaded personal data or database dumps. The repository's `.gitignore` excludes the local environment file.

**Connection detail to be aware of:** `src/db/db.php` defines both `getAdminConnection()` and `getPublicConnection()`, but both current entry points call `getAdminConnection()`. The `DB_PUBLIC_USER` and `DB_PUBLIC_PASSWORD` values in the template are not currently used by the public entry point. Do not treat the sample public credentials as an active security boundary.

## Start both interfaces

Open two terminals in the repository root.

Terminal 1 — public interface and API:

```powershell
php -S 127.0.0.1:8000 -t public
```

Open `http://127.0.0.1:8000/app.html`.

Terminal 2 — admin interface and API:

```powershell
php -S 127.0.0.1:8001 -t admin
```

Open `http://127.0.0.1:8001/app.html`.

Keep both terminals running while testing. Stop each server with Ctrl+C. These commands bind to localhost, which is suitable for local development; do not expose the admin interface to an untrusted network.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| `php` is not recognized | Install PHP or add its executable directory to PATH |
| `could not find driver` | Enable `pdo_pgsql` in the active PHP CLI configuration |
| PostgreSQL connection error | Confirm PostgreSQL is running and check DB host, port, name, username and password |
| Missing table/relation | Run the schema script in the database named in `.env` |
| Categories do not appear | Run the necessary-data SQL script after the schema |
| Images fail to upload | Check PHP upload limits, allowed image type/size and write permission on `storage/` |
| Image URL returns 404 | Check both the image metadata row and the corresponding file under `storage/` |
| Notifications fail | Verify TextBee/EmailJS credentials, provider configuration and server logs |
| Public/admin page cannot load API data | Confirm the matching PHP server is running on the expected port and inspect the browser network response |

A successful local page load or health response does not verify every workflow, notification delivery or production access control.
