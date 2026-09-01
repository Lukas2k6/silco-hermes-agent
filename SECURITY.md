# Security

This repository intentionally excludes credentials and runtime data.

Never commit:

- `%LOCALAPPDATA%\hermes\.env`
- Discord bot tokens
- provider API keys or OAuth files
- `state.db`, session transcripts, logs, or pairing records
- archives produced by `hermes backup`

A Hermes backup is the correct disaster-recovery artifact, but it contains credentials. Store it in an encrypted password manager, encrypted cloud drive, or encrypted external disk—not in GitHub, even in a private repository.

If a Discord token is ever committed, remove it from Git history and immediately reset it in the Discord Developer Portal. Deleting the latest commit is not enough because the old token remains in history.

