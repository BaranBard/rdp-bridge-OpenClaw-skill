#!/usr/bin/env bash
set -euo pipefail

# Connect to a Windows RDP host using FreeRDP (xfreerdp) inside an Xvfb desktop.
# Password is taken from OPENCLAW_RDP_PASS or prompted (silent).

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_lib.sh"

HOST="${1:-}"
PORT="${2:-3389}"
USER="${3:-}"

if [[ -z "$HOST" || -z "$USER" ]]; then
  echo "Usage: rdp.connect HOST [PORT] USER" >&2
  echo "Examples:" >&2
  echo "  ./scripts/rdp.connect.sh 192.168.1.10 3389 Administrator" >&2
  exit 2
fi

# Refuse to connect if an existing session is still running.
if rdp_is_running; then
  rdp_load_state
  echo "Already connected (pid=$(cat "$PID_FILE"), ${RDP_USER:-?}@${RDP_HOST:-?}:${RDP_PORT:-?} on DISPLAY=${RDP_DISPLAY:-?})." >&2
  echo "Run: ./scripts/rdp.disconnect.sh" >&2
  exit 1
fi

PASS="${OPENCLAW_RDP_PASS:-}"
if [[ -z "$PASS" ]]; then
  # Prompt for password without echoing.
  read -r -s -p "RDP password for ${USER}@${HOST}: " PASS
  echo
fi

# Display setup
RDP_DISPLAY="$(rdp_default_display)"
RDP_WIDTH="${RDP_WIDTH:-1024}"
RDP_HEIGHT="${RDP_HEIGHT:-768}"
export DISPLAY="$RDP_DISPLAY"

# Dependencies
rdp_require_cmd xfreerdp
rdp_require_cmd xdpyinfo

rdp_ensure_x_ready

# Save state (without password)
RDP_HOST="$HOST"
RDP_PORT="$PORT"
RDP_USER="$USER"
RDP_STARTED_AT="$(date -Iseconds)"
rdp_save_state

# Launch FreeRDP.
# NOTE: FreeRDP takes password via command line (/p:), which may be visible in process listings
# to other users on the same machine. Prefer a single-user host.

CMD=(
  xfreerdp
  "/v:${HOST}:${PORT}"
  "/u:${USER}"
  "/p:${PASS}"
  "/size:${RDP_WIDTH}x${RDP_HEIGHT}"
  "/cert:ignore"
  "-clipboard"
  "+auto-reconnect"
  "/network:auto"
  "/gdi:hw"
)

# Detach but keep logs.
( setsid "${CMD[@]}" >>"$LOG_FILE" 2>&1 & echo $! > "$PID_FILE" )

sleep 0.5
if rdp_is_running; then
  echo "Connected: ${USER}@${HOST}:${PORT} on DISPLAY=$DISPLAY (pid=$(cat "$PID_FILE"))."
  echo "Log: $LOG_FILE"
else
  echo "Failed to start xfreerdp. See log: $LOG_FILE" >&2
  exit 1
fi
