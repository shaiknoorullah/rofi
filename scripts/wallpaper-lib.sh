#!/usr/bin/env bash
#
# wallpaper-lib.sh — shared wallpaper get/set for rofi-wallpaper-slider.sh and rofilaunch.sh
#
# Wayland (Hyprland): awww (formerly swww). X11 (i3): feh.
# The last wallpaper set here is also written to $WALL_STATE, so every script
# (and a login autostart) can read the same value regardless of the backend.

WALL_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/rofi-wallpaper/current"

_wall_wayland() { [[ -n "${WAYLAND_DISPLAY:-}" ]] && command -v awww >/dev/null 2>&1; }

# Print the current wallpaper path (empty if unknown).
wall_current() {
    local p=""
    if _wall_wayland; then
        p=$(awww query 2>/dev/null | sed -n 's/.*currently displaying: image: //p' | head -1)
    fi
    if [[ -z "$p" && -f "$WALL_STATE" ]]; then
        p=$(head -1 "$WALL_STATE")
    fi
    if [[ -z "$p" && -f "$HOME/.fehbg" ]]; then
        p=$(grep -oP "(?<='|\")\S+\.(jpg|jpeg|png|webp|bmp)(?='|\")" "$HOME/.fehbg" | head -1)
    fi
    printf '%s\n' "$p"
}

# Set the wallpaper to image $1 and remember it. Returns non-zero on failure.
wall_set() {
    local img=$1
    [[ -f "$img" ]] || return 1
    if _wall_wayland; then
        awww img "$img" --transition-type grow --transition-duration 1 || return 1
    else
        feh --bg-fill "$img" || return 1
    fi
    mkdir -p "${WALL_STATE%/*}" && printf '%s\n' "$img" > "$WALL_STATE"
}
