# PUP-SPOT — Campus Lost and Found

PUP-SPOT is a campus Lost and Found system for browsing found items, submitting lost-item reports, requesting claims, and tracking submissions using reference codes.

This guide covers setting up a local copy of the project.

## Requirements

Install the following:

- **Git**
- **PHP 8.0 or later**
- **PostgreSQL**
- **PHP PostgreSQL extensions:** pdo_pgsql and pgsql
- A PostgreSQL client such as **pgAdmin** or **psql**

TextBee and EmailJS are optional. They are only needed if you want the application to send SMS and email notifications about potential item matches and claim status updates.

## 1. Clone the repository

~~~bash
git clone https://github.com/grp05-dba/grp05_lostandfound.git
cd grp05_lostandfound
~~~

## 2. Create and initialize the database

Start PostgreSQL and open **pgAdmin**. Connect to your PostgreSQL server, then create the project database.

### 2.1 Create the project database

1. In the Object Explorer, right-click **Databases**.
2. Select **Create → Database**.
3. Enter grp05_lostandfounddb as the database name.
4. Click **Save**.

Alternatively, execute:

~~~sql
CREATE DATABASE grp05_lostandfounddb;
~~~

### 2.2 Run the database scripts

After creating the database, select grp05_lostandfounddb in the Object Explorer and open **Query Tool**.

Run the SQL scripts from the project's sql/ directory in this order:

1. **sql/grp05_lostandfounddb_script.sql** — Creates the database tables and relationships.
2. **sql/grp05_lostandfounddb_necessary_data_script.sql** — Inserts the categories required by the application.
3. **sql/grp05_lostandfounddb_role_creation_sample_script.sql** — Creates the public and admin application roles and grants their permissions.

The role-creation script must be executed by a PostgreSQL administrator. Before running it, replace both occurrences of enter_your_password_here with private passwords of your choice. Do not use the PostgreSQL postgres superuser as an application connection.

### 2.3 Load optional demonstration data

To populate the database with sample records, run:

**sql/grp05_lostandfounddb_demo_data_script.sql**

Use a clean demo database. The script manages its own demo records, but it is not a substitute for a backup or migration procedure.

## 3. Configure PHP

The application requires PHP's `pdo_pgsql` and `pgsql` extensions to communicate with PostgreSQL.

### 3.1 Check your active PHP configuration

Check that PHP is installed:

~~~bash
php -v
~~~

Find the `php.ini` file used by your PHP installation:

~~~bash
php -m
~~~

Look for the **Loaded Configuration File** entry. Open that `php.ini` file using a text editor.

~~~text
pdo_pgsql
pgsql
~~~

If either extension is missing, enable it in the php.ini used by your PHP installation, then run php -m again. To locate the active configuration file, run:

~~~bash
php --ini
~~~

## 4. Configure environment variables

Create your local .env file from the provided example.

**Linux/macOS:**

~~~bash
cp .env.example .env
~~~

**Windows PowerShell:**

~~~powershell
Copy-Item .env.example .env
~~~

Open .env and enter the database credentials configured in the role-creation script:

~~~ini
DB_HOST=localhost
DB_PORT=5432
DB_NAME=grp05_lostandfounddb

# Admin API database role
DB_USER=lostandfound_app
DB_PASSWORD=your_app_role_password

# Public API database role
DB_PUBLIC_USER=lostandfound_public
DB_PUBLIC_PASSWORD=your_public_role_password
~~~

The public API uses the restricted lostandfound_public role. The admin API uses the broader lostandfound_app application role. Keep both passwords private and use the same values configured in PostgreSQL.

### Optional: Enable notifications

SMS and email notifications require provider credentials. Without them, the core application and database-backed workflows can still be used, but notifications will not be delivered.

To enable them, add your TextBee and EmailJS credentials to .env:

~~~ini
TEXTBEE_API_KEY=your_textbee_api_key
TEXTBEE_BASE_URL=https://api.textbee.dev

EMAILJS_BASE_URL=https://api.emailjs.com
EMAILJS_SERVICE_ID=your_emailjs_service_id
EMAILJS_TEMPLATE_ID=your_emailjs_template_id
EMAILJS_PUBLIC_KEY=your_emailjs_public_key
~~~

See [TextBee](https://textbee.dev/) and [EmailJS](https://www.emailjs.com/) for provider account setup and credentials.

**Never commit your .env file or share real credentials publicly.** The repository's .gitignore excludes .env.

## 5. Run the application locally

The project has separate public and admin interfaces. For local development, run them from the same repository in two separate PHP server instances.

**Terminal 1 — Public interface and API:**

~~~bash
php -S 127.0.0.1:8000 -t public
~~~

Open: http://127.0.0.1:8000/app.html

**Terminal 2 — Admin interface and API:**

~~~bash
php -S 127.0.0.1:8001 -t admin
~~~

Open: http://127.0.0.1:8001/app.html

Keep both server terminals running while using the application.

## 6. Deployment and access model

The intended deployment separates the two APIs:

- **Server A — Public API:** handles student/guest searches, lost reports and claims. It uses the restricted public database role.
- **Server B — Admin API:** handles administrative item and claim management. It uses the broader admin application database role and is intended to be accessible only through the campus private network or equivalent network restrictions.

Both APIs remain in the same repository and project folder. The two local ports above simulate this arrangement; they do not create true network isolation because both servers run on the same computer.

PUP-SPOT does not include an Admin username/password login. Network restriction is the intended administrative access boundary. Anyone who can reach the admin server through the permitted network may potentially access its functions, so the admin server must not be exposed to the public internet.

For more details, see [docs/architecture.md](docs/architecture.md), [docs/user-roles.md](docs/user-roles.md), and [docs/database.md](docs/database.md).

## Troubleshooting

| Issue | What to check |
|---|---|
| php command not found | Install PHP or add its executable directory to your system's PATH. |
| could not find driver | Enable the pdo_pgsql extension in the active PHP configuration. |
| PostgreSQL connection failed | Confirm PostgreSQL is running and verify the database credentials in .env. |
| Database does not exist | Create grp05_lostandfounddb before running the SQL scripts. |
| Relation/table does not exist | Run the schema script against the correct database. |
| Categories are missing | Run the necessary-data script after the schema script. |
| API returns 404 | Confirm both PHP servers are running and that you are using the correct interface URL and API port. |
| Notifications are not sent | Check the TextBee or EmailJS credentials in .env. |
