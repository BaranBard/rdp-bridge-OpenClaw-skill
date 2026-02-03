#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_lib.sh"

rdp_load_state

if rdp_is_running; then
  pid="$(cat "$PID_FILE")"
  echo "status=connected"
  echo "pid=$pid"
  echo "host=${RDP_HOST:-}"
  echo "port=${RDP_PORT:-}"
  echo "user=${RDP_USER:-}"
  echo "display=${RDP_DISPLAY:-}"
  echo "started_at=${RDP_STARTED_AT:-}"
  exit 0
else
  echo "status=disconnected"
  if [[ -f "$STATE_FILE" ]]; then
    echo "last_host=${RDP_HOST:-}"
    echo "last_port=${RDP_PORT:-}"
    echo "last_user=${RDP_USER:-}"
    echo "last_display=${RDP_DISPLAY:-}"
    echo "last_started_at=${RDP_STARTED_AT:-}"
  fi
  exit 1
fi
