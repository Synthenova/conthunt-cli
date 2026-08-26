#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

mkdir -p "$tmp/fixture" "$tmp/stubs" "$tmp/home"
printf '#!/bin/sh\necho "conthunt version 1.2.3"\n' > "$tmp/fixture/conthunt"
chmod +x "$tmp/fixture/conthunt"
tar -czf "$tmp/conthunt_darwin_arm64.tar.gz" -C "$tmp/fixture" conthunt
(cd "$tmp" && shasum -a 256 conthunt_darwin_arm64.tar.gz > checksums.txt)

printf '%s\n' '#!/bin/sh' \
  'case "$1" in' \
  '  -s) printf "%s\n" Darwin ;;' \
  '  -m) printf "%s\n" arm64 ;;' \
  '  *) exit 1 ;;' \
  'esac' > "$tmp/stubs/uname"

printf '%s\n' '#!/bin/sh' \
  'url=""' \
  'output=""' \
  'while [ "$#" -gt 0 ]; do' \
  '  case "$1" in' \
  '    -o) output=$2; shift 2 ;;' \
  '    -*) shift ;;' \
  '    *) url=$1; shift ;;' \
  '  esac' \
  'done' \
  'printf "%s\n" "$url" >> "$TEST_LOG"' \
  'case "$url" in' \
  '  */main/VERSION) [ "$TEST_STABLE_VERSION" != __CURL_FAIL__ ] || exit 22; printf "%s" "$TEST_STABLE_VERSION" ;;' \
  '  */dev/VERSION) printf "%s" "$TEST_DEV_VERSION" ;;' \
  '  */checksums.txt) cp "$TEST_CHECKSUMS" "$output" ;;' \
  '  */conthunt_darwin_arm64.tar.gz) cp "$TEST_ARCHIVE" "$output" ;;' \
  '  *) echo "unexpected URL: $url" >&2; exit 1 ;;' \
  'esac' > "$tmp/stubs/curl"

chmod +x "$tmp/stubs/uname" "$tmp/stubs/curl"

run_install() {
  : > "$tmp/urls.log"
  HOME="$tmp/home" \
  PATH="$tmp/stubs:$PATH" \
  TEST_LOG="$tmp/urls.log" \
  TEST_ARCHIVE="$tmp/conthunt_darwin_arm64.tar.gz" \
  TEST_CHECKSUMS="$tmp/checksums.txt" \
  TEST_STABLE_VERSION="  v2.0.0  " \
  TEST_DEV_VERSION="v2.1.0-beta.2" \
  CONTHUNT_INSTALL_DIR="$tmp/install" \
  "$@" sh "$repo_root/install.sh" >/dev/null
  test -x "$tmp/install/conthunt"
}

run_install env -u CONTHUNT_VERSION -u CONTHUNT_CHANNEL
grep -q '/download/v2.0.0/conthunt_darwin_arm64.tar.gz$' "$tmp/urls.log"

run_install env -u CONTHUNT_VERSION CONTHUNT_CHANNEL=dev
grep -q '/download/v2.1.0-beta.2/conthunt_darwin_arm64.tar.gz$' "$tmp/urls.log"

run_install env CONTHUNT_VERSION=v1.2.3 CONTHUNT_CHANNEL=dev
grep -q '/download/v1.2.3/conthunt_darwin_arm64.tar.gz$' "$tmp/urls.log"
if grep -q 'raw.githubusercontent.com/.*/VERSION' "$tmp/urls.log"; then
  echo 'exact version unexpectedly queried a channel pointer' >&2
  exit 1
fi

if HOME="$tmp/home" \
  PATH="$tmp/stubs:$PATH" \
  TEST_LOG="$tmp/urls.log" \
  TEST_ARCHIVE="$tmp/conthunt_darwin_arm64.tar.gz" \
  TEST_CHECKSUMS="$tmp/checksums.txt" \
  TEST_STABLE_VERSION="not-a-tag" \
  TEST_DEV_VERSION="v2.1.0-beta.2" \
  CONTHUNT_INSTALL_DIR="$tmp/install" \
  sh "$repo_root/install.sh" >/dev/null 2>&1; then
  echo 'installer accepted an invalid channel tag' >&2
  exit 1
fi

if HOME="$tmp/home" \
  PATH="$tmp/stubs:$PATH" \
  TEST_LOG="$tmp/urls.log" \
  TEST_ARCHIVE="$tmp/conthunt_darwin_arm64.tar.gz" \
  TEST_CHECKSUMS="$tmp/checksums.txt" \
  TEST_STABLE_VERSION="__CURL_FAIL__" \
  TEST_DEV_VERSION="v2.1.0-beta.2" \
  CONTHUNT_INSTALL_DIR="$tmp/install" \
  sh "$repo_root/install.sh" >/dev/null 2>&1; then
  echo 'installer ignored a channel pointer network failure' >&2
  exit 1
fi

if HOME="$tmp/home" \
  PATH="$tmp/stubs:$PATH" \
  TEST_LOG="$tmp/urls.log" \
  TEST_ARCHIVE="$tmp/conthunt_darwin_arm64.tar.gz" \
  TEST_CHECKSUMS="$tmp/checksums.txt" \
  TEST_STABLE_VERSION="$(printf 'bad\nv2.0.0')" \
  TEST_DEV_VERSION="v2.1.0-beta.2" \
  CONTHUNT_INSTALL_DIR="$tmp/install" \
  sh "$repo_root/install.sh" >/dev/null 2>&1; then
  echo 'installer accepted a multi-line channel pointer' >&2
  exit 1
fi

if HOME="$tmp/home" \
  PATH="$tmp/stubs:$PATH" \
  TEST_LOG="$tmp/urls.log" \
  TEST_ARCHIVE="$tmp/conthunt_darwin_arm64.tar.gz" \
  TEST_CHECKSUMS="$tmp/checksums.txt" \
  TEST_STABLE_VERSION="" \
  TEST_DEV_VERSION="v2.1.0-beta.2" \
  CONTHUNT_INSTALL_DIR="$tmp/install" \
  sh "$repo_root/install.sh" >/dev/null 2>&1; then
  echo 'installer accepted an empty channel pointer' >&2
  exit 1
fi

if HOME="$tmp/home" \
  PATH="$tmp/stubs:$PATH" \
  TEST_LOG="$tmp/urls.log" \
  TEST_ARCHIVE="$tmp/conthunt_darwin_arm64.tar.gz" \
  TEST_CHECKSUMS="$tmp/checksums.txt" \
  TEST_STABLE_VERSION="v2.0.0" \
  TEST_DEV_VERSION="v2.1.0-beta.2" \
  CONTHUNT_INSTALL_DIR="$tmp/install" \
  CONTHUNT_VERSION='../../bad' \
  sh "$repo_root/install.sh" >/dev/null 2>&1; then
  echo 'installer accepted an invalid exact tag' >&2
  exit 1
fi

printf '%064d  conthunt_darwin_arm64.tar.gz\n' 0 > "$tmp/bad-checksums.txt"
if HOME="$tmp/home" \
  PATH="$tmp/stubs:$PATH" \
  TEST_LOG="$tmp/urls.log" \
  TEST_ARCHIVE="$tmp/conthunt_darwin_arm64.tar.gz" \
  TEST_CHECKSUMS="$tmp/bad-checksums.txt" \
  CONTHUNT_INSTALL_DIR="$tmp/install" \
  CONTHUNT_VERSION=v1.2.3 \
  sh "$repo_root/install.sh" >/dev/null 2>&1; then
  echo 'installer accepted a bad checksum' >&2
  exit 1
fi

printf 'POSIX installer tests passed\n'
