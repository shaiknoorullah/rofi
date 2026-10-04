#!/usr/bin/env bash
# Login autostart (hyprland exec-once): restore the last wallpaper picked in rofi,
# falling back to a default when nothing was saved yet.
# shellcheck source=wallpaper-lib.sh
source "$HOME/.config/rofi/scripts/wallpaper-lib.sh"
img=$(head -1 "$WALL_STATE" 2>/dev/null)
[[ -f "$img" ]] || img="$HOME/walls/catppuccin/wallhaven-zyp7jo.jpg"
wall_set "$img"
