[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$BackupPath,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$resolvedBackup = (Resolve-Path -LiteralPath $BackupPath).Path
$command = Get-Command hermes -ErrorAction SilentlyContinue
$hermes = if ($command) { $command.Source } else { Join-Path $env:LOCALAPPDATA 'hermes\bin\hermes.exe' }
if (-not (Test-Path -LiteralPath $hermes)) {
    throw 'Install Hermes before restoring the backup.'
}

Write-Host 'Stopping the gateway before import...'
& $hermes gateway stop

$arguments = @('import', $resolvedBackup)
if ($Force) {
    $arguments += '--force'
}

& $hermes @arguments
if ($LASTEXITCODE -ne 0) {
    throw 'Hermes import failed. The gateway was left stopped for safety.'
}

Write-Host 'Reapplying the repository personality and safe settings...'
& (Join-Path $PSScriptRoot 'Install-Silco.ps1')

Write-Host 'Starting the gateway...'
& $hermes gateway start
if ($LASTEXITCODE -ne 0) {
    Write-Warning 'Gateway start failed. Try: schtasks /Run /TN Hermes_Gateway'
}

