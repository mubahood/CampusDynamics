# Database Migration and Seeding Workflow

This folder introduces a **Laravel-like, SQL-first migration and seeding workflow** for the legacy ASP.NET Web Forms codebase.

The objective is to make database changes:

- repeatable
- safe across environments
- auditable
- easy for contributors to use
- independent of one contributor's local machine

---

## Quick Reference

| Task | Command |
|---|---|
| Show help | `.\database\cd-db.ps1 help` |
| Preview everything (no DB needed) | `.\database\cd-db.ps1 status -DryRun` |
| Full environment bootstrap | `.\database\cd-db.ps1 init -CreateDatabases -ImportDumps -RunSeeds -RunValidation` |
| Apply pending migrations | `.\database\cd-db.ps1 migrate` |
| Apply pending seeds | `.\database\cd-db.ps1 seed` |
| Roll back most recent batch | `.\database\cd-db.ps1 rollback:last -Database main` |
| Validate database state | `.\database\cd-db.ps1 validate` |
| Create a migration | `.\database\cd-db.ps1 make:migration <name> -Database <db>` |
| Create a seed | `.\database\cd-db.ps1 make:seed <name> -Database <db>` |

> **Tip**: Add `-DryRun` to any command to preview what it would do without touching a database.

---

## 1. Why this approach was chosen

We evaluated several approaches before implementing this workflow.

### Approach A — manual SQL files only
**Pros**: simple to start, no tooling required.
**Cons**: no execution history, no checksum verification, easy to miss steps, hard to coordinate across contributors, fragile for multi-database projects.

### Approach B — ORM-specific migrations (Entity Framework, FluentMigrator)
**Pros**: structured migration lifecycle, strong developer ergonomics in newer stacks.
**Cons for this project**: this solution is legacy Web Forms; data access is a mix of TableAdapters, raw SQL, stored procedures, and MySQL-specific objects; introducing ORM migrations would create a partially disconnected schema model.

### Approach C — SQL-first runner with migration history tables (**chosen**)
**Pros**: matches the current architecture, supports tables/indexes/procedures/views/data fixes, works across multiple databases, easy to review in PRs, easy to apply in CI/CD, low coupling to application runtime.
**Cons**: contributors must write careful SQL, rollback discipline must be maintained.

---

## 2. What was implemented

### Tooling
| File | Purpose |
|---|---|
| [cd-db.ps1](cd-db.ps1) | Command entry point (`artisan`-style CLI) |
| [DatabaseTools.psm1](DatabaseTools.psm1) | Core engine: migration, seed, import, and validation logic |
| [database.settings.json](database.settings.json) | Tracked project database topology |
| `database.settings.local.json` | **Git-ignored** local runtime settings (credentials, overrides) |
| [database.settings.local.example.json](database.settings.local.example.json) | Safe template for contributors |

### Folder structure
| Folder | Contents |
|---|---|
| [migrations/](migrations) | Ordered `.up.sql` / `.down.sql` migration scripts |
| [seeds/](seeds) | Ordered SQL seed scripts |
| [imports/](imports) | Baseline SQL dump files (git-ignored, placed locally) |

### Initial migration content
- [20260314_120000__main__create_api_tokens_table.up.sql](migrations/20260314_120000__main__create_api_tokens_table.up.sql) / [.down.sql](migrations/20260314_120000__main__create_api_tokens_table.down.sql)
- [20260314_120100__main__seed_schema_settings.sql](seeds/20260314_120100__main__seed_schema_settings.sql)

---

## 3. Logical database map

This project manages multiple MySQL databases through a single tool:

| Logical name | Default database | Environment variable | Create order |
|---|---|---|---|
| `main` | `campus_dynamics` | `CD_DB_MAIN` | 1 |
| `admissions` | `campus_dynamics_admissions` | `CD_DB_ADMISSIONS` | 2 |
| `accounts` | `campus_dynamics_accounts` | `CD_DB_ACCOUNTS` | 3 |
| `portal` | `campus_dynamics_portal` | `CD_DB_PORTAL` | 4 |

Every migration and seed filename includes the target logical database, so the runner automatically applies each script to the correct database.

