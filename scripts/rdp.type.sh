#!/usr/bin/env bash
set -euo pipefail

# Delegate typing to computer-use skill on the RDP display.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_lib.sh"

TEXT="${1:-}"
if [[ -z "$TEXT" ]]; then
  echo "Usage: rdp.type \"text to type\"" >&2
  exit 2
fi

rdp_load_state
export DISPLAY="${RDP_DISPLAY:-$(rdp_default_display)}"

if ! CU_SCRIPTS="$(rdp_find_computer_use_scripts)"; then
  echo "computer-use skill not found. rdp.type delegates to skills/computer-use/scripts." >&2
  exit 1
fi
exec "$CU_SCRIPTS/type_text.sh" "$TEXT"
