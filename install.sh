#!/bin/sh
set -eu

repo=Synthenova/conthunt-cli
version=${CONTHUNT_VERSION:-}
channel=${CONTHUNT_CHANNEL:-stable}
install_dir=${CONTHUNT_INSTALL_DIR:-"$HOME/.local/bin"}

curl_fetch() {
  curl -fsSL --retry 3 --retry-delay 1 --connect-timeout 10 --max-time 120 "$@"
}

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
    stable) version_url="https://raw.githubusercontent.com/$repo/main/VERSION" ;;
    dev) version_url="https://raw.githubusercontent.com/$repo/dev/VERSION" ;;
    *) echo "CONTHUNT_CHANNEL must be stable or dev." >&2; exit 1 ;;
  esac
  if ! version=$(curl_fetch "$version_url"); then
    echo "Could not read the ContHunt $channel release pointer." >&2
    exit 1
  fi
fi

version=$(printf '%s' "$version" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
version_pattern='^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$'
matched_version=$(printf '%s\n' "$version" | grep -E "$version_pattern" || true)
if [ -z "$version" ] || [ "$matched_version" != "$version" ]; then
  echo "Invalid ContHunt release tag: ${version:-<empty>}." >&2
  exit 1
fi

archive="conthunt_${os}_${arch}.tar.gz"
base_url="https://github.com/$repo/releases/download/$version"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

curl_fetch "$base_url/$archive" -o "$tmp/$archive"
curl_fetch "$base_url/checksums.txt" -o "$tmp/checksums.txt"

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
