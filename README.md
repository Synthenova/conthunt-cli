# ContHunt CLI

Official binary releases, hosted MCP metadata, and agent skill for ContHunt, a social content research product for TikTok, Instagram Reels, and YouTube Shorts. The CLI and MCP source is maintained privately by Synthenova.

Cursor Marketplace reads `.cursor-plugin/` plus `mcp.json` and `assets/logo-dark.png`. The dedicated plugin pack is also at [`Synthenova/conthunt-mcp`](https://github.com/Synthenova/conthunt-mcp).

## MCP

Hosted Streamable HTTP + OAuth. No local MCP process.

```text
https://mcp.conthunt.app/
```

Codex:

```sh
codex mcp add conthunt --url https://mcp.conthunt.app/
codex mcp login conthunt
```

Claude Code:

```sh
claude mcp add --transport http conthunt https://mcp.conthunt.app/
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "conthunt": {
      "url": "https://mcp.conthunt.app/"
    }
  }
}
```

Gemini CLI:

```sh
gemini mcp add --transport http -s user conthunt https://mcp.conthunt.app/
```

Registry metadata: [`server.json`](server.json). Per-client install notes: [`MCP.md`](MCP.md).

## Agent skill

Install for Claude Code, Codex, Cursor, and other agents:

```sh
npx skills add Synthenova/conthunt-cli --skill conthunt -g
```

Then ask the agent to research a niche with ContHunt. If MCP is not connected, add `https://mcp.conthunt.app/` and sign in.

Skill source: [`skills/conthunt/SKILL.md`](https://github.com/Synthenova/conthunt-cli/tree/main/skills/conthunt).

Claude Code can also load this repository as a plugin marketplace:

```text
/plugin marketplace add Synthenova/conthunt-cli
/plugin install conthunt@conthunt
```

## Install

macOS or Linux:

```sh
curl -fsSL https://conthunt.app/install.sh | sh
```

Windows beta (PowerShell):

```powershell
irm https://conthunt.app/install.ps1 | iex
```

Install the latest development prerelease instead:

```sh
curl -fsSL https://conthunt.app/install.sh | CONTHUNT_CHANNEL=dev sh
```

```powershell
$env:CONTHUNT_CHANNEL="dev"; irm https://conthunt.app/install.ps1 | iex
```

Pin an exact release tag with `CONTHUNT_VERSION=v1.2.3`. An exact version always takes precedence over the channel. Set `CONTHUNT_INSTALL_DIR` to choose another destination. Every installer verifies the release archive against `checksums.txt` before installing it.

Then authenticate with a browser-backed device code:

```sh
conthunt login
conthunt whoami
```

The CLI checks its own release channel for updates at most once every 24 hours and prints a non-blocking notice when one is available. Updates are never installed automatically:

```sh
conthunt update
```

`conthunt update` downloads the matching release, verifies it against `checksums.txt`, and replaces the installed binary. Stable installations follow stable releases; development installations follow development prereleases.

Versions older than `v0.1.2` do not contain the update command. Re-run the installer once to reach `v0.1.2`; later releases can update themselves normally.

## Releases

Release archives and `checksums.txt` are attached to the [GitHub Releases](https://github.com/Synthenova/conthunt-cli/releases) page.

- `main` contains the stable installer and skill; stable tags are ordinary GitHub releases.
- `dev` contains prerelease changes; dev tags are GitHub prereleases and are selected with `CONTHUNT_CHANNEL=dev`.
- macOS binaries are currently unsigned. Developer ID signing and notarization must be enabled before describing them as signed.
- Windows x64 is currently a beta. Linux and macOS archives support x86_64 and arm64.

## Release maintenance

This repository intentionally contains no CLI source. Build archives in the private ContHunt repository using its `.goreleaser.yaml`, then publish the resulting archives and `checksums.txt` on the matching GitHub release here. Stable releases come from the private repository's `main` branch and publish a normal tag such as `v1.2.3`; development releases come from `dev` and publish a prerelease tag such as `v1.2.4-beta.1`. After the assets are published, release automation must update `VERSION` on that channel's branch to the new tag. Installers treat `main/VERSION` and `dev/VERSION` as the channel pointers. Keep the asset names unchanged:

```text
conthunt_darwin_arm64.tar.gz
conthunt_darwin_x86_64.tar.gz
conthunt_linux_arm64.tar.gz
conthunt_linux_x86_64.tar.gz
conthunt_windows_x86_64.zip
checksums.txt
```

Before publishing, run `tests/install_test.sh`; CI runs the same POSIX checks on macOS/Linux and the PowerShell installer checks on Windows. Update both `main` and `dev` deliberately—never merge prerelease-only installer changes into stable by tagging alone.

## License

The ContHunt CLI binary and installers are proprietary software licensed under [LICENSE.txt](LICENSE.txt). The public agent skill is licensed separately under [skills/conthunt/LICENSE](skills/conthunt/LICENSE).
