#!/usr/bin/env bash

set -euo pipefail

ts=$(date '+%Y%m%d-%H%M')
staging=$(mktemp -d /tmp/vaultwarden-backup.XXXXXX)
tmpdb="$staging/db-$ts.sqlite3"
archive="$staging/vaultwarden-$ts.tar.zst"
uploaded="$REMOTE_DIR/vaultwarden-$ts.tar.zst"

trap 'rm -rf "$staging"' EXIT

mountpoint -q "$REMOTE_DIR" || {
  echo "$REMOTE_DIR is not mounted" >&2
  exit 1
}

sqlite3 "$DATA_DIR/db.sqlite3" ".backup '$tmpdb'"

tar -C "$staging" "db-$ts.sqlite3" \
  -C "$DATA_DIR" --exclude='./db.sqlite3*' \
  --exclude=./icon_cache --exclude=./tmp \
  -I 'zstd -19 -T0' -cf "$archive" .

mv "$archive" "$uploaded"