---

## 4. Internal safety mechanisms

### Metadata tables
For every target database, the tool automatically creates these tables on first use:

| Table | Purpose |
|---|---|
| `cd_schema_migrations` | Tracks applied migrations with checksums, batch numbers, timestamps |
| `cd_schema_seeds` | Tracks applied seeds with checksums |
| `cd_schema_imports` | Tracks imported baseline dumps |
| `cd_schema_settings` | Stores framework configuration defaults |

### Checksum verification
Every migration and seed file is hashed with SHA-256. If someone edits an already-applied file, the runner **stops and fails fast** with a clear error instead of silently continuing.

### MySQL named locks
Only one migration or seed process can run on the same target database at a time. The runner acquires a MySQL advisory lock (`GET_LOCK`) and releases it after completion.

### Malformed file protection
Files in `migrations/` or `seeds/` that don't match the required naming pattern are **skipped with a warning** rather than crashing. This prevents one contributor's misnamed file from blocking the entire team.

### Logical database validation
`make:migration` and `make:seed` validate the `-Database` argument against the project's configured logical databases, preventing creation of files for non-existent databases.

### Lazy runtime resolution
Commands that don't require a database connection (`help`, `make:migration`, `make:seed`, and all `-DryRun` modes) work even when database credentials are not configured. New contributors can scaffold migrations immediately.

---

## 5. File naming rules

### Migration files

```
YYYYMMDD_HHMMSS__<logical-database>__<descriptive_name>.up.sql
YYYYMMDD_HHMMSS__<logical-database>__<descriptive_name>.down.sql
```

Example:
```
20260314_120000__main__create_api_tokens_table.up.sql
20260314_120000__main__create_api_tokens_table.down.sql
```

Rules:
- The timestamp ensures correct ordering across contributors
- The logical database name must match a configured database in `database.settings.json`
- The descriptive name should be lowercase with underscores
- Both `.up.sql` and `.down.sql` files must exist for every migration
- Special characters in names are automatically sanitized by `make:migration`

### Seed files

```
YYYYMMDD_HHMMSS__<logical-database>__<descriptive_name>.sql
```

Example:
```
20260314_120100__main__seed_schema_settings.sql
```

---

## 6. First-time contributor setup

### Prerequisites
- Windows PowerShell 5.1 or later
- MySQL Connector/NET 6.6.7 (or `MySql.Data.dll` in `Bin/`)
- Access to a MySQL server

### Step 1 — create local runtime settings

```powershell
Copy-Item .\database\database.settings.local.example.json .\database\database.settings.local.json
```

Edit the file and fill in:

| Field | Description | Example |
|---|---|---|
| `server.host` | MySQL server hostname | `127.0.0.1` |
| `server.port` | MySQL server port | `3306` |
| `server.user` | MySQL username | `root` |
| `server.password` | MySQL password | `yourpassword` |
| `databases.*` | Override database names if needed | `campus_dynamics_dev` |
| `assemblyPath` | Path to `MySql.Data.dll` if not auto-detected | `C:\path\to\MySql.Data.dll` |

> **Important**: `database.settings.local.json` is git-ignored. Never commit it.

### Step 2 — prepare baseline SQL dumps

Place vetted dumps in [imports/](imports):
- `main.sql`
- `admissions.sql`
- `accounts.sql`
- `portal.sql`

> These are git-ignored. Get them from the team lead or a shared secure location.

### Step 3 — bootstrap the databases

```powershell
.\database\cd-db.ps1 init -CreateDatabases -ImportDumps -RunSeeds -RunValidation
```

Bootstrap sequence:
1. Creates missing databases
2. Imports baseline SQL dumps (skipped if user tables already exist)
3. Records import history in `cd_schema_imports`
4. Applies all pending migrations in order
5. Applies all pending seeds in order
6. Runs validation queries to confirm success

### Step 4 — verify

```powershell
.\database\cd-db.ps1 status
```

All migrations and seeds should show as `[APPLIED]`.

---

## 7. Complete command reference

### `help`
Show available commands. Does **not** require database credentials.
```powershell
.\database\cd-db.ps1 help
```

