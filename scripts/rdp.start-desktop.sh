#!/usr/bin/env bash
set -euo pipefail

# Start an ad-hoc desktop (Xvfb + lightweight WM) for rdp-bridge.
# This is used when the computer-use virtual desktop is not running.

DISPLAY_ARG="${1:-:99}"
WIDTH="${RDP_WIDTH:-1024}"
HEIGHT="${RDP_HEIGHT:-768}"
DEPTH="${RDP_DEPTH:-24}"

SKILL_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_DIR="$SKILL_DIR/run"
mkdir -p "$RUN_DIR"

XVFB_PID_FILE="$RUN_DIR/xvfb.pid"
WM_PID_FILE="$RUN_DIR/wm.pid"

command -v Xvfb >/dev/null 2>&1 || { echo "Xvfb not installed (apt install xvfb)" >&2; exit 127; }
command -v openbox >/dev/null 2>&1 || command -v xfwm4 >/dev/null 2>&1 || {
  echo "Neither openbox nor xfwm4 found. Install one: apt install openbox (recommended)" >&2
  exit 127
}

# If already running, do nothing.
if xdpyinfo -display "$DISPLAY_ARG" >/dev/null 2>&1; then
  exit 0
fi

# Start Xvfb
(
  set -m
  Xvfb "$DISPLAY_ARG" \
    -screen 0 "${WIDTH}x${HEIGHT}x${DEPTH}" \
    -nolisten tcp \
    -ac \
    +extension RANDR \
    +render \
    >/dev/null 2>&1 &
  echo $! > "$XVFB_PID_FILE"
)

# Start a lightweight WM (best-effort)
export DISPLAY="$DISPLAY_ARG"
if command -v openbox >/dev/null 2>&1; then
  (openbox >/dev/null 2>&1 & echo $! > "$WM_PID_FILE")
else
  (xfwm4 --compositor=off >/dev/null 2>&1 & echo $! > "$WM_PID_FILE")
fi
