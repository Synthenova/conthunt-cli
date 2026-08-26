# ContHunt CLI

Official binary releases and agent skill for the proprietary ContHunt CLI. The CLI source is maintained privately by Synthenova.

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

## Install the agent skill

```sh
npx skills add Synthenova/conthunt-cli --skill conthunt -g
```

The skill teaches supported coding agents to use JSON output, asynchronous job lifecycles, reusable IDs, device authentication, and safe local downloads.

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
