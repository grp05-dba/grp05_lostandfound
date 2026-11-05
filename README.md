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

TextBee and EmailJS are optional. They are only needed if you want the application to send SMS and email notifications. Although setting them up is highly encouraged to experience the application's full functionality, including receiving notifications about potential item matches and claim status updates.

## 1. Clone the repository

Open a terminal and run:

```bash
git clone https://github.com/grp05-dba/grp05_lostandfound.git
cd grp05_lostandfound
```

## 2. Create and initialize the database

Start PostgreSQL and open **pgAdmin**. Connect to your PostgreSQL server, then follow these steps to create and initialize the project database.

### 2.1 Create the project database

1. In the Object Explorer, right-click **Databases**.
2. Select **Create → Database**.
3. Enter `grp05_lostandfounddb` as the database name.
4. Click **Save**.

Alternatively, you can open the Query Tool and execute:

```sql
CREATE DATABASE grp05_lostandfounddb;
```

### 2.2 Run the database scripts

After creating the database, select `grp05_lostandfounddb` in the Object Explorer, right-click it, and open **Query Tool**.

Open each SQL script from the project's `sql/` directory, copy its contents, paste them into the Query Tool, and click **Execute/Refresh** (the lightning bolt icon) to run the queries.

Execute the scripts in the following order:

1. **`sql/grp05_lostandfounddb_script.sql`** — Creates the database tables and their relationships.
2. **`sql/grp05_lostandfounddb_necessary_data_script.sql`** — Inserts the categories required by the application.
3. **`sql/grp05_lostandfounddb_role_creation_sample_script.sql`** — Creates the database roles and grants their permissions.

**Important:** The role-creation script must be executed by a PostgreSQL administrator. Before running it, replace both occurrences of `enter_your_password_here` with passwords of your choice. Keep these passwords private.

### 2.3 Load optional demonstration data

If you want to populate the database with sample records, open the following script in pgAdmin's Query Tool:

**`sql/grp05_lostandfounddb_demo_data_script.sql`**

Copy its contents, paste them into the Query Tool, and click **Execute/Refresh** to run the script.

This script is intended for a clean demo database. Avoid running it repeatedly on a database that already contains its sample records.


## 3. Configure PHP

The application requires PHP's `pdo_pgsql` and `pgsql` extensions to communicate with PostgreSQL.

### 3.1 Check your active PHP configuration

Check that PHP is installed:

```bash
php -v
```

Find the `php.ini` file used by your PHP installation:

```bash
php --ini
```

Look for the **Loaded Configuration File** entry. Open that `php.ini` file using a text editor.

> **Note:** If you use XAMPP, WAMP, or another PHP bundle, make sure you edit the configuration file belonging to that installation. The PHP used by your terminal may use a different `php.ini` from the PHP used by Apache.

### 3.2 Enable the PostgreSQL extensions

Follow the instructions for your operating system.

**Windows (standalone PHP, XAMPP, or WAMP):**

1. Open the active `php.ini` file.
2. Find the following lines:

   ```ini
   ;extension=pdo_pgsql
   ;extension=pgsql
   ```

3. Remove the leading semicolons:

   ```ini
   extension=pdo_pgsql
   extension=pgsql
   ```

4. Save the file.
5. If you use Apache through XAMPP or WAMP, restart Apache. For PHP's built-in development server, stop and start the server again.

If the entries are not present, add the two `extension=` lines to `php.ini`. Make sure the PostgreSQL extension files are included in PHP's `ext` directory and that `extension_dir` points to that directory.

**Linux (Arch Linux):**

Install the PostgreSQL extension package:

```bash
sudo pacman -S php-pgsql
```

Open `/etc/php/php.ini` and uncomment these lines:

```ini
extension=pdo_pgsql
extension=pgsql
```

Save the file and restart any running PHP or web server process.

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

If you want to enable notifications but prefer not to create your own TextBee and EmailJS accounts, you may contact the project maintainer to request access to the project's API credentials.

**Never commit your `.env` file or share real credentials publicly.** The repository's `.gitignore` excludes `.env`.

## 5. Run the application locally

The project has separate public and admin interfaces. They use ports **8000** and **8001**, respectively.

Open two terminals from the repository root.

**Terminal 1 — Public interface and API:**

```bash
php -S 127.0.0.1:8000 -t public
```

Open the public interface at:

- http://127.0.0.1:8000/app.html

**Terminal 2 — Admin interface and API:**

```bash
php -S 127.0.0.1:8001 -t admin
```

Open the admin interface at:

- http://127.0.0.1:8001/app.html

While the public interface at:
- http://127.0.0.1:8000/app.html

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
