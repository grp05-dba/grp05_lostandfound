# Local setup

Follow the root [README](../README.md) for the installation walkthrough; this page adds implementation notes and troubleshooting.

## Requirements

- Git
- PHP 8.0 or later
- PostgreSQL
- PHP extensions: pdo_pgsql, pgsql and curl
- A PostgreSQL client such as pgAdmin or psql
- A browser; Postman or another HTTP client is useful for API checks

TextBee and EmailJS credentials are optional for local browsing and database-backed workflows. They are required for actual provider notifications.

Check the PHP CLI installation:

~~~powershell
php -v
php --ini
php -m
~~~

Make sure the required extensions are enabled in the active CLI php.ini.

## Clone and initialize

~~~powershell
git clone https://github.com/grp05-dba/grp05_lostandfound.git
cd grp05_lostandfound
~~~

Create the database grp05_lostandfounddb, then run the SQL files in the root README order. The schema script is a fresh database initializer, not a repeatable migration. The optional demo script is designed to replace its own demo records; still use a disposable database for demonstrations and testing.

## Configure .env

Copy .env.example to .env in the repository root. The application reads it using PHP parse_ini_file(), so use INI-style key/value lines.

~~~powershell
Copy-Item .env.example .env
~~~

Set the PostgreSQL host, port and database name, then configure the two application database roles:

| Variables | Sample role | Used by |
| --- | --- | --- |
| DB_PUBLIC_USER, DB_PUBLIC_PASSWORD | lostandfound_public | Public API |
| DB_USER, DB_PASSWORD | lostandfound_app | Admin API |

Use the same passwords entered in the role-creation SQL script. The public role has restricted privileges for student/guest workflows. The admin application role has broader privileges for administrative workflows. Do not use PostgreSQL's built-in postgres superuser for application connections.

TextBee and EmailJS settings are optional; leave provider credentials as placeholders if you are not testing notifications.

Never commit .env, provider keys, real passwords, uploaded personal data or database dumps. The repository's .gitignore excludes the local environment file.

## Start both interfaces locally

Open two terminals in the repository root. Both interfaces are part of the same project folder and repository, but run as separate local PHP server instances to simulate the intended public/admin server separation.

Terminal 1 — public interface and API:

~~~powershell
php -S 127.0.0.1:8000 -t public
~~~

Open http://127.0.0.1:8000/app.html.

Terminal 2 — admin interface and API:

~~~powershell
php -S 127.0.0.1:8001 -t admin
~~~

Open http://127.0.0.1:8001/app.html.

Keep both terminals running while testing. Stop each server with Ctrl+C. These commands bind to localhost and are suitable for local development. Two ports on one computer only simulate the two-server deployment model; they do not provide true network isolation.

## Intended deployment

In the intended deployment, the public API runs on Server A and uses the restricted public database role. The admin API runs on Server B, uses the admin application role, and is restricted to the campus private network or equivalent network controls.

There is no Admin login in the current design. Do not expose the admin server to the public internet. The network restriction is the intended access boundary, and anyone who can reach the admin server on the permitted network may potentially access its functions.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| php is not recognized | Install PHP or add its executable directory to PATH |
| could not find driver | Enable pdo_pgsql in the active PHP CLI configuration |
| PostgreSQL connection error | Confirm PostgreSQL is running and check DB host, port, name, username and password |
| Missing table/relation | Run the schema script in the database named in .env |
| Categories do not appear | Run the necessary-data SQL script after the schema |
| Images fail to upload | Check PHP upload limits, allowed image type/size and write permission on storage/ |
| Image URL returns 404 | Check both the image metadata row and the corresponding file under storage/ |
| Notifications fail | Verify TextBee/EmailJS credentials, provider configuration and server logs |
| Public/admin page cannot load API data | Confirm the matching PHP server is running on the expected port and inspect the browser network response |

A successful local page load or health response does not verify every workflow, notification delivery or production network restriction.
