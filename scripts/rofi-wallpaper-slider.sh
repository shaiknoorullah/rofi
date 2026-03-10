#!/usr/bin/env bash
#
# rofi-wallpaper-slider.sh — Horizontal wallpaper browser with live preview
#
# Shows wallpaper thumbnails in a horizontal grid. Uses a re-open loop
# for live preview: Enter previews (applies wallpaper + re-opens rofi
# at the same position), Ctrl+Enter confirms, Escape reverts.
#
# Usage: rofi-wallpaper-slider.sh <category>
#   category: subdirectory name under ~/walls/

ROFI_DIR="$HOME/.config/rofi"
THEME_DIR="$ROFI_DIR/themes"
WALL_DIR="$HOME/walls"
CACHE_DIR="$HOME/.cache/rofi-wallpaper"
CATEGORY="$1"

if [[ -z "$CATEGORY" || ! -d "$WALL_DIR/$CATEGORY" ]]; then
    notify-send "Error" "Invalid category: $CATEGORY" -u critical
    exit 1
fi

CAT_DIR="$WALL_DIR/$CATEGORY"
THUMB_DIR="$CACHE_DIR/thumbs/$CATEGORY"
mkdir -p "$THUMB_DIR"

# Save current wallpaper for revert on Escape
ORIGINAL_WALL=""
if [[ -f "$HOME/.fehbg" ]]; then
    ORIGINAL_WALL=$(grep -oP "(?<='|\")\S+\.(jpg|jpeg|png|webp|bmp)(?='|\")" "$HOME/.fehbg" | head -1)
fi

# Generate thumbnails for all wallpapers in category
for img in "$CAT_DIR"/*.{jpg,jpeg,png,webp,bmp,JPG,JPEG,PNG,WEBP,BMP}; do
    [[ -f "$img" ]] || continue
    base=$(basename "$img")
    thumb="$THUMB_DIR/$base"
    if [[ ! -f "$thumb" ]]; then
        convert "$img" -resize 300x169^ -gravity center -extent 300x169 "$thumb" 2>/dev/null
    fi
done

# Build sorted entries with thumbnails
entries=""
for img in "$CAT_DIR"/*.{jpg,jpeg,png,webp,bmp,JPG,JPEG,PNG,WEBP,BMP}; do
    [[ -f "$img" ]] || continue
    base=$(basename "$img")
    thumb="$THUMB_DIR/$base"
    if [[ -f "$thumb" ]]; then
        entries+="$base\x00icon\x1f$thumb\n"
    else
        entries+="$base\n"
    fi
done

# Sort entries once into a temp file for consistent re-use
SORTED_ENTRIES=$(mktemp /tmp/rofi-wall-entries-XXXX)
echo -en "$entries" | sort -V > "$SORTED_ENTRIES"

# Live preview loop
# - Enter (kb-custom-1, exit 10): preview wallpaper + re-open at same position
# - Ctrl+Enter (kb-accept-entry, exit 0): confirm and close
# - Escape (exit 1): revert and close
selected_row=0

while true; do
    result=$(cat "$SORTED_ENTRIES" | rofi -dmenu \
        -theme "$THEME_DIR/wallpaper-slider" \
        -theme-str 'configuration {show-icons: true;}' \
        -show-icons \
        -selected-row "$selected_row" \
        -format 'i:s' \
        -kb-accept-entry "Control+Return" \
        -kb-custom-1 "Return,KP_Enter" \
        -p "$CATEGORY" \
        -mesg "Enter: preview | Ctrl+Enter: apply | Esc: revert")

    exit_code=$?

    # Parse index and filename from "index:filename" format
    row="${result%%:*}"
    name="${result#*:}"

    case $exit_code in
        10)
            # Enter = live preview
            [[ -n "$row" ]] && selected_row=$row
            if [[ -n "$name" && -f "$CAT_DIR/$name" ]]; then
                feh --bg-fill "$CAT_DIR/$name" 2>/dev/null
            fi
            ;;
        0)
            # Ctrl+Enter = confirm selection
            if [[ -n "$name" && -f "$CAT_DIR/$name" ]]; then
                feh --bg-fill "$CAT_DIR/$name"
                notify-send "Wallpaper Set" "$CATEGORY/$name" -t 3000
            fi
            break
            ;;
        *)
            # Escape = revert to original
            if [[ -n "$ORIGINAL_WALL" && -f "$ORIGINAL_WALL" ]]; then
                feh --bg-fill "$ORIGINAL_WALL"
            fi
            break
            ;;
    esac
done

# Cleanup
rm -f "$SORTED_ENTRIES"
