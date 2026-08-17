#!/usr/bin/env bash
# Emit a theme's dynamic palette as key<TAB>value rows for ThemeService.
set -euo pipefail

theme_name=${1:?usage: read-theme-values.sh THEME}
case "$theme_name" in ""|*/*|.*) exit 2 ;; esac

source_file="$HOME/.config/themes/$theme_name/quickshell.js"
[ -f "$source_file" ] || exit 2

sed -n 's/^const \([A-Za-z][A-Za-z0-9]*\) = "\(.*\)"$/\1\t\2/p' "$source_file"
