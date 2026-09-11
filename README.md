
-What this repository gives you

- `SOUL.md`: Silco's permanent Hermes identity
- direct channel replies instead of automatic thread creation
- disabled Discord typing-indicator spam
- a footer showing the model, context usage, and latency on every final Discord response
- scripts for installation, verification, updating, backup, and disaster recovery
- strict secret exclusions

-Apply to existing Hermes installation

Open PowerShell in this repository and run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\Install-Silco.ps1 -RestartGateway
.\scripts\Verify-Silco.ps1
```

The installer backs up an existing `%LOCALAPPDATA%\hermes\SOUL.md` before replacing it.

-new PC recovery

1. Install Hermes from its official Windows installer:

   ```powershell
   iex (irm https://hermes-agent.nousresearch.com/install.ps1)
   ```

2. Download this repository as a ZIP while signed in to GitHub: open the repository page, select Code → Download ZIP, and extract it. GitHub CLI is not required.

3. Open PowerShell inside the extracted folder. In File Explorer, open the folder, click the address bar, type `powershell`, and press Enter.

4. Apply the tracked personality and safe configuration:

   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   .\scripts\Install-Silco.ps1 -RestartGateway
   ```

   The installer detects Hermes's active config directory, installs `SOUL.md`
   there, and disables any built-in personality overlay. In Discord, run
   `/personality none` and then `/reset` once so an existing conversation does
   not retain the old default voice.

5. Select a model that is currently offered. Free model catalogs change, so do not hardcode an old model name:

   ```powershell
   hermes model
   ```

6. Restore Discord credentials through Hermes's interactive setup:

   ```powershell
   hermes gateway setup
   ```

7. Register and start the Windows gateway:

   ```powershell
   hermes gateway install
   hermes gateway start
   hermes gateway status --deep -l
   ```

Keep the Discord token in a password manager. If it is unavailable after a crash, reset it in the Discord Developer Portal and enter the replacement during `hermes gateway setup`.

-Full recovery with history and credentials

```powershell
.\scripts\Backup-Hermes.ps1
```

By default, backups go to `Documents\Hermes-Backups`. Move them to encrypted storage. Never copy them into this repository.

install Hermes, clone this repository, and run:

```powershell
.\scripts\Restore-From-Backup.ps1 -BackupPath "D:\Secure\silco-hermes-backup-YYYYMMDD-HHMMSS.zip"
```

Hermes's import replaces existing Hermes state, so the script stops the gateway first. The repository's current `SOUL.md` and safe settings are reapplied after import.

-Updating bot

Close Hermes Desktop and any interactive `hermes` terminal sessions, then run:

```powershell
.\scripts\Update-Hermes.ps1
```

The script records whether the gateway was running, stops it to avoid Windows file locks, runs `hermes update --backup`, checks the installation, and starts the gateway again.

-Updating Silco personality

Edit `SOUL.md`, commit and push the change, then apply it on the bot PC:

```powershell
git pull
.\scripts\Install-Silco.ps1 -RestartGateway
```

If the bot still sounds generic, verify the active installation:

```powershell
.\scripts\Verify-Silco.ps1
```

The output must show both `PASS: Silco personality matches the repository` and
`PASS: No competing Hermes personality overlay is active`.

-Live monitoring

```powershell
hermes dashboard
hermes logs agent -f
hermes logs gateway -f
```

**not cloud GPU utilization**

-Security model

