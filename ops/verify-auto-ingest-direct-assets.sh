#!/usr/bin/env bash
set -euo pipefail

SCRIPT_UNDER_TEST="/home/nech/.local/bin/notes-wiki-auto-ingest"

tmpdir="$(mktemp -d)"
cleanup() {
  if [[ -n "${server_pid:-}" ]]; then
    kill "$server_pid" >/dev/null 2>&1 || true
  fi
  rm -rf "$tmpdir"
}
trap cleanup EXIT

vault_dir="$tmpdir/vault"
state_dir="$tmpdir/state"
bin_dir="$tmpdir/bin"
http_dir="$tmpdir/http"
mkdir -p \
  "$vault_dir/raw/sources" \
  "$vault_dir/raw/assets" \
  "$vault_dir/wiki/sources" \
  "$state_dir" \
  "$bin_dir" \
  "$http_dir"

cat >"$bin_dir/codex" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"$TMP_CODEX_LOG"
exit 0
EOF
chmod +x "$bin_dir/codex"

printf 'fixture-image\n' >"$http_dir/test-image.png"

cat >"$vault_dir/raw/sources/Test Source.md" <<'EOF'
# Test Source

Remote image:

![Test image](http://127.0.0.1:18765/test-image.png)
EOF

python3 -m http.server 18765 --bind 127.0.0.1 --directory "$http_dir" >/dev/null 2>&1 &
server_pid=$!
sleep 1

export TMP_CODEX_LOG="$tmpdir/codex.log"
export VAULT_DIR="$vault_dir"
export STATE_DIR="$state_dir"
export CODEX_BIN="$bin_dir/codex"

"$SCRIPT_UNDER_TEST" enqueue
"$SCRIPT_UNDER_TEST" process

asset_path="$(find "$vault_dir/raw/assets" -type f | head -n 1)"
if [[ -z "$asset_path" ]]; then
  echo "expected downloaded asset in raw/assets"
  exit 1
fi

if ! grep -Fq "../assets/$(basename "$asset_path")" "$vault_dir/raw/sources/Test Source.md"; then
  echo "expected markdown source to be rewritten to a local asset path"
  exit 1
fi

if grep -Fq "http://127.0.0.1:18765/test-image.png" "$vault_dir/raw/sources/Test Source.md"; then
  echo "expected remote asset reference to be removed from markdown source"
  exit 1
fi

if ! find "$state_dir/processed" -type f | grep -q .; then
  echo "expected processed marker to be created"
  exit 1
fi

if ! grep -Fq "Ingest raw/sources/Test Source.md" "$TMP_CODEX_LOG"; then
  echo "expected codex ingest to run for rewritten source"
  exit 1
fi

echo "ok"