### `status`
Show migration and seed status for each logical database.
```powershell
.\database\cd-db.ps1 status                         # live status from MySQL
.\database\cd-db.ps1 status -DryRun                  # show discovered files only
.\database\cd-db.ps1 status -Database main            # filter to one database
.\database\cd-db.ps1 status -Database main,portal     # filter to multiple
```

### `init`
Full environment bootstrap.
```powershell
.\database\cd-db.ps1 init -CreateDatabases -ImportDumps -RunSeeds -RunValidation
.\database\cd-db.ps1 init -CreateDatabases -ImportDumps -RunSeeds -RunValidation -DryRun
.\database\cd-db.ps1 init -CreateDatabases -ImportDumps -ForceImport -RunSeeds
.\database\cd-db.ps1 init -Database main
```

| Flag | Effect |
|---|---|
| `-CreateDatabases` | Create databases if they don't exist |
| `-ImportDumps` | Import baseline SQL dumps from `imports/` |
| `-ForceImport` | Import dumps even if user tables already exist |
| `-RunSeeds` | Apply pending seeds after migrations |
| `-RunValidation` | Run validation queries after everything |
| `-DryRun` | Preview only |
| `-Database` | Filter to specific logical database(s) |

### `migrate`
Apply pending migrations.
```powershell
.\database\cd-db.ps1 migrate                         # all databases
.\database\cd-db.ps1 migrate -Database main           # only main
.\database\cd-db.ps1 migrate -DryRun                  # preview only
```

### `rollback:last`
Roll back the most recent migration batch.
```powershell
.\database\cd-db.ps1 rollback:last -Database main
.\database\cd-db.ps1 rollback:last -DryRun
```

### `seed`
Apply pending seeds.
```powershell
.\database\cd-db.ps1 seed                             # all databases
.\database\cd-db.ps1 seed -Database main              # only main
.\database\cd-db.ps1 seed -DryRun                     # preview only
```

### `validate`
Run validation queries from `database.settings.json`.
```powershell
.\database\cd-db.ps1 validate                         # all databases
.\database\cd-db.ps1 validate -Database main          # only main
.\database\cd-db.ps1 validate -DryRun                 # preview only
```

### `make:migration`
Create migration scaffold (up + down files). Does **not** require database credentials.
```powershell
.\database\cd-db.ps1 make:migration add_student_flags -Database main
.\database\cd-db.ps1 make:migration create_audit_log -Database accounts
```

### `make:seed`
Create seed scaffold. Does **not** require database credentials.
```powershell
.\database\cd-db.ps1 make:seed seed_student_status_lookup -Database main
.\database\cd-db.ps1 make:seed seed_default_categories -Database admissions
```

---

## 8. How to create a new migration

### Example: add a column
```powershell
.\database\cd-db.ps1 make:migration add_is_archived_to_students -Database main
```

`.up.sql`:
```sql
ALTER TABLE acad_student
ADD COLUMN is_archived TINYINT(1) NOT NULL DEFAULT 0;
```

`.down.sql`:
```sql
ALTER TABLE acad_student
DROP COLUMN is_archived;
```

### Example: create a new table
```powershell
.\database\cd-db.ps1 make:migration create_notification_queue -Database main
```

`.up.sql`:
```sql
CREATE TABLE notification_queue (
    id INT AUTO_INCREMENT PRIMARY KEY,
    recipient_id INT NOT NULL,
    subject VARCHAR(255) NOT NULL,
    body TEXT NULL,
    sent_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_notification_sent (sent_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

`.down.sql`:
```sql
DROP TABLE IF EXISTS notification_queue;
```

### Example: modify a stored procedure
```powershell
.\database\cd-db.ps1 make:migration update_get_student_summary_proc -Database main
```

`.up.sql`:
```sql
DROP PROCEDURE IF EXISTS get_student_summary;
DELIMITER ;;
CREATE PROCEDURE get_student_summary(IN p_student_id INT)
BEGIN
    -- new implementation here
