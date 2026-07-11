#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SOURCE="$SCRIPT_DIR/codex-live-token-cost.js"
TARGET_DIR="${CODEX_PLUS_USER_SCRIPTS_DIR:-$HOME/Library/Application Support/Codex++/user_scripts}"
TARGET="$TARGET_DIR/market-codex-live-token-cost.js"

if [ ! -f "$SOURCE" ]; then
  echo "Source script not found: $SOURCE" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"
cp "$SOURCE" "$TARGET"

if command -v shasum >/dev/null 2>&1; then
  HASH_STYLE=shasum
elif command -v sha256sum >/dev/null 2>&1; then
  HASH_STYLE=sha256sum
else
  echo "Neither shasum nor sha256sum was found" >&2
  exit 1
fi

sha256_file() {
  if [ "$HASH_STYLE" = shasum ]; then
    shasum -a 256 "$1" | awk '{print $1}' | sed 's/^\\//'
  else
    sha256sum "$1" | awk '{print $1}' | sed 's/^\\//'
  fi
}

SOURCE_HASH="$(sha256_file "$SOURCE")"
TARGET_HASH="$(sha256_file "$TARGET")"

MATCH=false
if [ "$SOURCE_HASH" = "$TARGET_HASH" ]; then
  MATCH=true
fi

printf 'source=%s\n' "$SOURCE"
printf 'target=%s\n' "$TARGET"
printf 'source_sha256=%s\n' "$SOURCE_HASH"
printf 'target_sha256=%s\n' "$TARGET_HASH"
printf 'match=%s\n' "$MATCH"

if [ "$MATCH" != true ]; then
  exit 1
fi
