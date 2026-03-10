#!/usr/bin/env bash
#
# rofilaunch.sh — Main launcher with dynamic style + wallpaper
#
# Reads style from ~/.config/rofi/style.conf, extracts current wallpaper
# from ~/.fehbg, and launches rofi with runtime overrides.
#
# Usage: rofilaunch.sh [d|w|f|r]
#   d/--drun       : Application launcher (default)
#   w/--window     : Window switcher
#   f/--filebrowser: File browser
#   r/--run        : Run command

# Kill existing rofi instance (toggle behavior)
pkill rofi && exit 0

ROFI_DIR="$HOME/.config/rofi"
THEME_DIR="$ROFI_DIR/themes"
CONF_FILE="$ROFI_DIR/style.conf"

# Read saved style preference
if [[ -f "$CONF_FILE" ]]; then
    source "$CONF_FILE"
fi
rofi_style="${rofiStyle:-style_1}"

# Determine mode
case "$1" in
    d|--drun)     r_mode="drun" ;;
    w|--window)   r_mode="window" ;;
    f|--filebrowser) r_mode="filebrowser" ;;
    r|--run)      r_mode="run" ;;
    *)            r_mode="drun" ;;
esac

# Extract current wallpaper path from feh's saved state
wall_path=""
if [[ -f "$HOME/.fehbg" ]]; then
    wall_path=$(grep -oP "(?<='|\")\S+\.(jpg|jpeg|png|webp|bmp)(?='|\")" "$HOME/.fehbg" | head -1)
fi

# Build wallpaper override (inject into the dummywall/wallbox background-image)
wall_override=""
if [[ -n "$wall_path" && -f "$wall_path" ]]; then
    wall_override="* { wall-path: url(\"$wall_path\", width); }"
fi

# Border radius from picom (read corner-radius or default to 8)
border_radius=8
if [[ -f "$HOME/.config/picom/picom.conf" ]]; then
    br=$(grep -oP 'corner-radius\s*=\s*\K[0-9]+' "$HOME/.config/picom/picom.conf" 2>/dev/null)
    [[ -n "$br" ]] && border_radius=$br
fi
elem_border=$((border_radius * 2))
r_override="window {border: 0px; border-radius: ${border_radius}px;} element {border-radius: ${elem_border}px;}"

# Font override
font_override="* {font: \"JetBrainsMono Nerd Font 10\";}"

# Icon theme override
i_override="configuration {icon-theme: \"Adwaita\";}"

rofi -show "$r_mode" \
    -show-icons \
    -theme-str "$font_override" \
    -theme-str "$i_override" \
    -theme-str "$r_override" \
    -theme-str "$wall_override" \
    -theme "$THEME_DIR/$rofi_style" &
disown
