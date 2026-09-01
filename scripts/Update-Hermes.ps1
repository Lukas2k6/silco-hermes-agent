[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$command = Get-Command hermes -ErrorAction SilentlyContinue
$hermes = if ($command) { $command.Source } else { Join-Path $env:LOCALAPPDATA 'hermes\bin\hermes.exe' }
if (-not (Test-Path -LiteralPath $hermes)) {
    throw 'Hermes was not found.'
}

$statusText = (& $hermes gateway status 2>&1 | Out-String)
$gatewayWasRunning = $statusText -match 'Gateway process running|process running \(PID'

if ($gatewayWasRunning) {
    Write-Host 'Stopping the gateway so Windows can replace Hermes files...'
    & $hermes gateway stop
}

$updated = $false
try {
    Write-Host 'Updating Hermes with a full pre-update backup...'
    & $hermes update --backup
    if ($LASTEXITCODE -ne 0) {
        throw 'Hermes update failed.'
    }
    $updated = $true

    & $hermes config check
    & $hermes doctor
}
finally {
    if ($gatewayWasRunning) {
        Write-Host 'Starting the gateway again...'
        & $hermes gateway start
        if ($LASTEXITCODE -ne 0) {
            Write-Warning 'Gateway start failed. Try: schtasks /Run /TN Hermes_Gateway'
        }
    }
}

if ($updated) {
    Write-Host 'Hermes updated and checked successfully.' -ForegroundColor Green
}

