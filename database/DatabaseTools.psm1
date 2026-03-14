Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-DbInfo {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-DbWarn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-DbOk {
    param([string]$Message)
    Write-Host "[ OK ] $Message" -ForegroundColor Green
}

function Write-DbErr {
    param([string]$Message)
    Write-Host "[FAIL] $Message" -ForegroundColor Red
}

function Get-JsonPropertyValue {
    param(
        $Object,
        [Parameter(Mandatory = $true)][string] $PropertyName,
        $Default = $null
    )

    if ($null -eq $Object) { return $Default }
    $prop = $Object.PSObject.Properties[$PropertyName]
    if ($null -eq $prop) { return $Default }
    return $prop.Value
}

function Get-DatabaseProjectRoot {
    param([string]$StartPath = $PSScriptRoot)

    $current = Get-Item -LiteralPath $StartPath
    if ($current.PSIsContainer -eq $false) {
        $current = $current.Directory
    }

    while ($null -ne $current) {
        $databaseFolder = Join-Path $current.FullName 'database'
        $settingsFile = Join-Path $databaseFolder 'database.settings.json'
        if (Test-Path -LiteralPath $settingsFile) {
            return $current.FullName
        }
        $current = $current.Parent
    }

    throw 'Unable to locate project root. Expected database/database.settings.json in this project.'
}

function Get-DatabaseSettings {
    param([string]$ProjectRoot)

    $databaseRoot = Join-Path $ProjectRoot 'database'
    $settingsPath = Join-Path $databaseRoot 'database.settings.json'
    $localSettingsPath = Join-Path $databaseRoot 'database.settings.local.json'

    if (-not (Test-Path -LiteralPath $settingsPath)) {
        throw "Database settings file not found: $settingsPath"
    }

    $settings = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json
    $localSettings = $null
    if (Test-Path -LiteralPath $localSettingsPath) {
        $localSettings = Get-Content -LiteralPath $localSettingsPath -Raw | ConvertFrom-Json
    }

    [pscustomobject]@{
        ProjectRoot = $ProjectRoot
        DatabaseRoot = $databaseRoot
        Settings = $settings
        LocalSettings = $localSettings
        SettingsPath = $settingsPath
        LocalSettingsPath = $localSettingsPath
    }
}

function Resolve-DatabaseRuntime {
    param([string]$ProjectRoot)

    $bundle = Get-DatabaseSettings -ProjectRoot $ProjectRoot
    $settings = $bundle.Settings
    $local = $bundle.LocalSettings

    $server = [pscustomobject]@{
        Host = $(
            $localHost = Get-JsonPropertyValue -Object (Get-JsonPropertyValue $local 'server') -PropertyName 'host'
            if ($localHost) { $localHost } else { [Environment]::GetEnvironmentVariable((Get-JsonPropertyValue $settings.server 'hostEnv')) }
        )
        Port = $(
            $localPort = Get-JsonPropertyValue -Object (Get-JsonPropertyValue $local 'server') -PropertyName 'port'
            if ($localPort) { [int]$localPort } else {
                $envPort = [Environment]::GetEnvironmentVariable((Get-JsonPropertyValue $settings.server 'portEnv'))
                if ([string]::IsNullOrWhiteSpace($envPort)) { 3306 } else { [int]$envPort }
            }
        )
        User = $(
            $localUser = Get-JsonPropertyValue -Object (Get-JsonPropertyValue $local 'server') -PropertyName 'user'
            if ($localUser) { $localUser } else { [Environment]::GetEnvironmentVariable((Get-JsonPropertyValue $settings.server 'userEnv')) }
        )
        Password = $(
            $localPassword = Get-JsonPropertyValue -Object (Get-JsonPropertyValue $local 'server') -PropertyName 'password'
            if ($localPassword) { $localPassword } else { [Environment]::GetEnvironmentVariable((Get-JsonPropertyValue $settings.server 'passwordEnv')) }
        )
        SslMode = $(
            $localSsl = Get-JsonPropertyValue -Object (Get-JsonPropertyValue $local 'server') -PropertyName 'sslMode'
            if ($localSsl) { $localSsl } else {
                $configured = Get-JsonPropertyValue -Object (Get-JsonPropertyValue $settings 'server') -PropertyName 'sslMode' -Default 'None'
                if ($configured) { $configured } else { 'None' }
            }
        )
    }

    # Server credential validation is deferred to Open-MySqlConnection so
    # commands like help, make:migration, make:seed, and dry-runs can run
    # even without database credentials configured.

    $environmentName = Get-JsonPropertyValue -Object $local -PropertyName 'environmentName'
    if ([string]::IsNullOrWhiteSpace($environmentName)) {
        $environmentName = [Environment]::GetEnvironmentVariable((Get-JsonPropertyValue $settings 'environmentNameEnv'))
    }
    if ([string]::IsNullOrWhiteSpace($environmentName)) {
        $environmentName = $env:USERNAME
        if ([string]::IsNullOrWhiteSpace($environmentName)) { $environmentName = 'local' }
    }

    $assemblyPath = Get-JsonPropertyValue -Object $local -PropertyName 'assemblyPath'
    if ([string]::IsNullOrWhiteSpace($assemblyPath)) {
        $assemblyPath = [Environment]::GetEnvironmentVariable((Get-JsonPropertyValue $settings.mysql 'assemblyPathEnv'))
    }

    $dbOverrides = Get-JsonPropertyValue -Object $local -PropertyName 'databases'
    $importOverrides = Get-JsonPropertyValue -Object $local -PropertyName 'imports'

    $databases = @()
    foreach ($db in $settings.databases) {
        $logicalName = $db.logicalName
        $localName = Get-JsonPropertyValue -Object $dbOverrides -PropertyName $logicalName
        $resolvedName = if ($localName) { $localName } else {
            $envName = [Environment]::GetEnvironmentVariable($db.nameEnv)
            if ($envName) { $envName } else { $db.defaultName }
        }

        $localImport = Get-JsonPropertyValue -Object $importOverrides -PropertyName $logicalName
        $importPath = if ($localImport) { $localImport } else {
            if ([string]::IsNullOrWhiteSpace($db.importRelativePath)) { $null } else { Join-Path $ProjectRoot $db.importRelativePath }
        }

        $databases += [pscustomobject]@{
            LogicalName = $logicalName
            ResolvedName = $resolvedName
            NameEnv = $db.nameEnv
            CreateOrder = [int]$db.createOrder
            ImportPath = $importPath
            ValidationQueries = $db.validationQueries
        }
    }

    [pscustomobject]@{
        ProjectRoot = $ProjectRoot
        DatabaseRoot = $bundle.DatabaseRoot
        ProjectName = $settings.projectName
        Metadata = $settings.metadata
        AssemblyPath = $assemblyPath
        EnvironmentName = $environmentName
        Server = $server
        Databases = $databases
        LocalSettingsPath = $bundle.LocalSettingsPath
    }
}

function Get-SelectedDatabases {
    param(
        [Parameter(Mandatory = $true)] $Runtime,
        [string[]] $Only
    )

    if ($null -eq $Only -or $Only.Count -eq 0) {
        return $Runtime.Databases | Sort-Object CreateOrder, LogicalName
    }

    $selected = @()
    foreach ($name in $Only) {
        $match = $Runtime.Databases | Where-Object { $_.LogicalName -eq $name }
        if ($null -eq $match) {
            throw "Unknown logical database '$name'. Valid values: $($Runtime.Databases.LogicalName -join ', ')"
        }
        $selected += $match
    }
    return $selected | Sort-Object CreateOrder, LogicalName
}

function Load-MySqlProvider {
    param([Parameter(Mandatory = $true)] $Runtime)

    $alreadyLoaded = [AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GetName().Name -eq 'MySql.Data' }
    if ($alreadyLoaded) { return }

    $candidatePaths = @()
    if (-not [string]::IsNullOrWhiteSpace($Runtime.AssemblyPath)) { $candidatePaths += $Runtime.AssemblyPath }
    $candidatePaths += @( 
        (Join-Path $Runtime.ProjectRoot 'Bin\MySql.Data.dll'),
        'C:\Program Files (x86)\MySQL\MySQL Connector Net 6.6.7\Assemblies\v4.0\MySql.Data.dll',
        'C:\Program Files\MySQL\MySQL Connector Net 6.6.7\Assemblies\v4.0\MySql.Data.dll'
    )

    foreach ($candidate in $candidatePaths | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique) {
        if (Test-Path -LiteralPath $candidate) {
            [void][Reflection.Assembly]::LoadFrom($candidate)
            Write-DbOk "Loaded MySql.Data from $candidate"
            return
        }
    }

    try {
        [void][System.Reflection.Assembly]::LoadWithPartialName('MySql.Data')
    }
    catch {
    }

    $loaded = [AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GetName().Name -eq 'MySql.Data' }
    if ($loaded) {
        Write-DbOk 'Loaded MySql.Data from the machine assembly cache.'
        return
    }

    throw @"
Unable to load MySql.Data for the migration runner.

Fix one of these:
1. Install MySQL Connector/NET 6.6.7 on this machine.
2. Put MySql.Data.dll in Bin/.
3. Set CD_MYSQL_ASSEMBLY_PATH to the MySql.Data.dll location.
4. Or set database/database.settings.local.json -> assemblyPath.
"@
}

function New-MySqlConnectionString {
    param(
        [Parameter(Mandatory = $true)] $Runtime,
        [string] $DatabaseName
    )

    $parts = @(
        "server=$($Runtime.Server.Host)",
        "port=$($Runtime.Server.Port)",
        "user id=$($Runtime.Server.User)",
        "password=$($Runtime.Server.Password)",
        'Allow User Variables=True',
        'Allow Zero Datetime=True',
        'Convert Zero Datetime=True',
        'Default Command Timeout=600',
        'Charset=utf8'
    )

    if (-not [string]::IsNullOrWhiteSpace($DatabaseName)) {
        $parts += "database=$DatabaseName"
    }

    if (-not [string]::IsNullOrWhiteSpace($Runtime.Server.SslMode)) {
        $parts += "SslMode=$($Runtime.Server.SslMode)"
    }

    return ($parts -join ';')
}

function Open-MySqlConnection {
    param(
        [Parameter(Mandatory = $true)] $Runtime,
        [string] $DatabaseName
    )

    if ([string]::IsNullOrWhiteSpace($Runtime.Server.Host) -or [string]::IsNullOrWhiteSpace($Runtime.Server.User)) {
        throw 'Database server runtime configuration is incomplete. Set database/database.settings.local.json or export CD_DB_HOST / CD_DB_USER / CD_DB_PASSWORD.'
    }

    Load-MySqlProvider -Runtime $Runtime
    $connectionString = New-MySqlConnectionString -Runtime $Runtime -DatabaseName $DatabaseName
    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString)
    $connection.Open()
    return $connection
}

