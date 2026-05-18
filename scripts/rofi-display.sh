#!/usr/bin/env bash
#
# rofi-display.sh — Multi-monitor layout manager (Wayland / Hyprland)
#
# Description:
#   Queries hyprctl for connected monitors and presents rofi menu options
#   to toggle them: disable individual monitors, enable all, mirror, or
#   restore the on-disk layout (~/.config/hypr/monitors.conf).
#
# Keybinding: $mod+Shift+m
#
# Dependencies:
#   - rofi
#   - hyprctl
#   - jq
#
set -eu

THEME="$HOME/.config/rofi/themes/simple.rasi"

# Get monitor names as an array
mapfile -t MONS < <(hyprctl monitors -j | jq -r '.[].name')
N=${#MONS[@]}

if [ "$N" -eq 0 ]; then
    notify-send "Display" "No monitors detected" -u critical
    exit 1
fi

if [ "$N" -eq 1 ]; then
    notify-send "Display" "Only one display: ${MONS[0]}" -t 3000
    exit 0
fi

# Build menu (dynamic — works for any number of monitors)
opts="󰕥  Restore from monitors.conf\n"
for m in "${MONS[@]}"; do
    opts+="󰍹  Disable: $m\n"
done
opts+="󰍹  Enable all\n"
opts+="󰍺  Mirror onto: ${MONS[0]}"

chosen=$(printf "%b" "$opts" | rofi -dmenu -theme "$THEME" -p "Display") || exit 0
[ -z "$chosen" ] && exit 0

case "$chosen" in
    *"Restore from"*)
        hyprctl reload
        notify-send "Display" "Reloaded monitor config" -t 2000
        ;;
    *"Disable:"*)
        mon=$(echo "$chosen" | sed -E 's/.*Disable: //')
        hyprctl keyword monitor "$mon,disable"
        notify-send "Display" "Disabled $mon" -t 2000
        ;;
    *"Enable all"*)
        hyprctl reload
        notify-send "Display" "All monitors enabled" -t 2000
        ;;
    *"Mirror onto"*)
        # Mirror every other monitor onto the first
        primary="${MONS[0]}"
        for m in "${MONS[@]:1}"; do
            hyprctl keyword monitor "$m,preferred,auto,1,mirror,$primary"
        done
        notify-send "Display" "Mirrored to $primary" -t 2000
        ;;
esac
