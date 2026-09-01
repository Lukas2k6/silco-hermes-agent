# Repository operating instructions

This repository is the reproducible, non-secret configuration for a Windows-native Hermes Discord agent named Silco.

## Operational rules

- Never commit `%LOCALAPPDATA%\hermes\.env`, Discord bot tokens, provider credentials, OAuth files, `state.db`, logs, session transcripts, or Hermes backup archives.
- Treat `SOUL.md` as the canonical personality source. The deployed copy lives at `%LOCALAPPDATA%\hermes\SOUL.md`.
- Use `scripts/Install-Silco.ps1` to apply the tracked personality and safe settings.
- Use Hermes's own `hermes backup` and `hermes import` commands for complete state migration. Full backups contain secrets and belong in encrypted storage outside this repository.
- Do not edit the upstream checkout at `%LOCALAPPDATA%\hermes\hermes-agent`. Run `hermes update` to update upstream code.
- Keep Windows scripts non-destructive, idempotent where practical, and compatible with Windows PowerShell 5.1 and PowerShell 7.
- When changing a PowerShell script, validate it with the PowerShell parser before committing.

## Verification

Run:

```powershell
.\scripts\Verify-Silco.ps1
```

The Discord token must never be printed during verification.

