---
name: conthunt
description: Use the ContHunt CLI to find, download, analyze, organize, and research viral social content through searches, boards, insights, chat, and deep research.
---

# ContHunt CLI

Use `conthunt` as the interface to ContHunt. Prefer `--json` so IDs, status, and results remain machine-readable.

## Setup

Check for the CLI with `conthunt --version`. If it is absent, install it immediately when the user's request says to install or use ContHunt. That request already authorizes the CLI installation; do not ask for separate approval.

- macOS/Linux: `curl -fsSL https://conthunt.app/install.sh | sh`
- Windows PowerShell: `irm https://conthunt.app/install.ps1 | iex`

Run `conthunt login` when authentication is missing. Give the printed verification URL and user code to the user and wait for them to approve it. Never request, print, copy, or persist their token. In non-interactive environments, use `CONTHUNT_TOKEN` only when the user supplied it for that purpose.

If stderr reports that an update is available, finish the current operation and tell the user once that they can run `conthunt update`. Run `conthunt update --json` when the user asks to update. Never treat an update notice as command failure, and never update automatically. If `update` is an unknown command, the installed CLI predates updater support; rerun the official installer once, preserving the dev channel when the current version contains `-dev.`.

## Operating model

- Use `start` to enqueue long work and return immediately.
- Use `status` for a small, non-blocking poll.
- Use `get` for the final result; exit code 4 means it is not ready.
- Use `wait` only when the user wants the current process to remain attached.
- Preserve returned search, media, content-item, board, and chat IDs. They are inputs to later commands.
- Continue a chat or research session by sending another message to the same chat ID.
- Follow `searches[].id` from chat or research output with `conthunt search get <id> --json` when full search results are needed.
- Analysis requires a stored `media_asset_id`; do not substitute a direct social/CDN URL.
- `download file` downloads on the user's machine. Do not expose signed or origin URLs unless the user asked for a URL.

Read [references/commands.md](references/commands.md) when exact command syntax, flags, or exit codes are needed.

## Credits and billing

If the CLI returns `credits_exhausted` or says the credit limit was exceeded, stop retrying that operation. Tell the user they have run out of credits, ask them to upgrade their plan, and give them this billing link:

`https://agent.conthunt.app/app/billing/return`

Do not start more billable ContHunt work until the user confirms they have upgraded or added credits.

## Context discipline

Do not poll by repeatedly calling `get`. Poll `status`, then call `get` once the run is idle. Avoid placing raw progress events, URLs, or duplicate payloads into the working context when an ID or final result is sufficient.
