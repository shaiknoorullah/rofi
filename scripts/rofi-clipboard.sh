#!/usr/bin/env bash
#
# rofi-clipboard.sh — Clipboard history via cliphist (Wayland)
#
# Description:
#   Uses cliphist + wl-clipboard to show clipboard history in rofi.
#   On selection, the chosen entry is decoded and copied back to the
#   Wayland clipboard.
#
# Keybinding: $mod+c
#
# Dependencies:
#   - rofi
#   - cliphist
#   - wl-clipboard (provides wl-copy / wl-paste)
#
# Background daemon:
#   The cliphist watcher must be running to record clipboard history.
#   It is started from ~/.config/hypr/hyprland.conf:
#     exec-once = wl-paste --type text  --watch cliphist store
#     exec-once = wl-paste --type image --watch cliphist store
#
set -eu

THEME="$HOME/.config/rofi/themes/clipboard.rasi"

# Make sure the watcher is alive (in case Hyprland exec-once was skipped)
if ! pgrep -fa "wl-paste --type text --watch cliphist store" >/dev/null; then
    wl-paste --type text  --watch cliphist store &
    wl-paste --type image --watch cliphist store &
    sleep 0.3
fi

# Show history in rofi and decode the selection back to the clipboard.
selected=$(cliphist list | rofi -dmenu -theme "$THEME" -p '󰅍 clipboard') || exit 0
[ -z "$selected" ] && exit 0
printf '%s\n' "$selected" | cliphist decode | wl-copy
