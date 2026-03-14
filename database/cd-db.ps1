[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $Command = 'help',

    [Parameter(Position = 1)]
    [string] $Name,

    [string[]] $Database,
    [switch] $DryRun,
    [switch] $CreateDatabases,
    [switch] $ImportDumps,
    [switch] $ForceImport,
    [switch] $RunSeeds,
    [switch] $RunValidation,
    [string] $StartPath = $PSScriptRoot
)

$modulePath = Join-Path $PSScriptRoot 'DatabaseTools.psm1'
Import-Module $modulePath -Force

function Show-Help {
    Write-Host @"
Campus Dynamics Database Tool

Commands:
  help
      Show this message.

  status [-Database main,portal] [-DryRun]
      Show migration/seed status.

  init [-CreateDatabases] [-ImportDumps] [-RunSeeds] [-RunValidation] [-Database ...] [-DryRun]
      Create databases, optionally import dumps, then run migrations and seeds.

  migrate [-Database main,portal] [-DryRun]
      Apply pending migrations.

  rollback:last [-Database main,portal] [-DryRun]
      Roll back the most recent migration batch.

  seed [-Database main,portal] [-DryRun]
      Apply pending seeds.

  validate [-Database main,portal] [-DryRun]
      Run validation queries configured for each logical database.

  make:migration <name> -Database <logical-database>
      Create a new migration scaffold.

  make:seed <name> -Database <logical-database>
      Create a new seed scaffold.

Examples:
  .\database\cd-db.ps1 status -DryRun
  .\database\cd-db.ps1 init -CreateDatabases -ImportDumps -RunSeeds -RunValidation
  .\database\cd-db.ps1 migrate -Database main
  .\database\cd-db.ps1 make:migration create_student_flags -Database main
  .\database\cd-db.ps1 make:seed seed_lookup_values -Database main
"@
}

# Lazy-resolve the runtime only when the command needs it.
# This ensures 'help' and 'make:*' commands work even without full DB credentials.
function Get-LazyRuntime {
    if ($null -eq $script:_runtime) {
        $root = Get-DatabaseProjectRoot -StartPath $StartPath
        $script:_runtime = Resolve-DatabaseRuntime -ProjectRoot $root
    }
    return $script:_runtime
}

function Assert-ValidLogicalDatabase {
    param([string] $DbName)
    $rt = Get-LazyRuntime
    $match = $rt.Databases | Where-Object { $_.LogicalName -eq $DbName }
    if ($null -eq $match) {
        $validNames = ($rt.Databases | ForEach-Object { $_.LogicalName }) -join ', '
        throw "Unknown logical database '$DbName'. Valid values: $validNames"
    }
}

switch ($Command.ToLowerInvariant()) {
    'help' {
        Show-Help
    }
    'status' {
        $runtime = Get-LazyRuntime
        Show-DatabaseStatus -Runtime $runtime -Only $Database -DryRun:$DryRun
    }
    'init' {
        $runtime = Get-LazyRuntime
        Initialize-DatabaseEnvironment -Runtime $runtime -Only $Database -CreateDatabases:$CreateDatabases -ImportDumps:$ImportDumps -ForceImport:$ForceImport -RunMigrations:$true -RunSeeds:$RunSeeds -DryRun:$DryRun
        if ($RunValidation) {
            Test-DatabasePipeline -Runtime $runtime -Only $Database -DryRun:$DryRun
        }
    }
    'migrate' {
        $runtime = Get-LazyRuntime
        Invoke-DatabaseMigrations -Runtime $runtime -Only $Database -DryRun:$DryRun
    }
    'rollback:last' {
        $runtime = Get-LazyRuntime
        Invoke-DatabaseRollbackLast -Runtime $runtime -Only $Database -DryRun:$DryRun
    }
    'seed' {
        $runtime = Get-LazyRuntime
        Invoke-DatabaseSeeds -Runtime $runtime -Only $Database -DryRun:$DryRun
    }
    'validate' {
        $runtime = Get-LazyRuntime
        Test-DatabasePipeline -Runtime $runtime -Only $Database -DryRun:$DryRun
    }
    'make:migration' {
        if ([string]::IsNullOrWhiteSpace($Name)) { throw 'Migration name is required. Example: .\database\cd-db.ps1 make:migration create_api_keys -Database main' }
        if ($null -eq $Database -or $Database.Count -ne 1) { throw 'Exactly one logical database must be supplied with -Database.' }
        Assert-ValidLogicalDatabase -DbName $Database[0]
        $runtime = Get-LazyRuntime
        New-DatabaseMigration -Runtime $runtime -LogicalDatabase $Database[0] -Name $Name
    }
    'make:seed' {
        if ([string]::IsNullOrWhiteSpace($Name)) { throw 'Seed name is required. Example: .\database\cd-db.ps1 make:seed seed_lookup_values -Database main' }
        if ($null -eq $Database -or $Database.Count -ne 1) { throw 'Exactly one logical database must be supplied with -Database.' }
        Assert-ValidLogicalDatabase -DbName $Database[0]
        $runtime = Get-LazyRuntime
        New-DatabaseSeed -Runtime $runtime -LogicalDatabase $Database[0] -Name $Name
    }
    default {
        throw "Unknown command '$Command'. Run .\database\cd-db.ps1 help"
    }
}
