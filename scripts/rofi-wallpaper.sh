#!/usr/bin/env bash
#
# rofi-wallpaper.sh — Wallpaper selector using feh
#
# Description:
#   Lists all image files from ~/walls/ in a rofi dmenu, displayed as
#   category/filename (e.g. "tech-terminal/old-computer.png"), and applies
#   the selected image as the desktop wallpaper using feh.
#   feh's --bg-fill mode scales the image to fill the screen while
#   preserving aspect ratio (cropping edges if necessary).
#
# Keybinding: $mod+Shift+w (defined in i3 config)
#
# Dependencies:
#   - rofi        : menu launcher (dmenu mode)
#   - feh         : lightweight image viewer, used here to set wallpaper
#   - find        : lists image files by extension
#   - notify-send : success/error notifications (typically via dunst)
#
# Usage:
#   ~/.config/rofi/scripts/rofi-wallpaper.sh
#
# Notes:
#   feh --bg-fill writes a script to ~/.fehbg that records the last-set
#   wallpaper command. The i3 config runs "exec ~/.fehbg" on startup,
#   which means the selected wallpaper automatically persists across
#   reboots and i3 restarts without any additional configuration.

# Path to the dedicated rofi theme for the wallpaper picker
THEME="$HOME/.config/rofi/themes/wallpaper.rasi"

# Directory containing wallpaper images organized in category subdirectories
WALLPAPER_DIR="$HOME/walls"

# Guard: exit early if the wallpapers directory doesn't exist. This
# prevents confusing "empty list" behavior on a new machine.
if [[ ! -d "$WALLPAPER_DIR" ]]; then
    notify-send "Error" "Wallpapers directory not found" -u critical
    exit 1
fi

# --------------------------------------------------------------------------
# List image files from all category subdirectories.
#
# -mindepth 2 : skip files in the top-level directory (README, etc.)
# -maxdepth 2 : only go one level deep into category folders
# -type f     : only regular files (skip directories and symlinks)
# -iname      : case-insensitive match for common image extensions
#
# sed strips the WALLPAPER_DIR prefix to produce "category/filename.ext"
# entries for a clean, browsable list. Pipe through sort for stable order.
# --------------------------------------------------------------------------
wallpapers=$(find "$WALLPAPER_DIR" -mindepth 2 -maxdepth 2 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) | sed "s|^$WALLPAPER_DIR/||" | sort)

# If no images were found, notify the user and exit gracefully rather
# than showing an empty rofi menu.
if [[ -z "$wallpapers" ]]; then
    notify-send "Wallpapers" "No images found in $WALLPAPER_DIR" -u normal
    exit 0
fi

chosen=$(echo "$wallpapers" | rofi -dmenu -theme "$THEME" -p "Wallpaper" -mesg "Select wallpaper  ·  $(echo "$wallpapers" | wc -l) available")

# Only act if the user made a selection (pressing Escape returns empty).
if [[ -n "$chosen" ]]; then
    # --bg-fill scales the image to fill the entire screen, cropping if the
    # aspect ratios differ. This is preferred over --bg-scale (which may
    # letterbox) or --bg-center (which may leave gaps on smaller images).
    # As a side effect, feh writes ~/.fehbg so the choice persists on restart.
    feh --bg-fill "$WALLPAPER_DIR/$chosen"
    notify-send "Wallpaper Set" "$chosen" -t 3000
fi
