[CmdletBinding()]
param(
    [string]$HermesHome
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$repoSoul = Join-Path $repoRoot 'SOUL.md'
$command = Get-Command hermes -ErrorAction SilentlyContinue
$hermes = if ($command) { $command.Source } else { Join-Path $env:LOCALAPPDATA 'hermes\bin\hermes.exe' }

if (-not (Test-Path -LiteralPath $hermes)) {
    throw 'FAIL: Hermes was not found.'
}

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
$installedSoul = Join-Path $HermesHome 'SOUL.md'
$envFile = Join-Path $HermesHome '.env'
Write-Host "Active Hermes home: $HermesHome"

if (-not (Test-Path -LiteralPath $installedSoul)) {
    throw "FAIL: $installedSoul does not exist. Run Install-Silco.ps1."
}

$expectedHash = (Get-FileHash -LiteralPath $repoSoul -Algorithm SHA256).Hash
$actualHash = (Get-FileHash -LiteralPath $installedSoul -Algorithm SHA256).Hash
if ($expectedHash -ne $actualHash) {
    throw 'FAIL: Installed SOUL.md differs from the repository version.'
}
Write-Host 'PASS: Silco personality matches the repository.' -ForegroundColor Green

$personality = (& $hermes config get display.personality 2>&1 | Out-String).Trim()
if ([string]::IsNullOrWhiteSpace($personality) -or $personality -match '^(none|neutral|default)$') {
    Write-Host 'PASS: No competing Hermes personality overlay is active.' -ForegroundColor Green
}
else {
    Write-Warning "Personality overlay '$personality' can override Silco. Run: hermes config set display.personality none"
}

$systemPrompt = (& $hermes config get agent.system_prompt 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($systemPrompt)) {
    Write-Warning 'agent.system_prompt is set and may compete with SOUL.md.'
}

if (Test-Path -LiteralPath $envFile) {
    $hasDiscordToken = Select-String -LiteralPath $envFile -Pattern '^DISCORD_BOT_TOKEN=.+$' -Quiet
    if ($hasDiscordToken) {
        Write-Host 'PASS: A Discord token is configured (value not displayed).' -ForegroundColor Green
    }
    else {
        Write-Warning 'Discord token is missing. Run: hermes gateway setup'
    }
}
else {
    Write-Warning 'Hermes .env is missing. Run: hermes gateway setup'
}

$model = (& $hermes config get model.default 2>&1 | Out-String).Trim()
if ($model -match 'deepseek-v4-flash-free') {
    Write-Warning 'The retired deepseek-v4-flash-free model is still selected. Run: hermes model'
}
else {
    Write-Host "Configured model: $model"
}

& $hermes config check
& $hermes gateway status --deep -l
