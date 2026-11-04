# PUP-SPOT - Lost and Found System — Setup Guide

## 1. Prerequisites

Install the following before running the project:

- **PHP** — with the `pgsql` and `pdo_pgsql` extensions enabled.
- **PostgreSQL** — database server.
- **Git** — for version control and working with branches.
- **API testing tool** — Postman or Thunder Client.
- **Code editor** — such as VS Code.
- **TextBee account (optional)** — required to configure and test SMS notifications.
- **EmailJS account (optional)** — required to configure and test email notifications.

You may use a Windows PHP installation or a development environment such as XAMPP, provided the PHP version being used by the project has PostgreSQL support enabled.

## 2. Clone the Repository

Open a terminal or PowerShell and run:

```powershell
git clone <repository-url>
cd lost-and-found-dba
```

Replace `<repository-url>` with the URL of the project repository.

## 3. Set Up PostgreSQL

### Step 1: Install PostgreSQL

Install PostgreSQL for Windows if it is not already installed.

During installation, take note of:
- The database server host, usually `localhost`.
- The port, usually `5432`.
- The PostgreSQL username.
- The password associated with that username.

You can manage the database using pgAdmin or another PostgreSQL client.

### Step 2: Create the Database

Create a database named:

```sql
CREATE DATABASE grp05_lostandfounddb;
```

You can execute this command through pgAdmin's Query Tool while connected to the PostgreSQL server, or create the database through its interface.

### Step 3: Initialize the Schema

The repository contains the following SQL scripts:

- `sql/grp05_lostandfounddb_script.sql` — creates the database tables and schema.
- `sql/grp05_lostandfounddb_test_data_script.sql` — inserts test data.
- `sql/grp05_lostandfounddb_role_creation_sample_script.sql` — creates the application and public database roles and grants their privileges.

Run `grp05_lostandfounddb_script.sql` against the `grp05_lostandfounddb` database first.

After the schema has been created successfully, run `grp05_lostandfounddb_test_data_script.sql` against the same database.

**Important:** Execute the schema script before the test-data script because the test data depends on the tables and relationships defined by the schema.

### Step 4: Create the application database roles

After creating the schema, run `grp05_lostandfounddb_role_creation_sample_script.sql` with a PostgreSQL administrator account. Replace both `enter_your_password_here` placeholders with local passwords before running it. Use the same credentials for `DB_USER` / `DB_PASSWORD` and `DB_PUBLIC_USER` / `DB_PUBLIC_PASSWORD` in `.env`, respectively. Do not commit the passwords.

## 4. Configure PHP PostgreSQL Support

The PHP installation used to run the project must have both `pgsql` and `pdo_pgsql` enabled.

### Step 1: Check PHP

Open PowerShell or a terminal in the project directory:

```powershell
php -v
php --ini
```

The first command displays the PHP version. The second identifies the configuration file (`php.ini`) used by that PHP installation.

If `php` is not recognized, install PHP or add its directory to your Windows `PATH`.

### Step 2: Check the Extensions

Run:

```powershell
php -m
```

Look for these modules in the output:

```text
pgsql
pdo_pgsql
```

Both must be available to the PHP CLI that will run the API.

### Step 3: Enable Missing Extensions

If either extension is missing:

1. Open the `php.ini` file identified by `php --ini`.
2. Locate the PostgreSQL extension entries.
3. Enable the corresponding extensions by removing the leading semicolon if present.

For example:

```ini
extension=pdo_pgsql
extension=pgsql
```

4. Save the file.
5. Run `php -m` again to verify that both extensions are loaded.

The exact extension configuration may vary by PHP distribution. If the extensions are unavailable, install a PHP distribution that includes compatible PostgreSQL extensions.

If you use XAMPP, make sure you configure the `php.ini` belonging to the PHP installation that will actually run the API.

## 5. Configure the Environment Variables

The API reads configuration from a `.env` file in the project root. Start by copying the example file:

```powershell
Copy-Item .env.example .env
```

On macOS/Linux, use `cp .env.example .env` instead.

Set the database values in `.env`:

```ini
DB_HOST=localhost
DB_PORT=5432
DB_NAME=grp05_lostandfounddb
DB_USER=your_database_user
DB_PASSWORD=your_database_password
DB_PUBLIC_USER=your_database_public_user
DB_PUBLIC_PASSWORD=your_database_public_password
```

The admin server uses `DB_USER` and `DB_PASSWORD`. The public server uses `DB_PUBLIC_USER` and `DB_PUBLIC_PASSWORD`. These must match the PostgreSQL roles and passwords configured for the project. The entry points are separate: `admin/index.php` only accepts `/api/admin/...` requests, and `public/index.php` only accepts `/api/public/...` requests.

### Optional notification integrations

TextBee and EmailJS are not required to start the API or use its core database features, such as creating records, browsing/searching items, and testing database operations. Their credentials are only needed to deliver SMS and email notifications.

Some create, status-update, and potential-match flows automatically attempt a notification according to the user's contact preference. Without valid provider settings, the notification will not be delivered and PHP may emit warnings, but the database operation is performed before the notification attempt.

