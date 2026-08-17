#!/usr/bin/env bash
# Apply one of ~/.config/themes/* without relying on a launcher frontend.
set -uo pipefail

theme_name=${1:?usage: apply-theme.sh THEME}
themes_dir="$HOME/.config/themes"
theme_dir="$themes_dir/$theme_name"

# Theme names are supplied by Quickshell, but validate again before touching
# any configuration files.
case "$theme_name" in
    ""|*/*|.*) exit 2 ;;
esac
[ -d "$theme_dir" ] && [ -f "$theme_dir/hyprland.lua" ] && [ -f "$theme_dir/kitty.conf" ] || exit 2

# Apply Kitty first. The remaining integrations are optional, so a failure in
# one of them must never prevent the terminal theme from changing.
printf 'include %s\n' "$theme_dir/kitty.conf" > "$HOME/.config/kitty/theme.conf"
pkill -USR1 -x kitty 2>/dev/null || true

wallpaper_base="$HOME/Pictures/wallpapers"
wallpaper=$(find "$wallpaper_base/$theme_name" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | shuf -n 1 || true)

[ -z "$wallpaper" ] || awww img "$wallpaper" --transition-type any --transition-duration 1.5 --transition-fps 90 || true

install_if_present() {
    local source=$1 destination=$2
    [ -f "$source" ] || return 0
    mkdir -p "$(dirname "$destination")"
    cp "$source" "$destination"
}

rm -f "$HOME/.config/gtk-3.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
install_if_present "$theme_dir/gtk-3.css" "$HOME/.config/gtk-3.0/gtk.css"
install_if_present "$theme_dir/gtk-4.css" "$HOME/.config/gtk-4.0/gtk.css"
command -v gsettings >/dev/null && gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark || true

case "$theme_name" in mocha) btop_theme=catppuccin.theme ;; *) btop_theme="$theme_name.theme" ;; esac
if [ -f "$HOME/.config/btop/btop.conf" ]; then
    sed -i "s|^color_theme =.*|color_theme = \"$HOME/.config/btop/themes/$btop_theme\"|" "$HOME/.config/btop/btop.conf"
fi

install_if_present "$theme_dir/tmux.conf" "$HOME/.config/tmux/theme.conf"
printf 'dofile("%s")\n' "$theme_dir/hyprland.lua" > "$HOME/.config/hypr/theme.lua"

"$HOME/.config/quickshell/scripts/build-theme.sh" || true
hyprctl reload >/dev/null || true
pgrep tmux >/dev/null && tmux source-file "$HOME/.config/tmux/tmux.conf" 2>/dev/null || true
notify-send -i "$wallpaper" "Theme Activated" "Applied $theme_name"
