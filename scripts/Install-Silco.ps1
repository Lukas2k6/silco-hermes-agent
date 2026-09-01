[CmdletBinding()]
param(
    [string]$HermesHome,
    [switch]$RestartGateway
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Get-HermesExecutable {
    $command = Get-Command hermes -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $fallback = Join-Path $env:LOCALAPPDATA 'hermes\bin\hermes.exe'
    if (Test-Path -LiteralPath $fallback) {
        return $fallback
    }

    throw @"
Hermes is not installed or is not on PATH.
Install it from the official Windows installer, open a new PowerShell window,
and run this script again:

  iex (irm https://hermes-agent.nousresearch.com/install.ps1)
"@
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceSoul = Join-Path $repoRoot 'SOUL.md'
$hermes = Get-HermesExecutable

# Ask Hermes which home/config it is actually using. This matters when
# HERMES_HOME was customized; copying to LOCALAPPDATA would then have no effect.
if ([string]::IsNullOrWhiteSpace($HermesHome)) {
    $configPath = (& $hermes config path 2>&1 | Select-Object -Last 1 | Out-String).Trim()
    if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($configPath)) {
        $HermesHome = Split-Path -Parent $configPath
    }
    else {
        $HermesHome = Join-Path $env:LOCALAPPDATA 'hermes'
    }
}

$HermesHome = [System.IO.Path]::GetFullPath($HermesHome)
$env:HERMES_HOME = $HermesHome
$targetSoul = Join-Path $HermesHome 'SOUL.md'

if (-not (Test-Path -LiteralPath $sourceSoul)) {
    throw "Canonical SOUL.md was not found at $sourceSoul"
}

New-Item -ItemType Directory -Path $HermesHome -Force | Out-Null

if (Test-Path -LiteralPath $targetSoul) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupSoul = Join-Path $HermesHome "SOUL.md.before-silco.$stamp.bak"
    Copy-Item -LiteralPath $targetSoul -Destination $backupSoul
    Write-Host "Saved the previous personality to $backupSoul"
}

Copy-Item -LiteralPath $sourceSoul -Destination $targetSoul -Force
Write-Host "Installed Silco personality at $targetSoul"

$settings = [ordered]@{
    # A selected built-in personality is injected after SOUL.md and can make
    # the bot sound like the default character. "none" leaves SOUL.md in charge.
    'display.personality'                    = 'none'
    'discord.require_mention'                 = 'true'
    'discord.auto_thread'                     = 'false'
    'discord.typing_indicator'                = 'false'
    'discord.reactions'                       = 'true'
    'discord.history_backfill'                = 'true'
    'discord.history_backfill_limit'          = '50'
    'group_sessions_per_user'                 = 'true'
    'display.tool_progress'                   = 'new'
    'display.runtime_footer.enabled'          = 'true'
    'display.runtime_footer.fields'           = '["model","context_pct","latency"]'
    'updates.pre_update_backup'               = 'full'
}

# These gateway keys are supported by the runtime but are not yet present in
# the CLI's strict suggestion table in some Hermes releases.
$runtimeOnlyKeys = @(
    'group_sessions_per_user',
    'display.tool_progress'
)

foreach ($entry in $settings.GetEnumerator()) {
    Write-Host "Setting $($entry.Key) = $($entry.Value)"
    if ($runtimeOnlyKeys -contains $entry.Key) {
        & $hermes config set --force $entry.Key $entry.Value
    }
    else {
        & $hermes config set $entry.Key $entry.Value
    }
    if ($LASTEXITCODE -ne 0) {
        throw "Hermes rejected configuration key $($entry.Key)"
    }
}

Write-Host 'Checking Hermes configuration...'
& $hermes config check
if ($LASTEXITCODE -ne 0) {
    throw 'hermes config check reported a problem.'
}

if ($RestartGateway) {
    Write-Host 'Restarting the Hermes gateway...'
    & $hermes gateway stop
    Start-Sleep -Seconds 2
    & schtasks.exe /Run /TN Hermes_Gateway
    Start-Sleep -Seconds 3
    & $hermes gateway status --deep -l
}

Write-Host ''
Write-Host 'Silco is installed.' -ForegroundColor Green
Write-Host 'In Discord, run /personality none and then /reset once.'
Write-Host 'Credentials are intentionally not stored in this repository.'
Write-Host 'On a fresh machine, finish with:'
Write-Host '  hermes model'
Write-Host '  hermes gateway setup'
Write-Host '  hermes gateway install'
Write-Host '  hermes gateway start'
