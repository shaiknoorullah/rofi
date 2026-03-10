#!/usr/bin/env bash
#
# rofi-wallpaper-slider.sh — Horizontal wallpaper browser with live preview
#
# Uses rofi-blocks for dynamic content. As the user navigates wallpapers,
# feh applies each one in real-time. Enter persists, Escape reverts.
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
generate_thumbs() {
    for img in "$CAT_DIR"/*.{jpg,jpeg,png,webp,bmp,JPG,JPEG,PNG,WEBP,BMP}; do
        [[ -f "$img" ]] || continue
        base=$(basename "$img")
        thumb="$THUMB_DIR/$base"
        if [[ ! -f "$thumb" ]]; then
            convert "$img" -resize 300x169^ -gravity center -extent 300x169 "$thumb" 2>/dev/null
        fi
    done
}

generate_thumbs

# Create the rofi-blocks wrapper script
WRAPPER=$(mktemp /tmp/rofi-wall-XXXX.sh)
cat > "$WRAPPER" << 'WRAPEOF'
#!/usr/bin/env bash
CAT_DIR="$1"
THUMB_DIR="$2"
ORIGINAL_WALL="$3"

# Build initial JSON with all wallpapers
build_json() {
    local lines=""
    local first=true
    for img in "$CAT_DIR"/*.{jpg,jpeg,png,webp,bmp,JPG,JPEG,PNG,WEBP,BMP}; do
        [[ -f "$img" ]] || continue
        base=$(basename "$img")
        thumb="$THUMB_DIR/$base"
        icon_str=""
        [[ -f "$thumb" ]] && icon_str=",\"icon\":\"$thumb\""
        $first || lines+=","
        first=false
        lines+="{\"text\":\"$base\"$icon_str}"
    done
    echo "{\"lines\":[$lines],\"prompt\":\"$CATEGORY\",\"message\":\"Navigate: Ctrl+h/l | Enter: apply | Esc: revert\"}"
}

build_json

# Read events from rofi
while IFS= read -r line; do
    # rofi-blocks sends the selected entry name
    if [[ -n "$line" ]]; then
        # Check if this is a selection event (user pressed Enter)
        name=$(echo "$line" | jq -r '.value // .name // empty' 2>/dev/null)
        if [[ -z "$name" ]]; then
            name="$line"
        fi
        # Apply wallpaper as live preview
        full_path="$CAT_DIR/$name"
        if [[ -f "$full_path" ]]; then
            feh --bg-fill "$full_path" 2>/dev/null
        fi
    fi
done

# If we reach here without selection (Escape), revert
if [[ -n "$ORIGINAL_WALL" && -f "$ORIGINAL_WALL" ]]; then
    feh --bg-fill "$ORIGINAL_WALL" 2>/dev/null
fi
WRAPEOF
chmod +x "$WRAPPER"

# Build entries for non-blocks fallback (dmenu mode with icons)
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

# Try rofi-blocks first, fallback to dmenu
if rofi -dump-config 2>/dev/null | grep -q blocks; then
    chosen=$(rofi -modi "blocks" -show blocks \
        -blocks-wrap "$WRAPPER $CAT_DIR $THUMB_DIR $ORIGINAL_WALL" \
        -theme "$THEME_DIR/wallpaper-slider" \
        -show-icons)
else
    chosen=$(echo -en "$entries" | rofi -dmenu \
        -theme "$THEME_DIR/wallpaper-slider" \
        -p "$CATEGORY" \
        -mesg "Select wallpaper | Enter: apply | Esc: cancel")
fi

# Handle result
if [[ -n "$chosen" ]]; then
    feh --bg-fill "$CAT_DIR/$chosen"
    notify-send "Wallpaper Set" "$CATEGORY/$chosen" -t 3000
else
    # Revert on Escape
    if [[ -n "$ORIGINAL_WALL" && -f "$ORIGINAL_WALL" ]]; then
        feh --bg-fill "$ORIGINAL_WALL"
    fi
fi

# Cleanup
rm -f "$WRAPPER"
