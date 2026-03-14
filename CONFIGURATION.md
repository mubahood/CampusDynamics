# Configuration Guide – Campus Dynamics

This document explains how to configure Campus Dynamics for different environments (local development, staging, production).

---

## Table of Contents
1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Configuration Files](#configuration-files)
4. [Placeholder Reference](#placeholder-reference)
5. [Environment Transforms](#environment-transforms)
6. [PowerShell Test Scripts](#powershell-test-scripts)
7. [Security Guidelines](#security-guidelines)
8. [Troubleshooting](#troubleshooting)

---

## Overview

Campus Dynamics uses ASP.NET Web.config files to store environment-specific settings such as database connection strings, session timeouts, and debug flags. Because these files contain sensitive credentials, **they are excluded from source control**.

Instead, each sensitive file has a corresponding `.example` file that is committed and serves as the setup template:

| Tracked (safe) template         | Local file to create (git-ignored)  | Purpose                            |
|---------------------------------|--------------------------------------|------------------------------------|
| `web.config.example`            | `web.config`                         | Main application configuration     |
| `web.Debug.config.example`      | `web.Debug.config`                   | Debug build transformation         |
| `web.Release.config.example`    | `web.Release.config`                 | Release/production transformation  |
| `test_db.ps1.example`           | `test_db.ps1`                        | Database connectivity test script  |
| `test_queries.ps1.example`      | `test_queries.ps1`                   | SQL query verification script      |

---

## Quick Start

Run the following commands in PowerShell from the project root to create your local config files from the templates:

```powershell
# 1. Create the main web.config
Copy-Item web.config.example         web.config

# 2. (Optional) Create build-specific transforms
Copy-Item web.Debug.config.example   web.Debug.config
Copy-Item web.Release.config.example web.Release.config

# 3. (Optional) Create local test scripts
Copy-Item test_db.ps1.example        test_db.ps1
Copy-Item test_queries.ps1.example   test_queries.ps1
```

After copying, open each file and replace every `{{ PLACEHOLDER }}` with your actual value (see [Placeholder Reference](#placeholder-reference) below).

---

## Configuration Files

### `web.config`

The primary ASP.NET configuration file. Key sections:

| Section             | What to configure                                                |
|---------------------|------------------------------------------------------------------|
| `<connectionStrings>` | MySQL host, port, user, password for all application databases |
| `<appSettings>`     | Application-level switches and API keys                          |
| `<compilation>`     | Set `debug="true"` in development, `"false"` in production       |
| `<customErrors>`    | Set `mode="Off"` in dev, `mode="RemoteOnly"` in production       |
| `<sessionState>`    | Timeout in minutes (`43200` = 30 days)                           |

### Databases

Campus Dynamics connects to four MySQL databases:

| Connection string name                        | Database                     | Used by                             |
|-----------------------------------------------|------------------------------|-------------------------------------|
| `LocalMySqlServer` / `vacConnectionString`    | `campus_dynamics`            | Core application, security, roles   |
| `campus_dynamics_admissionsConnectionString`  | `campus_dynamics_admissions` | Admissions module                   |
| `accountsConnectionString`                    | `campus_dynamics_accounts`   | Finance & accounting module         |
| `campus_dynamics_portalConnectionString`      | `campus_dynamics_portal`     | Student & staff portal              |

---

## Placeholder Reference

All placeholders use the `{{ NAME }}` convention so they are easy to find with a text search.

| Placeholder                         | Description                                                          | Example value          |
|-------------------------------------|----------------------------------------------------------------------|------------------------|
| `{{ DB_SERVER }}`                   | MySQL server hostname or IP address                                  | `localhost`, `10.0.1.5`|
| `{{ DB_PORT }}`                     | MySQL port (default 3306)                                            | `3306`                 |
| `{{ DB_USER }}`                     | MySQL username                                                       | `root`, `campus_app`   |
| `{{ DB_PASSWORD }}`                 | MySQL password                                                       | *(your password)*      |
| `{{ true_for_dev__false_for_prod }}` | Compilation debug flag                                              | `true` or `false`      |

Search for remaining placeholders after copying:

```powershell
Select-String -Path web.config -Pattern '\{\{.*?\}\}'
```

---

## Environment Transforms

ASP.NET Web.config transformations are applied automatically during publish/build:

- **`web.Debug.config`** – applied when building in `Debug` configuration. Typically overrides connection strings to point to your local database and keeps `debug="true"`.
- **`web.Release.config`** – applied when building in `Release` configuration. Should point to production/staging database, disable debug, and set `customErrors` to `RemoteOnly`.

Visual Studio applies transforms automatically. To apply manually via MSBuild:

```powershell
msbuild CampusDynamics.sln /p:Configuration=Release /p:DeployOnBuild=true
```

---

## PowerShell Test Scripts

The `.ps1` scripts allow direct database testing without running the full web application:

| Script              | Purpose                                                   |
|---------------------|-----------------------------------------------------------|
| `test_db.ps1`       | Basic database connectivity and sanity check queries      |
| `test_queries.ps1`  | Run key SQL queries to verify data shape                  |
| `test_nche_queries.ps1` | NCHE-specific export query validation               |

### Prerequisites

1. MySQL .NET Connector must be installed (the GAC must contain `MySql.Data.dll`).
2. Run PowerShell as Administrator, or use `-ExecutionPolicy Bypass`:

```powershell
powershell -ExecutionPolicy Bypass -File test_db.ps1
```

---

## Security Guidelines

- **Never commit real credentials.** `.gitignore` is already configured to block `web.config`, `web.Debug.config`, `web.Release.config`, and the test scripts.
- **Use a dedicated database user in production** with only the permissions the application needs (SELECT, INSERT, UPDATE, DELETE on the four databases). Avoid using the MySQL `root` account.
- **Enable SSL for production database connections** by adding `SslMode=Required` to the connection string (already included in `web.Release.config.example`).
- **Rotate credentials** if they are accidentally committed. Use `git filter-branch` or BFG Repo Cleaner to purge history.
- **Keep `Persist Security Info=False`** in production connection strings so credentials are not returned after the connection is established.

---

## Troubleshooting

### `Unable to connect to any of the specified MySQL hosts`
- Verify `{{ DB_SERVER }}` is reachable from the web server (ping / telnet on port 3306).
- Check that the MySQL user has `GRANT` permissions from the application server's IP.

### `Access denied for user '...'@'...'`
- The MySQL user/password in the connection string is wrong, or the user does not exist.
- Run `SHOW GRANTS FOR '{{ DB_USER }}'@'{{ DB_SERVER }}';` in MySQL to verify.

### `The entity type X is not part of the model for the current context`
- Ensure all four databases exist and have been seeded with the base schema.

### `Could not load file or assembly 'MySql.Data, Version=6.6.7.0'`
- The MySQL .NET Connector v6.6.7 must be present in the `Bin/` folder or the GAC.
- You can install it via NuGet: `Install-Package MySql.Data -Version 6.6.7`.

### Debug builds not applying transformations
- Ensure `web.Debug.config` is nested under `web.config` in Solution Explorer (right-click → Add Config Transform if missing).
