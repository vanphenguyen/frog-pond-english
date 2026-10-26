#!/usr/bin/env bash
# Installs Flutter in Claude Code cloud sessions so analyze/test/build work.
# Does nothing on a local machine, where Flutter is installed normally.
set -euo pipefail

[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || exit 0

FLUTTER_VERSION=3.47.8
FLUTTER_DIR="$HOME/flutter"

if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  curl -sSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    | tar xJ -C "$HOME"
  git config --global --add safe.directory "$FLUTTER_DIR"
fi

if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"$FLUTTER_DIR/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"
flutter --disable-analytics >/dev/null 2>&1 || true
cd "${CLAUDE_PROJECT_DIR:-.}"
flutter pub get >/dev/null
