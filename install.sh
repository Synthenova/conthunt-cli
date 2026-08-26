#!/bin/sh
set -eu

repo=Synthenova/conthunt-cli
version=${CONTHUNT_VERSION:-}
channel=${CONTHUNT_CHANNEL:-stable}
install_dir=${CONTHUNT_INSTALL_DIR:-"$HOME/.local/bin"}

case "$(uname -s)" in
  Darwin) os=darwin ;;
  Linux) os=linux ;;
  *) echo "ContHunt supports macOS and Linux with this installer." >&2; exit 1 ;;
esac

case "$(uname -m)" in
  arm64|aarch64) arch=arm64 ;;
  x86_64|amd64) arch=x86_64 ;;
  *) echo "Unsupported CPU architecture: $(uname -m)" >&2; exit 1 ;;
esac

if [ -z "$version" ]; then
  case "$channel" in
    stable)
      version=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" |
        sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
      ;;
    dev)
      version=$(curl -fsSL "https://api.github.com/repos/$repo/releases?per_page=100" |
        tr ',' '\n' |
        awk '
          /"tag_name"[[:space:]]*:/ {
            draft=0
            tag=$0
            sub(/^.*"tag_name"[[:space:]]*:[[:space:]]*"/, "", tag)
            sub(/".*$/, "", tag)
          }
          /"draft"[[:space:]]*:[[:space:]]*true/ { draft=1 }
          /"prerelease"[[:space:]]*:[[:space:]]*true/ && tag != "" && !draft { print tag; exit }
        ')
      ;;
    *) echo "CONTHUNT_CHANNEL must be stable or dev." >&2; exit 1 ;;
  esac
  [ -n "$version" ] || { echo "Could not resolve the latest ContHunt $channel release." >&2; exit 1; }
fi

archive="conthunt_${os}_${arch}.tar.gz"
base_url="https://github.com/$repo/releases/download/$version"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

curl -fsSL "$base_url/$archive" -o "$tmp/$archive"
curl -fsSL "$base_url/checksums.txt" -o "$tmp/checksums.txt"

grep "  $archive\$" "$tmp/checksums.txt" > "$tmp/archive.sha256" || {
  echo "Release checksum is missing for $archive." >&2
  exit 1
}

if command -v sha256sum >/dev/null 2>&1; then
  (cd "$tmp" && sha256sum -c archive.sha256)
else
  (cd "$tmp" && shasum -a 256 -c archive.sha256)
fi

tar -xzf "$tmp/$archive" -C "$tmp"
mkdir -p "$install_dir"
install -m 0755 "$tmp/conthunt" "$install_dir/conthunt"

"$install_dir/conthunt" --version
printf 'Installed ContHunt to %s/conthunt\n' "$install_dir"

case ":$PATH:" in
  *":$install_dir:"*) ;;
  *) printf 'Add %s to PATH before running conthunt.\n' "$install_dir" ;;
esac