function Invoke-MySqlScalar {
    param(
        [Parameter(Mandatory = $true)] $Connection,
        [Parameter(Mandatory = $true)][string] $Sql
    )

    $command = $Connection.CreateCommand()
    $command.CommandText = $Sql
    $command.CommandTimeout = 600
    return $command.ExecuteScalar()
}

function Invoke-MySqlNonQuery {
    param(
        [Parameter(Mandatory = $true)] $Connection,
        [Parameter(Mandatory = $true)][string] $Sql
    )

    $command = $Connection.CreateCommand()
    $command.CommandText = $Sql
    $command.CommandTimeout = 600
    [void]$command.ExecuteNonQuery()
}

function Invoke-MySqlQuery {
    param(
        [Parameter(Mandatory = $true)] $Connection,
        [Parameter(Mandatory = $true)][string] $Sql
    )

    $command = $Connection.CreateCommand()
    $command.CommandText = $Sql
    $command.CommandTimeout = 600
    $adapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($command)
    $table = New-Object System.Data.DataTable
    [void]$adapter.Fill($table)
    return $table
}

function Invoke-MySqlScriptFile {
    param(
        [Parameter(Mandatory = $true)] $Connection,
        [Parameter(Mandatory = $true)][string] $ScriptPath
    )

    $scriptText = Get-Content -LiteralPath $ScriptPath -Raw
    $scriptRunner = New-Object MySql.Data.MySqlClient.MySqlScript($Connection, $scriptText)
    [void]$scriptRunner.Execute()
}

