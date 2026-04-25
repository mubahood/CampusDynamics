[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$DeployedFilePath,

    [string]$SourceFilePath = "E:\OneDrive\Campus Dynamics MRU\CampusDynamics\COOPERP\NewScreens\NewStudentInfo.aspx.cs",

    [string]$AppPoolName = "DefaultAppPool",

    [switch]$RecycleAppPool,

    [switch]$ClearAspNetTempFiles,

    [string]$AspNetTempPath = "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files"
)

$ErrorActionPreference = "Stop"

Write-Host "== CampusDynamics SetPassword redeploy ==" -ForegroundColor Cyan
Write-Host "Source : $SourceFilePath"
Write-Host "Target : $DeployedFilePath"

if (-not (Test-Path -LiteralPath $SourceFilePath)) {
    throw "Source file not found: $SourceFilePath"
}

if (-not (Test-Path -LiteralPath $DeployedFilePath)) {
    throw "Deployed file not found: $DeployedFilePath"
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupPath = "$DeployedFilePath.bak_$timestamp"

if ($PSCmdlet.ShouldProcess($DeployedFilePath, "Backup current deployed file")) {
    Copy-Item -LiteralPath $DeployedFilePath -Destination $backupPath -Force
    Write-Host "Backup created: $backupPath" -ForegroundColor Green
}

if ($PSCmdlet.ShouldProcess($DeployedFilePath, "Copy updated source file to deployed location")) {
    Copy-Item -LiteralPath $SourceFilePath -Destination $DeployedFilePath -Force
    Write-Host "Deployed updated file." -ForegroundColor Green
}

if ($RecycleAppPool) {
    if ($PSCmdlet.ShouldProcess($AppPoolName, "Recycle IIS application pool")) {
        Import-Module WebAdministration -ErrorAction Stop
        Restart-WebAppPool -Name $AppPoolName
        Write-Host "Recycled app pool: $AppPoolName" -ForegroundColor Green
    }
}

if ($ClearAspNetTempFiles) {
    if (Test-Path -LiteralPath $AspNetTempPath) {
        if ($PSCmdlet.ShouldProcess($AspNetTempPath, "Clear ASP.NET temporary files")) {
            Get-ChildItem -LiteralPath $AspNetTempPath -Force | Remove-Item -Recurse -Force
            Write-Host "Cleared ASP.NET temp files." -ForegroundColor Green
        }
    }
    else {
        Write-Warning "ASP.NET temp path not found: $AspNetTempPath"
    }
}

Write-Host "Done." -ForegroundColor Cyan
Write-Host "Verify marker by calling SetPassword and checking message/header contains SETPASSWORD_V2." -ForegroundColor Yellow
