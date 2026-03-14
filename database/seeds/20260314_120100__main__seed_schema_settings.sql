-- Seed: seed_schema_settings
-- Logical database: main
-- Purpose: Record deterministic migration-framework defaults for this project.

INSERT INTO cd_schema_settings (setting_key, setting_value, description)
VALUES
('project_name', 'CampusDynamics', 'Owning project for this database migration pipeline'),
('migration_strategy', 'sql-first', 'Database changes are managed as ordered SQL migrations'),
('seed_strategy', 'idempotent', 'Seed scripts must be deterministic and safe to replay as new files'),
('baseline_import_required', 'true', 'Fresh environments should start from vetted SQL dumps before incremental migrations'),
('default_logical_database', 'main', 'Primary logical database for this project')
ON DUPLICATE KEY UPDATE
    setting_value = VALUES(setting_value),
    description = VALUES(description);