function Ensure-MetadataTables {
    param([Parameter(Mandatory = $true)] $Connection)

    $createMigrations = @"
CREATE TABLE IF NOT EXISTS cd_schema_migrations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    migration_key VARCHAR(255) NOT NULL,
    logical_database VARCHAR(64) NOT NULL,
    checksum VARCHAR(64) NOT NULL,
    batch_no INT NOT NULL,
    applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    execution_ms INT NULL,
    applied_by VARCHAR(128) NULL,
    host_name VARCHAR(128) NULL,
    environment_name VARCHAR(128) NULL,
    project_name VARCHAR(128) NULL,
    script_path VARCHAR(500) NULL,
    UNIQUE KEY uk_cd_schema_migrations (migration_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
"@

    $createSeeds = @"
CREATE TABLE IF NOT EXISTS cd_schema_seeds (
    id INT AUTO_INCREMENT PRIMARY KEY,
    seed_key VARCHAR(255) NOT NULL,
    logical_database VARCHAR(64) NOT NULL,
    checksum VARCHAR(64) NOT NULL,
    applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    execution_ms INT NULL,
    applied_by VARCHAR(128) NULL,
    host_name VARCHAR(128) NULL,
    environment_name VARCHAR(128) NULL,
    project_name VARCHAR(128) NULL,
    script_path VARCHAR(500) NULL,
    UNIQUE KEY uk_cd_schema_seeds (seed_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
"@

    $createImports = @"
CREATE TABLE IF NOT EXISTS cd_schema_imports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    import_key VARCHAR(255) NOT NULL,
    logical_database VARCHAR(64) NOT NULL,
    checksum VARCHAR(64) NOT NULL,
    dump_path VARCHAR(500) NOT NULL,
    imported_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    imported_by VARCHAR(128) NULL,
    host_name VARCHAR(128) NULL,
    environment_name VARCHAR(128) NULL,
    project_name VARCHAR(128) NULL,
    UNIQUE KEY uk_cd_schema_imports (import_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
"@

    $createSettings = @"
CREATE TABLE IF NOT EXISTS cd_schema_settings (
    setting_key VARCHAR(191) NOT NULL PRIMARY KEY,
    setting_value TEXT NULL,
    description VARCHAR(500) NULL,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
"@

    Invoke-MySqlNonQuery -Connection $Connection -Sql $createMigrations
    Invoke-MySqlNonQuery -Connection $Connection -Sql $createSeeds
    Invoke-MySqlNonQuery -Connection $Connection -Sql $createImports
    Invoke-MySqlNonQuery -Connection $Connection -Sql $createSettings
}

function Get-FileChecksum {
    param([Parameter(Mandatory = $true)][string] $Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Parse-MigrationFileName {
    param([Parameter(Mandatory = $true)][string] $FileName)

    $match = [regex]::Match($FileName, '^(?<stamp>\d{8}_\d{6})__(?<database>[a-z0-9_]+)__(?<name>.+?)\.(?<direction>up|down)\.sql$')
    if (-not $match.Success) {
        throw "Invalid migration file name: $FileName. Expected YYYYMMDD_HHMMSS__database__name.up.sql"
    }

    [pscustomobject]@{
        Stamp = $match.Groups['stamp'].Value
        Database = $match.Groups['database'].Value
        Name = $match.Groups['name'].Value
        Direction = $match.Groups['direction'].Value
        Key = "$($match.Groups['stamp'].Value)__$($match.Groups['database'].Value)__$($match.Groups['name'].Value)"
    }
}

function Parse-SeedFileName {
    param([Parameter(Mandatory = $true)][string] $FileName)

    $match = [regex]::Match($FileName, '^(?<stamp>\d{8}_\d{6})__(?<database>[a-z0-9_]+)__(?<name>.+?)\.sql$')
    if (-not $match.Success) {
        throw "Invalid seed file name: $FileName. Expected YYYYMMDD_HHMMSS__database__name.sql"
    }

    [pscustomobject]@{
        Stamp = $match.Groups['stamp'].Value
        Database = $match.Groups['database'].Value
        Name = $match.Groups['name'].Value
        Key = "$($match.Groups['stamp'].Value)__$($match.Groups['database'].Value)__$($match.Groups['name'].Value)"
    }
}

function Get-MigrationFiles {
    param([Parameter(Mandatory = $true)] $Runtime)

    $folder = Join-Path $Runtime.DatabaseRoot 'migrations'
    if (-not (Test-Path -LiteralPath $folder)) { return @() }

    $results = @()
    Get-ChildItem -LiteralPath $folder -File -Filter '*.sql' |
        Where-Object { $_.Name -like '*.up.sql' -or $_.Name -like '*.down.sql' } |
        ForEach-Object {
            $file = $_
            try {
                $parsed = Parse-MigrationFileName -FileName $file.Name
                $results += [pscustomobject]@{
                    FullName = $file.FullName
                    Name = $file.Name
                    Parsed = $parsed
                }
            }
            catch {
                Write-DbWarn "Skipping malformed migration file: $($file.Name) -- $($_.Exception.Message)"
            }
        }
    return $results
}

function Get-SeedFiles {
    param([Parameter(Mandatory = $true)] $Runtime)

    $folder = Join-Path $Runtime.DatabaseRoot 'seeds'
    if (-not (Test-Path -LiteralPath $folder)) { return @() }

    $results = @()
    Get-ChildItem -LiteralPath $folder -File -Filter '*.sql' |
        ForEach-Object {
            $file = $_
            try {
                $parsed = Parse-SeedFileName -FileName $file.Name
                $results += [pscustomobject]@{
                    FullName = $file.FullName
                    Name = $file.Name
                    Parsed = $parsed
                }
            }
            catch {
                Write-DbWarn "Skipping malformed seed file: $($file.Name) -- $($_.Exception.Message)"
            }
        }
    return $results
}

function Get-NextBatchNumber {
    param([Parameter(Mandatory = $true)] $Connection)
    $result = Invoke-MySqlScalar -Connection $Connection -Sql 'SELECT COALESCE(MAX(batch_no), 0) + 1 FROM cd_schema_migrations;'
    return [int]$result
}

function Acquire-MigrationLock {
    param(
        [Parameter(Mandatory = $true)] $Connection,
        [Parameter(Mandatory = $true)][string] $LockName,
        [int] $TimeoutSeconds = 60
    )

    $escapedLockName = $LockName.Replace("'", "''")
    $result = Invoke-MySqlScalar -Connection $Connection -Sql "SELECT GET_LOCK('$escapedLockName', $TimeoutSeconds);"
    if ([int]$result -ne 1) {
        throw "Unable to acquire MySQL migration lock '$LockName'. Another migration process may still be running."
    }
}

function Release-MigrationLock {
    param(
        [Parameter(Mandatory = $true)] $Connection,
        [Parameter(Mandatory = $true)][string] $LockName
    )

    $escapedLockName = $LockName.Replace("'", "''")
    [void](Invoke-MySqlScalar -Connection $Connection -Sql "SELECT RELEASE_LOCK('$escapedLockName');")
}

function Get-AppliedMigrations {
    param([Parameter(Mandatory = $true)] $Connection)
    return Invoke-MySqlQuery -Connection $Connection -Sql 'SELECT migration_key, checksum, batch_no FROM cd_schema_migrations;'
}

function Get-AppliedSeeds {
    param([Parameter(Mandatory = $true)] $Connection)
    return Invoke-MySqlQuery -Connection $Connection -Sql 'SELECT seed_key, checksum FROM cd_schema_seeds;'
}

function New-MigrationTemplate {
    param(
        [Parameter(Mandatory = $true)][string] $LogicalDatabase,
        [Parameter(Mandatory = $true)][string] $Name
    )

    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $safeName = ($Name.ToLowerInvariant() -replace '[^a-z0-9]+', '_').Trim('_')
    $baseName = "$timestamp`__$LogicalDatabase`__$safeName"

    $up = @"
-- Migration: $safeName
-- Logical database: $LogicalDatabase
-- Generated: $(Get-Date -Format s)
-- Notes:
--   1. Keep this script idempotent where possible.
--   2. For large destructive changes, create a backup-first plan.
--   3. The runner selects the target database automatically.

-- Write your UP migration below.

"@

    $down = @"
-- Rollback: $safeName
-- Logical database: $LogicalDatabase
-- Generated: $(Get-Date -Format s)
-- Notes:
--   1. Every non-trivial migration should have a rollback path.
--   2. If rollback is unsafe, document the manual recovery process here.

-- Write your DOWN migration below.

"@

    [pscustomobject]@{
        UpFile = "$baseName.up.sql"
        DownFile = "$baseName.down.sql"
        UpContent = $up
        DownContent = $down
    }
}

function New-SeedTemplate {
    param(
        [Parameter(Mandatory = $true)][string] $LogicalDatabase,
        [Parameter(Mandatory = $true)][string] $Name
    )

    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $safeName = ($Name.ToLowerInvariant() -replace '[^a-z0-9]+', '_').Trim('_')
    $fileName = "$timestamp`__$LogicalDatabase`__$safeName.sql"
    $content = @"
-- Seed: $safeName
-- Logical database: $LogicalDatabase
-- Generated: $(Get-Date -Format s)
-- Seed rules:
--   1. Make seeds idempotent.
--   2. Prefer INSERT ... ON DUPLICATE KEY UPDATE.
--   3. Seed only deterministic shared data.

-- Write your seed script below.

"@

    [pscustomobject]@{
        File = $fileName
        Content = $content
    }
}

function New-DatabaseMigration {
    param(
        [Parameter(Mandatory = $true)] $Runtime,
        [Parameter(Mandatory = $true)][string] $LogicalDatabase,
        [Parameter(Mandatory = $true)][string] $Name
    )

    $template = New-MigrationTemplate -LogicalDatabase $LogicalDatabase -Name $Name
    $migrationFolder = Join-Path $Runtime.DatabaseRoot 'migrations'
    $upPath = Join-Path $migrationFolder $template.UpFile
    $downPath = Join-Path $migrationFolder $template.DownFile

    if ((Test-Path -LiteralPath $upPath) -or (Test-Path -LiteralPath $downPath)) {
        throw 'Migration scaffold already exists for this timestamp/name. Run the command again with a different name.'
    }

    Set-Content -LiteralPath $upPath -Value $template.UpContent -NoNewline
    Set-Content -LiteralPath $downPath -Value $template.DownContent -NoNewline
    Write-DbOk "Created migration files:`n - $upPath`n - $downPath"
}

function New-DatabaseSeed {
    param(
        [Parameter(Mandatory = $true)] $Runtime,
        [Parameter(Mandatory = $true)][string] $LogicalDatabase,
        [Parameter(Mandatory = $true)][string] $Name
    )

    $template = New-SeedTemplate -LogicalDatabase $LogicalDatabase -Name $Name
    $seedFolder = Join-Path $Runtime.DatabaseRoot 'seeds'
    $seedPath = Join-Path $seedFolder $template.File

    if (Test-Path -LiteralPath $seedPath) {
        throw 'Seed scaffold already exists for this timestamp/name. Run the command again with a different name.'
    }

    Set-Content -LiteralPath $seedPath -Value $template.Content -NoNewline
    Write-DbOk "Created seed file:`n - $seedPath"
}

function Show-DatabaseStatus {
    param(
        [Parameter(Mandatory = $true)] $Runtime,
        [string[]] $Only,
        [switch] $DryRun
    )

    $selectedDatabases = Get-SelectedDatabases -Runtime $Runtime -Only $Only
    $migrations = Get-MigrationFiles -Runtime $Runtime
    $seeds = Get-SeedFiles -Runtime $Runtime

    foreach ($db in $selectedDatabases) {
        Write-Host ''
        Write-Host "=== $($Runtime.ProjectName) :: $($db.LogicalName) => $($db.ResolvedName) ===" -ForegroundColor Magenta

        $dbMigrations = $migrations | Where-Object { $_.Parsed.Database -eq $db.LogicalName -and $_.Parsed.Direction -eq 'up' } | Sort-Object { $_.Parsed.Stamp }, { $_.Parsed.Name }
        $dbSeeds = $seeds | Where-Object { $_.Parsed.Database -eq $db.LogicalName } | Sort-Object { $_.Parsed.Stamp }, { $_.Parsed.Name }

        if ($DryRun) {
            Write-DbInfo 'Dry-run status mode: showing discovered files only.'
            foreach ($migration in $dbMigrations) { Write-Host ("  [MIGRATION] {0}" -f $migration.Name) }
            foreach ($seed in $dbSeeds) { Write-Host ("  [SEED]      {0}" -f $seed.Name) }
            continue
        }

        $connection = Open-MySqlConnection -Runtime $Runtime -DatabaseName $db.ResolvedName
        try {
            Ensure-MetadataTables -Connection $connection
            $appliedMigrations = Get-AppliedMigrations -Connection $connection
            $appliedSeeds = Get-AppliedSeeds -Connection $connection

            foreach ($migration in $dbMigrations) {
                $row = $appliedMigrations | Where-Object { $_.migration_key -eq $migration.Parsed.Key } | Select-Object -First 1
                $status = if ($row) { 'APPLIED' } else { 'PENDING' }
                $color = if ($row) { 'Green' } else { 'Yellow' }
                Write-Host ("  [{0}] {1}" -f $status, $migration.Name) -ForegroundColor $color
            }

            foreach ($seed in $dbSeeds) {
                $row = $appliedSeeds | Where-Object { $_.seed_key -eq $seed.Parsed.Key } | Select-Object -First 1
                $status = if ($row) { 'APPLIED' } else { 'PENDING' }
                $color = if ($row) { 'Green' } else { 'Yellow' }
                Write-Host ("  [{0}] {1}" -f $status, $seed.Name) -ForegroundColor $color
            }
        }
        finally {
            $connection.Dispose()
        }
    }
}

function Invoke-DatabaseMigrations {
    param(
        [Parameter(Mandatory = $true)] $Runtime,
        [string[]] $Only,
        [switch] $DryRun
    )

    $allMigrations = Get-MigrationFiles -Runtime $Runtime
    $selectedDatabases = Get-SelectedDatabases -Runtime $Runtime -Only $Only

    foreach ($db in $selectedDatabases) {
        $dbMigrations = $allMigrations |
            Where-Object { $_.Parsed.Database -eq $db.LogicalName -and $_.Parsed.Direction -eq 'up' } |
            Sort-Object { $_.Parsed.Stamp }, { $_.Parsed.Name }

        if (@($dbMigrations).Count -eq 0) {
            Write-DbWarn "No migration files found for logical database '$($db.LogicalName)'."
            continue
        }

        if ($DryRun) {
            Write-DbInfo "Dry-run migrate for $($db.LogicalName) ($($db.ResolvedName))"
            foreach ($migration in $dbMigrations) {
                Write-Host ("  -> would apply {0}" -f $migration.Name)
            }
            continue
        }

        $connection = Open-MySqlConnection -Runtime $Runtime -DatabaseName $db.ResolvedName
        $lockName = "cd_migrate_$($Runtime.ProjectName)_$($db.ResolvedName)"
        try {
            Ensure-MetadataTables -Connection $connection
            Acquire-MigrationLock -Connection $connection -LockName $lockName -TimeoutSeconds 90

            $applied = Get-AppliedMigrations -Connection $connection
            $batchNo = Get-NextBatchNumber -Connection $connection

            foreach ($migration in $dbMigrations) {
                $checksum = Get-FileChecksum -Path $migration.FullName
                $existing = $applied | Where-Object { $_.migration_key -eq $migration.Parsed.Key } | Select-Object -First 1

                if ($existing) {
                    if ($existing.checksum.ToString().ToLowerInvariant() -ne $checksum) {
                        throw "Migration '$($migration.Name)' was already applied with a different checksum. Create a new migration instead of editing an applied one."
                    }
                    Write-DbOk "Already applied: $($migration.Name)"
                    continue
                }

                $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
                Write-DbInfo "Applying migration: $($migration.Name)"
                Invoke-MySqlScriptFile -Connection $connection -ScriptPath $migration.FullName
                $stopwatch.Stop()

                $scriptPathEscaped = $migration.FullName.Replace("'", "''")
                $checksumEscaped = $checksum.Replace("'", "''")
                $keyEscaped = $migration.Parsed.Key.Replace("'", "''")
                $logicalEscaped = $db.LogicalName.Replace("'", "''")
                $envEscaped = $Runtime.EnvironmentName.Replace("'", "''")
                $projectEscaped = $Runtime.ProjectName.Replace("'", "''")
                $userEscaped = ($(if ($env:USERNAME) { $env:USERNAME } else { 'unknown-user' })).Replace("'", "''")
                $hostEscaped = ($(if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { 'unknown-host' })).Replace("'", "''")

                $insertSql = @"
INSERT INTO cd_schema_migrations
(migration_key, logical_database, checksum, batch_no, execution_ms, applied_by, host_name, environment_name, project_name, script_path)
VALUES
('$keyEscaped', '$logicalEscaped', '$checksumEscaped', $batchNo, $($stopwatch.ElapsedMilliseconds), '$userEscaped', '$hostEscaped', '$envEscaped', '$projectEscaped', '$scriptPathEscaped');
"@
                Invoke-MySqlNonQuery -Connection $connection -Sql $insertSql
                Write-DbOk "Applied migration: $($migration.Name)"
            }
        }
        finally {
            try { Release-MigrationLock -Connection $connection -LockName $lockName } catch {}
            $connection.Dispose()
        }
    }
}

function Invoke-DatabaseRollbackLast {
    param(
        [Parameter(Mandatory = $true)] $Runtime,
        [string[]] $Only,
        [switch] $DryRun
    )

    $allMigrations = Get-MigrationFiles -Runtime $Runtime
    $selectedDatabases = Get-SelectedDatabases -Runtime $Runtime -Only $Only

    foreach ($db in $selectedDatabases) {
        if ($DryRun) {
            Write-DbInfo "Dry-run rollback:last for $($db.LogicalName)"
            continue
        }

        $connection = Open-MySqlConnection -Runtime $Runtime -DatabaseName $db.ResolvedName
        $lockName = "cd_migrate_$($Runtime.ProjectName)_$($db.ResolvedName)"
        try {
            Ensure-MetadataTables -Connection $connection
            Acquire-MigrationLock -Connection $connection -LockName $lockName -TimeoutSeconds 90

            $lastBatch = Invoke-MySqlScalar -Connection $connection -Sql 'SELECT COALESCE(MAX(batch_no), 0) FROM cd_schema_migrations;'
            if ([int]$lastBatch -le 0) {
                Write-DbWarn "No applied migrations found for '$($db.LogicalName)'."
                continue
            }

            $table = Invoke-MySqlQuery -Connection $connection -Sql "SELECT migration_key FROM cd_schema_migrations WHERE batch_no = $lastBatch ORDER BY id DESC;"
            foreach ($row in $table.Rows) {
                $migrationKey = $row.migration_key
                $downScript = $allMigrations | Where-Object { $_.Parsed.Key -eq $migrationKey -and $_.Parsed.Direction -eq 'down' } | Select-Object -First 1
                if ($null -eq $downScript) {
                    throw "Rollback requested, but down migration is missing for '$migrationKey'."
                }

                Write-DbInfo "Rolling back migration: $($downScript.Name)"
                Invoke-MySqlScriptFile -Connection $connection -ScriptPath $downScript.FullName
                $escapedKey = $migrationKey.Replace("'", "''")
                Invoke-MySqlNonQuery -Connection $connection -Sql "DELETE FROM cd_schema_migrations WHERE migration_key = '$escapedKey';"
                Write-DbOk "Rolled back: $migrationKey"
            }
        }
        finally {
            try { Release-MigrationLock -Connection $connection -LockName $lockName } catch {}
            $connection.Dispose()
        }
    }
}

function Invoke-DatabaseSeeds {
    param(
        [Parameter(Mandatory = $true)] $Runtime,
        [string[]] $Only,
        [switch] $DryRun
    )

    $allSeeds = Get-SeedFiles -Runtime $Runtime
    $selectedDatabases = Get-SelectedDatabases -Runtime $Runtime -Only $Only

    foreach ($db in $selectedDatabases) {
        $dbSeeds = $allSeeds | Where-Object { $_.Parsed.Database -eq $db.LogicalName } | Sort-Object { $_.Parsed.Stamp }, { $_.Parsed.Name }
        if (@($dbSeeds).Count -eq 0) {
            Write-DbWarn "No seed files found for logical database '$($db.LogicalName)'."
            continue
        }

        if ($DryRun) {
            Write-DbInfo "Dry-run seed for $($db.LogicalName) ($($db.ResolvedName))"
            foreach ($seed in $dbSeeds) {
                Write-Host ("  -> would apply {0}" -f $seed.Name)
            }
            continue
        }

        $connection = Open-MySqlConnection -Runtime $Runtime -DatabaseName $db.ResolvedName
        $lockName = "cd_seed_$($Runtime.ProjectName)_$($db.ResolvedName)"
        try {
            Ensure-MetadataTables -Connection $connection
            Acquire-MigrationLock -Connection $connection -LockName $lockName -TimeoutSeconds 90

            $applied = Get-AppliedSeeds -Connection $connection

            foreach ($seed in $dbSeeds) {
                $checksum = Get-FileChecksum -Path $seed.FullName
                $existing = $applied | Where-Object { $_.seed_key -eq $seed.Parsed.Key } | Select-Object -First 1
                if ($existing) {
                    if ($existing.checksum.ToString().ToLowerInvariant() -ne $checksum) {
                        throw "Seed '$($seed.Name)' was already applied with a different checksum. Create a new seed file instead of editing an applied one."
                    }
                    Write-DbOk "Already applied: $($seed.Name)"
                    continue
                }

                $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
                Write-DbInfo "Applying seed: $($seed.Name)"
                Invoke-MySqlScriptFile -Connection $connection -ScriptPath $seed.FullName
                $stopwatch.Stop()

                $scriptPathEscaped = $seed.FullName.Replace("'", "''")
                $checksumEscaped = $checksum.Replace("'", "''")
                $keyEscaped = $seed.Parsed.Key.Replace("'", "''")
                $logicalEscaped = $db.LogicalName.Replace("'", "''")
                $envEscaped = $Runtime.EnvironmentName.Replace("'", "''")
                $projectEscaped = $Runtime.ProjectName.Replace("'", "''")
                $userEscaped = ($(if ($env:USERNAME) { $env:USERNAME } else { 'unknown-user' })).Replace("'", "''")
                $hostEscaped = ($(if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { 'unknown-host' })).Replace("'", "''")

                $insertSql = @"
INSERT INTO cd_schema_seeds
(seed_key, logical_database, checksum, execution_ms, applied_by, host_name, environment_name, project_name, script_path)
VALUES
('$keyEscaped', '$logicalEscaped', '$checksumEscaped', $($stopwatch.ElapsedMilliseconds), '$userEscaped', '$hostEscaped', '$envEscaped', '$projectEscaped', '$scriptPathEscaped');
"@
                Invoke-MySqlNonQuery -Connection $connection -Sql $insertSql
                Write-DbOk "Applied seed: $($seed.Name)"
            }
        }
        finally {
            try { Release-MigrationLock -Connection $connection -LockName $lockName } catch {}
            $connection.Dispose()
        }
    }
}

function Initialize-DatabaseEnvironment {
    param(
        [Parameter(Mandatory = $true)] $Runtime,
        [string[]] $Only,
        [switch] $CreateDatabases,
        [switch] $ImportDumps,
        [switch] $ForceImport,
        [switch] $RunMigrations,
        [switch] $RunSeeds,
        [switch] $DryRun
    )

    $selectedDatabases = Get-SelectedDatabases -Runtime $Runtime -Only $Only

    if ($DryRun) {
        Write-DbInfo "Dry-run init for $($Runtime.ProjectName) / environment '$($Runtime.EnvironmentName)'"
        foreach ($db in $selectedDatabases) {
            Write-Host ("  -> database {0} maps to {1}" -f $db.LogicalName, $db.ResolvedName)
            if ($CreateDatabases) { Write-Host '     create database if missing' }
            if ($ImportDumps) {
                if ($db.ImportPath) { Write-Host ("     import dump if present: {0}" -f $db.ImportPath) }
                else { Write-Host '     no import path configured' }
            }
        }
        if ($RunMigrations) { Invoke-DatabaseMigrations -Runtime $Runtime -Only $Only -DryRun }
        if ($RunSeeds) { Invoke-DatabaseSeeds -Runtime $Runtime -Only $Only -DryRun }
        return
    }

    $serverConnection = Open-MySqlConnection -Runtime $Runtime -DatabaseName $null
    try {
        foreach ($db in $selectedDatabases) {
            if ($CreateDatabases) {
                Write-DbInfo "Ensuring database exists: $($db.ResolvedName)"
                $createDbSql = "CREATE DATABASE IF NOT EXISTS ``$($db.ResolvedName)`` CHARACTER SET utf8 COLLATE utf8_general_ci;"
                Invoke-MySqlNonQuery -Connection $serverConnection -Sql $createDbSql
                Write-DbOk "Database ready: $($db.ResolvedName)"
            }

            if ($ImportDumps -and -not [string]::IsNullOrWhiteSpace($db.ImportPath) -and (Test-Path -LiteralPath $db.ImportPath)) {
                $dbConnection = Open-MySqlConnection -Runtime $Runtime -DatabaseName $db.ResolvedName
                try {
                    Ensure-MetadataTables -Connection $dbConnection
                    $checksum = Get-FileChecksum -Path $db.ImportPath
                    $importKey = "dump::$($db.LogicalName)::$checksum"
                    $existing = Invoke-MySqlScalar -Connection $dbConnection -Sql "SELECT COUNT(*) FROM cd_schema_imports WHERE import_key = '$($importKey.Replace("'", "''"))';"
                    $tableCount = Invoke-MySqlScalar -Connection $dbConnection -Sql "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name NOT LIKE 'cd_schema_%';"

                    if ([int]$existing -gt 0) {
                        Write-DbOk "Dump already registered for $($db.LogicalName): $($db.ImportPath)"
                    }
                    elseif ([int]$tableCount -gt 0 -and -not $ForceImport) {
                        Write-DbWarn "Skipping import for $($db.LogicalName) because user tables already exist. Use -ForceImport to override deliberately."
                    }
                    else {
                        Write-DbInfo "Importing dump for $($db.LogicalName): $($db.ImportPath)"
                        Invoke-MySqlScriptFile -Connection $dbConnection -ScriptPath $db.ImportPath
                        $escapedImportKey = $importKey.Replace("'", "''")
                        $escapedChecksum = $checksum.Replace("'", "''")
                        $escapedPath = $db.ImportPath.Replace("'", "''")
                        $escapedLogical = $db.LogicalName.Replace("'", "''")
                        $escapedEnv = $Runtime.EnvironmentName.Replace("'", "''")
                        $escapedProject = $Runtime.ProjectName.Replace("'", "''")
                        $escapedUser = ($(if ($env:USERNAME) { $env:USERNAME } else { 'unknown-user' })).Replace("'", "''")
                        $escapedHost = ($(if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { 'unknown-host' })).Replace("'", "''")

                        $sql = @"
INSERT INTO cd_schema_imports
(import_key, logical_database, checksum, dump_path, imported_by, host_name, environment_name, project_name)
VALUES
('$escapedImportKey', '$escapedLogical', '$escapedChecksum', '$escapedPath', '$escapedUser', '$escapedHost', '$escapedEnv', '$escapedProject');
"@
                        Invoke-MySqlNonQuery -Connection $dbConnection -Sql $sql
                        Write-DbOk "Imported dump successfully for $($db.LogicalName)"
                    }
                }
                finally {
                    $dbConnection.Dispose()
                }
            }
        }
    }
    finally {
        $serverConnection.Dispose()
    }

    if ($RunMigrations) { Invoke-DatabaseMigrations -Runtime $Runtime -Only $Only }
    if ($RunSeeds) { Invoke-DatabaseSeeds -Runtime $Runtime -Only $Only }
}

function Test-DatabasePipeline {
    param(
        [Parameter(Mandatory = $true)] $Runtime,
        [string[]] $Only,
        [switch] $DryRun
    )

    $selectedDatabases = Get-SelectedDatabases -Runtime $Runtime -Only $Only

    foreach ($db in $selectedDatabases) {
        Write-Host ''
        Write-Host "Validating $($db.LogicalName) => $($db.ResolvedName)" -ForegroundColor Magenta

        if ($DryRun) {
            foreach ($query in $db.ValidationQueries) {
                Write-Host ("  -> would run validation query: {0}" -f $query.name)
            }
            continue
        }

        $connection = Open-MySqlConnection -Runtime $Runtime -DatabaseName $db.ResolvedName
        try {
            Ensure-MetadataTables -Connection $connection
            foreach ($query in $db.ValidationQueries) {
                $table = Invoke-MySqlQuery -Connection $connection -Sql $query.sql
                $rowSummary = if ($table.Rows.Count -gt 0) {
                    ($table.Rows[0].ItemArray | ForEach-Object { if ($null -eq $_) { 'NULL' } else { $_.ToString() } }) -join ', '
                } else {
                    'no rows returned'
                }
                Write-DbOk "$($query.name): $rowSummary"
            }
        }
        finally {
            $connection.Dispose()
        }
    }
}

Export-ModuleMember -Function Get-DatabaseProjectRoot, Resolve-DatabaseRuntime, New-DatabaseMigration, New-DatabaseSeed, Show-DatabaseStatus, Invoke-DatabaseMigrations, Invoke-DatabaseRollbackLast, Invoke-DatabaseSeeds, Initialize-DatabaseEnvironment, Test-DatabasePipeline
