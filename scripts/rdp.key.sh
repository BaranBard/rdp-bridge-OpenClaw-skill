#!/usr/bin/env bash
set -euo pipefail

# Delegate key press to computer-use skill on the RDP display.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_lib.sh"

KEY="${1:-}"
if [[ -z "$KEY" ]]; then
  echo "Usage: rdp.key \"Return\" | rdp.key \"ctrl+s\" | rdp.key \"alt+F4\"" >&2
  exit 2
fi

rdp_load_state
export DISPLAY="${RDP_DISPLAY:-$(rdp_default_display)}"

if ! CU_SCRIPTS="$(rdp_find_computer_use_scripts)"; then
  echo "computer-use skill not found. rdp.key delegates to skills/computer-use/scripts." >&2
  exit 1
fi
exec "$CU_SCRIPTS/key.sh" "$KEY"