END;;
DELIMITER ;
```

### Migration rules
- **Never** edit a migration that has already been applied anywhere shared
- Create a new migration instead of modifying an existing one
- Include a real rollback in `.down.sql` when feasible
- Keep SQL deterministic and idempotent where possible
- For risky data rewrites, back up first and document recovery steps
- One concern per migration file when practical

### Testing a migration locally
```powershell
.\database\cd-db.ps1 migrate -Database main
.\database\cd-db.ps1 validate -Database main
.\database\cd-db.ps1 rollback:last -Database main    # test rollback
.\database\cd-db.ps1 migrate -Database main           # re-apply
```

---

## 9. How to create a new seed

Seeds are for deterministic shared data: lookup values, static config, reference records, safe defaults.

### Create a scaffold
```powershell
.\database\cd-db.ps1 make:seed seed_lookup_values -Database main
```

### Use idempotent SQL
```sql
INSERT INTO some_lookup_table (code, name)
VALUES ('A', 'Active')
ON DUPLICATE KEY UPDATE
    name = VALUES(name);
```

### Seed rules
- Make seeds idempotent (safe to run multiple times)
- Do not include contributor-specific or secret data
- Do not edit applied seeds — create a new one instead
- Prefer `INSERT ... ON DUPLICATE KEY UPDATE` over plain `INSERT`

---

## 10. Real database import strategy

### Baseline import philosophy
This is a mature legacy system. We are **not** trying to reconstruct the entire historical schema with retroactive migrations. Instead:

1. Start from a vetted SQL dump as the agreed baseline
2. Import that baseline into the target environment
3. Record the import in `cd_schema_imports`
4. Use incremental migrations for all future changes

### Import safety checks
- Already-imported dumps (matching checksum) are skipped
- If user tables already exist, import is skipped unless `-ForceImport` is used
- Import history is permanently recorded for audit

---

## 11. Development workflow

1. Pull latest code
2. Place approved SQL dumps in `imports/` for fresh environments
3. Bootstrap: `.\database\cd-db.ps1 init -CreateDatabases -ImportDumps -RunSeeds -RunValidation`
4. Develop normally
5. Schema changes → `make:migration`; shared data → `make:seed`
6. Apply and validate: `migrate`, `seed`, `validate`
7. Submit code + migration + seed + docs together in PR

---

## 12. PR rules for database changes

A PR with database changes should contain:
- Migration `.up.sql` and `.down.sql` files
- Seed file(s) if shared data changed
- Documentation updates if workflow expectations changed
- Clear explanation of which logical database is affected

### Never do this
- Edit an already-applied migration
- Hide database changes in `.sql` files outside this folder
- Commit baseline dumps into git
- Commit `database.settings.local.json`

---

## 13. Environment variables reference

| Variable | Purpose | Required? |
|---|---|---|
| `CD_DB_HOST` | MySQL server hostname | Yes (unless local settings file exists) |
| `CD_DB_PORT` | MySQL server port | No (defaults to `3306`) |
| `CD_DB_USER` | MySQL username | Yes (unless local settings file exists) |
| `CD_DB_PASSWORD` | MySQL password | Recommended |
| `CD_DB_MAIN` | Override `campus_dynamics` name | No |
| `CD_DB_ADMISSIONS` | Override `campus_dynamics_admissions` name | No |
| `CD_DB_ACCOUNTS` | Override `campus_dynamics_accounts` name | No |
| `CD_DB_PORTAL` | Override `campus_dynamics_portal` name | No |
| `CD_ENVIRONMENT_NAME` | Label for audit logs | No (defaults to `$env:USERNAME`) |
| `CD_MYSQL_ASSEMBLY_PATH` | Path to `MySql.Data.dll` | No (auto-detected) |

> **Priority**: `database.settings.local.json` > environment variables > defaults

---

## 14. Metadata table schemas

Automatically created in each target database:

### `cd_schema_migrations`
| Column | Type | Description |
|---|---|---|
| `id` | INT AUTO_INCREMENT | Primary key |
| `migration_key` | VARCHAR(255) UNIQUE | `stamp__database__name` identifier |
| `logical_database` | VARCHAR(64) | Target logical database |
| `checksum` | VARCHAR(64) | SHA-256 hash of the applied `.up.sql` file |
| `batch_no` | INT | Batch number (migrations applied together share a batch) |
| `applied_at` | DATETIME | When the migration was applied |
| `execution_ms` | INT | Execution duration in milliseconds |
| `applied_by` | VARCHAR(128) | Username who ran the migration |
| `host_name` | VARCHAR(128) | Machine name |
| `environment_name` | VARCHAR(128) | Environment label |
| `project_name` | VARCHAR(128) | Project name from settings |
| `script_path` | VARCHAR(500) | Full path to the applied script |

### `cd_schema_seeds`
Same columns as `cd_schema_migrations` except no `batch_no` column, and `seed_key` instead of `migration_key`.

### `cd_schema_imports`
| Column | Type | Description |
|---|---|---|
| `id` | INT AUTO_INCREMENT | Primary key |
| `import_key` | VARCHAR(255) UNIQUE | `dump::database::checksum` identifier |
| `logical_database` | VARCHAR(64) | Target logical database |
| `checksum` | VARCHAR(64) | SHA-256 of the dump file |
| `dump_path` | VARCHAR(500) | Full path to the imported dump |
| `imported_at` | DATETIME | When the dump was imported |
| `imported_by` | VARCHAR(128) | Username |
| `host_name` | VARCHAR(128) | Machine name |
| `environment_name` / `project_name` | VARCHAR(128) | Audit labels |

### `cd_schema_settings`
| Column | Type | Description |
|---|---|---|
| `setting_key` | VARCHAR(191) PRIMARY KEY | Setting identifier |
| `setting_value` | TEXT | Setting value |
| `description` | VARCHAR(500) | Description |
| `updated_at` | DATETIME | Last update timestamp |

---

## 15. Troubleshooting

### "Database server runtime configuration is incomplete"
**Cause**: No database credentials found.
**Fix**: Create `database.settings.local.json` from the example, or set `CD_DB_HOST` + `CD_DB_USER` environment variables.

### "Unable to load MySql.Data"
**Cause**: MySQL .NET connector not installed or not findable.
**Fix** (any one):
1. Install MySQL Connector/NET 6.6.7
2. Place `MySql.Data.dll` in `Bin/`
3. Set `CD_MYSQL_ASSEMBLY_PATH` to the DLL path
4. Set `assemblyPath` in `database.settings.local.json`

### "Authentication to host ... failed"
**Cause**: Wrong MySQL credentials.
**Fix**: Check `server.user` / `server.password` in local settings or `CD_DB_USER` / `CD_DB_PASSWORD` env vars.

### "Migration already applied with a different checksum"
**Cause**: An applied migration file was edited.
**Fix**: Do not edit applied migrations. Create a new migration with the corrective change.

### "Seed already applied with a different checksum"
**Cause**: An applied seed file was edited.
**Fix**: Create a new seed file instead.

### "Unable to acquire MySQL migration lock"
**Cause**: Another migration/seed process is running on the same database.
**Fix**: Wait for it to finish, or investigate orphaned locks.

### "Unknown logical database '...'"
**Cause**: Invalid database name passed to `-Database`.
**Fix**: Use a valid name from `database.settings.json`. The error lists all valid names.

### "[WARN] Skipping malformed migration/seed file"
**Cause**: A file doesn't match the naming pattern.
**Fix**: Rename to `YYYYMMDD_HHMMSS__database__name.up.sql` format, or delete if unintentional.

### "Rollback requested, but down migration is missing"
**Cause**: The `.down.sql` file for a migration doesn't exist.
**Fix**: Create the missing `.down.sql` file before rollback.

---

## 16. MySql.Data assembly search order

1. `assemblyPath` in `database.settings.local.json`
2. `CD_MYSQL_ASSEMBLY_PATH` environment variable
3. `Bin\MySql.Data.dll` in the project root
4. Default installer paths (`C:\Program Files (x86)\MySQL\...`)
5. Machine assembly cache (GAC)

---

## 17. Final rule for contributors

> Baseline structure comes from vetted dumps,
> future structure comes from migrations,
> future shared data comes from seeds,
> every environment applies the same ordered database changes,
> and no contributor should ever need to hand-edit production-like schema drift manually.
