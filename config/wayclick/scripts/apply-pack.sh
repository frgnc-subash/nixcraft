#!/usr/bin/env bash
# Switch the active wayclick sound pack and (re)start wayclick with it, so
# picking a pack always results in it actually running with that pack —
# regardless of whether it happened to be on or off before.
set -euo pipefail

pack_name=${1:?usage: apply-pack.sh PACK_NAME}
config_dir="$HOME/.config/wayclick"
soundpacks_dir="$config_dir/soundpacks"
runner="$HOME/.contained_apps/uv/wayclick/runner.py"

case "$pack_name" in
    ""|*/*|.*) exit 2 ;;
esac

[[ -f "$soundpacks_dir/$pack_name/config.json" ]] || exit 2

printf '%s' "$pack_name" >"$config_dir/.active_pack"

if pgrep -f "$runner" >/dev/null; then
    pkill -f "$runner"
    while pgrep -f "$runner" >/dev/null; do
        sleep 0.1
    done
fi

# setsid detaches into its own session/process group so it survives once
# this script (and whatever launched it) exits. Plain `background &` is
# not enough — the child stays in this script's process group and gets
# reaped along with it, and `disown` needs job control, which isn't on
# in a non-interactive script.
setsid "$config_dir/scripts/wayclick.sh" >/dev/null 2>&1 &
