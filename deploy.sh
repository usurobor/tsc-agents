#!/usr/bin/env bash
set -euo pipefail

# Deploy current specs into the OpenClaw runtime workspace.
# 1) Copy canonical spec files into openclaw/ runtime tree
# 2) Rsync openclaw/ into /root/.openclaw/workspace

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$ROOT_DIR/openclaw"
DEST="/root/.openclaw/workspace"

cd "$ROOT_DIR"

for name in SOUL USER USER-ROLE AGENTS ENGINEERING IDENTITY HEARTBEAT TOOLS; do
  src="spec/${name}.md"
  if [[ -f "$src" ]]; then
    cp "$src" "openclaw/${name}.md"
  fi
done

echo "Syncing $SRC -> $DEST ..."
rsync -a --delete "$SRC"/ "$DEST"/
echo "Done."