To enable notifications, create accounts with [TextBee](https://textbee.dev/) and [EmailJS](https://www.emailjs.com/), then configure these values in `.env`:

```ini
TEXTBEE_API_KEY=your_textbee_api_key
TEXTBEE_BASE_URL=https://api.textbee.dev

EMAILJS_BASE_URL=https://api.emailjs.com
EMAILJS_SERVICE_ID=your_emailjs_service_id
EMAILJS_TEMPLATE_ID=your_emailjs_template_id
EMAILJS_PUBLIC_KEY=your_emailjs_public_key
```

Configure the EmailJS template to accept the `body` and `email` template parameters sent by the application. Without valid provider settings, notifications cannot be delivered; the core database/API workflows remain usable.

**Important:**
- Never commit `.env` or real database/provider credentials.
- Keep `.env` local; `.gitignore` should exclude it.
- Use placeholders only in `.env.example`, screenshots, and shared documentation.

`src/db/db.php` reads `.env` with PHP's `parse_ini_file()` and selects the admin or public credentials according to which entry point is handling the request.

## 6. Run the API

Run each API from the project root in its own terminal. They use different document roots and ports so they can run at the same time.

### Public API

```sh
php -S 127.0.0.1:8000 -t public
```

Public base URL: `http://127.0.0.1:8000`

### Admin API

In a second terminal:

```sh
php -S 127.0.0.1:8001 -t admin
```

Admin base URL: `http://127.0.0.1:8001`

Keep both terminals open while using the APIs. For a quick check, send these requests with Postman or Thunder Client:

```http
GET http://127.0.0.1:8000/api/public/categories
GET http://127.0.0.1:8001/api/admin/test
```

The first request should return the category list; the second should return the API test message. If either reports a database connection error, check the PostgreSQL service, the matching admin/public credentials in `.env`, the database name, and the PHP PostgreSQL extensions.

## 7. Test the API

Use an API testing tool such as **Postman** or **Thunder Client** to test the available endpoints.

For each endpoint, check:
- The HTTP method and URL.
- The request body and headers, when required.
- The returned JSON data.
- The HTTP status code.
- The response when invalid or missing data is supplied.

As new endpoints are implemented, their request methods, URLs, parameters, and expected responses should be documented in the project README or the team's API documentation.

## 8. Development Workflow — Git Branches and Pull Requests

Each developer is encouraged to create a separate branch for the issue or feature they are assigned. Do not commit feature work directly to `main`.

### Step 1: Update `main`

Before starting work:

```powershell
git switch main
git pull origin main
```

### Step 2: Create a Feature Branch

Use a descriptive branch name based on the issue or feature.

Examples:

```powershell
git switch -c feature/found-items
git switch -c feature/lost-reports
git switch -c feature/claim-management
```

Create only the branch relevant to your assigned task.

### Step 3: Implement and Test

- Follow the existing project architecture and coding conventions.
- Avoid modifying shared files without coordinating with the project lead.
- Test the implemented endpoints using Postman or Thunder Client.
- Make sure the feature works with the agreed-upon database schema.
- Commit only the changes related to your assigned task.

### Step 4: Commit Your Changes

```powershell
git add .
git commit -m "Implement found item retrieval"
git push -u origin feature/found-items
```

Replace the branch name and commit message with those appropriate for your task.

### Step 5: Submit a Pull Request

On GitHub:

1. Open the project repository.
2. Create a pull request from your feature branch into `main`.
3. Describe what you implemented.
4. Include the endpoints tested and their results.
5. Mention any known issues or changes requiring integration.

The project lead will review the submitted code, request changes if needed, test the integration, and merge the pull request when it is ready.

Do not merge your own pull request unless explicitly authorized.

### Branching Guidelines

- Use one branch per issue or feature.
- Keep branches focused on the assigned task.
- Avoid committing `.env`, credentials, or unrelated files.
- Pull the latest changes from `main` before starting new work.
- Coordinate changes to shared files to reduce merge conflicts.
- Ask the project lead before changing the database schema or shared application architecture.

## 9. Troubleshooting

| Problem | What to check |
|---|---|
| `php` is not recognized | Install PHP or configure the Windows `PATH`. |
| `could not find driver` | Enable `pdo_pgsql` in the PHP configuration used by the server. |
| `Class "PDO" not found` or PostgreSQL-related class errors | Verify the PHP installation and required extensions. |
| Database connection failed | Verify PostgreSQL is running and check `.env` values. |
| Database does not exist | Create `grp05_lostandfounddb` before running the SQL scripts. |
| Table does not exist | Execute the schema script against the correct database. |
| Test data insertion fails | Verify that the schema was initialized and referenced records exist. |
| API returns `404` | Check the request URL, HTTP method, and implemented endpoint. |
| Changes do not appear on GitHub | Confirm that the correct branch was pushed. |

## 10. Project Guidelines

This project uses native PHP, PDO, and PostgreSQL to implement a REST API.

The intended architecture is:

```text
index.php
    ↓
Controller
    ↓
Service
    ↓
Repository
    ↓
PostgreSQL
```

Follow the existing architecture when implementing new features. Keep HTTP handling in controllers, business logic in services, and SQL operations in repositories.



## Additional Project Resources:
- [Informal Documentation](https://docs.google.com/document/d/1-5aMBfCVfKJ3zU1nbGnBMF0GyYv30UPKHnW3pPxG6Is/edit?tab=t.cgekm2zjfg#heading=h.pw7bwki50q29)
- [Activity 2 Application Blueprint](https://drive.google.com/file/d/1Aemwp4iH1OYGZf6ZI4rz8Pw3OHGaA_Dv/view?usp=drive_link)
