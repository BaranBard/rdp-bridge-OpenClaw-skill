#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_lib.sh"

rdp_load_state
export DISPLAY="${RDP_DISPLAY:-$(rdp_default_display)}"

if ! xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; then
  echo "X display not available: DISPLAY=$DISPLAY" >&2
  exit 1
fi

if CU_SCRIPTS="$(rdp_find_computer_use_scripts)"; then
  exec "$CU_SCRIPTS/screenshot.sh"
fi

# Fallback screenshot if computer-use is absent.
rdp_require_cmd import
# Capture root window to base64 PNG (matches computer-use style)
TMP="$(mktemp --suffix=.png)"
trap 'rm -f "$TMP"' EXIT
import -window root "$TMP"
base64 -w 0 "$TMP"
