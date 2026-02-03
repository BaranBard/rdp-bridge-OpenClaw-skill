#!/usr/bin/env bash
set -euo pipefail

# rdp-bridge shared helpers

SKILL_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_DIR="$SKILL_DIR/run"
STATE_FILE="$RUN_DIR/state.env"
PID_FILE="$RUN_DIR/xfreerdp.pid"
LOG_FILE="$RUN_DIR/xfreerdp.log"

mkdir -p "$RUN_DIR"

# Load saved state if present
rdp_load_state() {
  if [[ -f "$STATE_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$STATE_FILE"
  fi
}

rdp_save_state() {
  {
    echo "RDP_HOST=${RDP_HOST:-}"
    echo "RDP_PORT=${RDP_PORT:-}"
    echo "RDP_USER=${RDP_USER:-}"
    echo "RDP_DISPLAY=${RDP_DISPLAY:-}"
    echo "RDP_WIDTH=${RDP_WIDTH:-}"
    echo "RDP_HEIGHT=${RDP_HEIGHT:-}"
    echo "RDP_STARTED_AT=${RDP_STARTED_AT:-}"
  } > "$STATE_FILE"
}

rdp_is_running() {
  if [[ -f "$PID_FILE" ]]; then
    local pid
    pid="$(cat "$PID_FILE" 2>/dev/null || true)"
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      return 0
    fi
  fi
  return 1
}

rdp_require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "Missing dependency: $cmd" >&2
    return 127
  }
}

rdp_default_display() {
  # Prefer the computer-use skill display when present.
  # computer-use documents :99, so use that as default.
  echo "${RDP_DISPLAY:-:99}"
}

rdp_find_computer_use_scripts() {
  local path="$SKILL_DIR/../computer-use/scripts"
  if [[ -d "$path" ]]; then
    echo "$path"
    return 0
  fi
  return 1
}

rdp_ensure_x_ready() {
  # Ensure an X server is available on $DISPLAY.
  # If not, start an ad-hoc Xvfb + lightweight WM owned by this skill.
  rdp_require_cmd xdpyinfo

  if xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; then
    return 0
  fi

  "$SKILL_DIR/scripts/rdp.start-desktop.sh" "$DISPLAY"

  # Wait a moment for X to come up
  for _ in {1..40}; do
    if xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.1
  done

  echo "Failed to bring up X server on DISPLAY=$DISPLAY" >&2
  return 1
}
