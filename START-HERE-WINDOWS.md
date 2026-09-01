# Start here on the Hermes bot PC

You do not need GitHub CLI (`gh`) or Git to install the Silco configuration.

1. Download `silco-hermes-agent-ready.zip` from the Codex chat where it was provided.
2. Transfer the ZIP to the PC that actually runs Hermes.
3. Right-click the ZIP and choose **Extract All**.
4. Open the extracted `silco-hermes-agent` folder.
5. Click the File Explorer address bar, type `powershell`, and press Enter.
6. Run:

   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   .\scripts\Install-Silco.ps1 -RestartGateway
   .\scripts\Verify-Silco.ps1
   ```

7. In Discord, run `/reset` once so the next conversation starts with the new personality.

If the Windows gateway restart reports the Job Object problem, run:

```powershell
schtasks /Run /TN Hermes_Gateway
hermes gateway status --deep -l
```

The script finds Hermes at `%LOCALAPPDATA%\hermes\bin\hermes.exe` even when the `hermes` command is not on PATH.

## Back up the working bot

```powershell
.\scripts\Backup-Hermes.ps1
```

The backup contains credentials. Keep it encrypted and do not upload it to GitHub.

## Update Hermes later

Close Hermes Desktop and any open Hermes chat terminals, then run:

```powershell
.\scripts\Update-Hermes.ps1
```

To update only this repository's personality/scripts, download the newest ZIP again, extract it, and rerun `Install-Silco.ps1`.

