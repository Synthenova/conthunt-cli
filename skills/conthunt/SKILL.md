---
name: conthunt
description: Use the ContHunt CLI to discover and research viral social content through SearchAgent, direct searches, boards, analysis, insights, and deep research.
---

# ContHunt CLI

Use `conthunt` as the interface to ContHunt. Prefer `--json` so IDs, statuses, pagination, and results remain machine-readable.

## Setup

Check for the CLI with `conthunt --version`. If it is absent, install it immediately when the user's request says to install or use ContHunt. That request already authorizes CLI installation; do not ask separately.

- macOS/Linux: `curl -fsSL https://conthunt.app/install.sh | sh`
- Windows PowerShell: `irm https://conthunt.app/install.ps1 | iex`

Run `conthunt login` when authentication is missing. Give the verification URL and user code to the user, then wait for approval. Never request, print, copy, or persist their token. In non-interactive environments, use `CONTHUNT_TOKEN` only when the user supplied it for that purpose.

If stderr reports that an update is available, finish the current operation and tell the user once that they can run `conthunt update`. Run `conthunt update --json` only when the user asks. Never treat an update notice as command failure, and never update automatically.

## Operating model

- Use `agent-search` when the user wants the SearchAgent to explore a niche, refine probes, and choose useful searches.
- Use `search` when the user has already supplied the exact query and platform scope.
- Use `research` when the user wants evidence-backed answers across the resulting videos.
- Use `start` to enqueue long work and return immediately.
- Use `status` for a small, non-blocking poll. Use `wait` only when the user wants the process to remain attached.
- Use `get` once the status is completed. Exit code 4 means the result is not ready.
- Preserve returned run, search, media, content-item, board, and research chat IDs. They are inputs to later commands.
- Follow a SearchAgent or research result's search IDs with `conthunt search get <search-id> --json` when full video results are needed.
- Page through research videos with `research watched`; retrieve a selected video's question-aware Markdown with `research evidence`.
- Analysis requires a stored `media_asset_id`; do not substitute a direct social or CDN URL.
- `download file` downloads on the user's machine. Do not expose signed or origin URLs unless the user asks for a URL.

Read [references/commands.md](references/commands.md) for exact syntax, flags, pagination, and exit codes.

## Credits and billing

If the CLI returns `credits_exhausted` or says the credit limit was exceeded, stop retrying that operation. Tell the user they have run out of credits, ask them to upgrade, and give them this billing link:

`https://agent.conthunt.app/app/billing/return`

Do not start more billable ContHunt work until the user confirms they upgraded or added credits.

## Context discipline

Do not repeatedly call `get` while work is active. Poll `status`, then call `get` once completed. Use pagination for result collections. Keep raw progress events, signed URLs, and duplicate payloads out of the working context when IDs, compact status, or selected evidence are sufficient.
