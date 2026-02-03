#!/usr/bin/env bash
set -euo pipefail

# Delegate click to computer-use skill on the RDP display.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_lib.sh"

X="${1:-}"
Y="${2:-}"
BUTTON="${3:-left}"
if [[ -z "$X" || -z "$Y" ]]; then
  echo "Usage: rdp.click X Y [left|right|middle|double|triple]" >&2
  exit 2
fi

rdp_load_state
export DISPLAY="${RDP_DISPLAY:-$(rdp_default_display)}"

if ! CU_SCRIPTS="$(rdp_find_computer_use_scripts)"; then
  echo "computer-use skill not found. rdp.click delegates to skills/computer-use/scripts." >&2
  exit 1
fi
exec "$CU_SCRIPTS/click.sh" "$X" "$Y" "$BUTTON"
