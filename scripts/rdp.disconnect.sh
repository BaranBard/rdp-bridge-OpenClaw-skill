#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_lib.sh"

if rdp_is_running; then
  pid="$(cat "$PID_FILE")"
  echo "Stopping xfreerdp (pid=$pid)..." >&2
  kill "$pid" 2>/dev/null || true

  # Wait a bit then force
  for _ in {1..30}; do
    if kill -0 "$pid" 2>/dev/null; then
      sleep 0.1
    else
      break
    fi
  done
  if kill -0 "$pid" 2>/dev/null; then
    echo "Force killing (pid=$pid)..." >&2
    kill -9 "$pid" 2>/dev/null || true
  fi

  rm -f "$PID_FILE"
  echo "Disconnected." >&2
else
  echo "Not connected." >&2
  rm -f "$PID_FILE" 2>/dev/null || true
fi
