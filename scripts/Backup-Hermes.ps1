[CmdletBinding()]
param(
    [string]$Destination = (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Hermes-Backups'),
    [switch]$Quick
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$command = Get-Command hermes -ErrorAction SilentlyContinue
$hermes = if ($command) { $command.Source } else { Join-Path $env:LOCALAPPDATA 'hermes\bin\hermes.exe' }
if (-not (Test-Path -LiteralPath $hermes)) {
    throw 'Hermes was not found.'
}

New-Item -ItemType Directory -Path $Destination -Force | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$output = Join-Path $Destination "silco-hermes-backup-$stamp.zip"

$arguments = @('backup', '--output', $output)
if ($Quick) {
    $arguments += '--quick'
    $arguments += @('--label', 'manual-silco-backup')
}

& $hermes @arguments
if ($LASTEXITCODE -ne 0) {
    throw 'Hermes backup failed.'
}

Write-Host "Backup created: $output" -ForegroundColor Green
Write-Warning 'This archive contains credentials. Keep it encrypted and never commit it to GitHub.'

