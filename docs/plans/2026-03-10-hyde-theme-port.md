# HyDE Rofi Theme Port — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the current fullscreen-blur rofi theme system with HyDE's 12 windowed launcher styles + launchpad, a style selector, a rofi-blocks wallpaper browser with live preview, and consolidated utility menu themes — all adapted for i3/X11.

**Architecture:** Port HyDE's self-contained `.rasi` theme files, replacing `hyprctl` calls with xrandr/feh equivalents. Each launcher style is a standalone theme that imports a shared color mapping (`theme.rasi`). A launcher script reads a saved style preference and applies runtime overrides (border radius, font, wallpaper path). Utility menus consolidate into two base themes: `clipboard.rasi` (dropdown) and `simple.rasi` (single-column).

**Tech Stack:** rofi, rofi-blocks, feh, picom, i3, bash, xrandr, ImageMagick (for thumbnail generation)

---

## Phase 1: Theme Foundation

### Task 1: Create HyDE-compatible color mapping

**Files:**
- Create: `~/.config/rofi/themes/theme.rasi`
- Keep: `~/.config/rofi/themes/catppuccin-mocha.rasi` (unchanged)

**Step 1: Create `theme.rasi`**

This maps Catppuccin Mocha colors to HyDE's variable names so all ported styles work without modification.

```rasi
/* HyDE-compatible color variable mapping
 * Maps Catppuccin Mocha palette to HyDE's expected variable names.
 * All ported HyDE styles reference these variables. */
* {
    main-bg:            #1E1E2Ee6;
    main-fg:            #CDD6F4ff;
    main-br:            #CBA6F7ff;
    main-ex:            #F5E0DCff;
    select-bg:          #B4BEFEff;
    select-fg:          #1E1E2Bff;
    separatorcolor:     transparent;
    border-color:       transparent;
}
```

**Step 2: Verify rofi can parse it**

Run: `rofi -dump-config -theme ~/.config/rofi/themes/theme.rasi 2>&1 | head -5`
Expected: No errors

**Step 3: Commit**

```bash
git add ~/.config/rofi/themes/theme.rasi
git commit -m "feat(rofi): add HyDE-compatible color mapping theme.rasi"
```

---

### Task 2: Create style.conf preference file

**Files:**
- Create: `~/.config/rofi/style.conf`

**Step 1: Create the file**

```bash
echo "rofiStyle=style_1" > ~/.config/rofi/style.conf
```

**Step 2: Commit**

```bash
git add ~/.config/rofi/style.conf
git commit -m "feat(rofi): add style preference file"
```

---

## Phase 2: Port 12 Launcher Styles + Launchpad

### Task 3: Port launcher styles 1-6

**Files:**
- Create: `~/.config/rofi/themes/style_1.rasi` through `style_6.rasi`

Port each style from the HyDE repository. For each file:

1. Fetch from `https://raw.githubusercontent.com/HyDE-Project/HyDE/main/Configs/.local/share/hyde/rofi/themes/style_N.rasi`
2. Change `@theme "~/.config/rofi/theme.rasi"` → `@theme "~/.config/rofi/themes/theme.rasi"`
3. Change `icon-theme` from `"Tela-circle-dracula"` → `"Adwaita"` (matching user's config.rasi)
4. Keep the `background-image` property on the wallpaper widget — the launcher script will override this at runtime with the current wallpaper path from `~/.fehbg`
5. Remove `// Attribute: rofilaunch,launcher` comment is fine to keep (used by style selector to find launcher themes)

**Style summary for reference:**
- style_1: Sideview — wallpaper sidebar left, list right (63x33em)
- style_2: TwinPanel — wallpaper header, 2-col list below (56x35em)
- style_3: ModeSidebar — blurred bg, mode icons + list (37x30em)
- style_4: TopPanel — wallpaper left, modes center, list right (46x30em)
- style_5: ModeGrid — 5-column icon grid + mode buttons (50x31em)
- style_6: SimpleStack — mode icons left, text list right (37x31em)

**Step 1: Fetch and adapt all 6 files**

For each style_N.rasi, fetch the raw content and apply the two substitutions above.

**Step 2: Test each loads without error**

Run for each: `rofi -show drun -theme ~/.config/rofi/themes/style_N.rasi 2>&1 | head -5`
Expected: Rofi opens with the style (dismiss with Escape)

**Step 3: Commit**

```bash
git add ~/.config/rofi/themes/style_{1..6}.rasi
git commit -m "feat(rofi): port HyDE launcher styles 1-6"
```

---

### Task 4: Port launcher styles 7-12

**Files:**
- Create: `~/.config/rofi/themes/style_7.rasi` through `style_12.rasi`

Same process as Task 3.

**Style summary:**
- style_7: ModeBar — compact horizontal bar (38x12em)
- style_8: SplitPanel — list+modes left, wallpaper right (37x30em)
- style_9: CenterStack — square wallpaper left, list right (57x30em)
- style_10: CompactPanel — narrow vertical, wallpaper header (25x40em)
- style_11: DiagonalSplit — quad wallpaper left, list right (58x30em)
- style_12: GradientView — list left, gradient wallpaper right (60x30em)

**Step 1: Fetch and adapt all 6 files**

Same substitutions as Task 3.

**Step 2: Test each**

Run for each: `rofi -show drun -theme ~/.config/rofi/themes/style_N.rasi 2>&1 | head -5`

**Step 3: Commit**

```bash
git add ~/.config/rofi/themes/style_{7..12}.rasi
git commit -m "feat(rofi): port HyDE launcher styles 7-12"
```

---

### Task 5: Port launchpad theme

**Files:**
- Create: `~/.config/rofi/themes/launchpad.rasi`

**Step 1: Fetch and adapt**

Fetch from HyDE, apply same `@theme` path fix and icon-theme change. The launchpad is a fullscreen macOS-style grid (7 cols x 5 rows, 72px icons).

**Step 2: Test**

Run: `rofi -show drun -theme ~/.config/rofi/themes/launchpad.rasi`
Expected: Fullscreen app grid

**Step 3: Commit**

```bash
git add ~/.config/rofi/themes/launchpad.rasi
git commit -m "feat(rofi): port HyDE launchpad theme"
```

---

## Phase 3: Launcher Script + Style Selector

### Task 6: Create the main launcher script

**Files:**
- Create: `~/.config/rofi/scripts/rofilaunch.sh`

This script replaces direct rofi invocations. It:
1. Reads the saved style from `~/.config/rofi/style.conf`
2. Extracts the current wallpaper path from `~/.fehbg`
3. Applies runtime overrides: wallpaper image, border radius (from picom), font
4. Launches rofi with the selected style

```bash
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
```

**Step 1: Write the script**

Create the file above at `~/.config/rofi/scripts/rofilaunch.sh`.

**Step 2: Make executable**

Run: `chmod +x ~/.config/rofi/scripts/rofilaunch.sh`

**Step 3: Test**

Run: `~/.config/rofi/scripts/rofilaunch.sh d`
Expected: Rofi opens with style_1 and current wallpaper visible in the sidebar

**Step 4: Test with different styles**

```bash
echo "rofiStyle=style_5" > ~/.config/rofi/style.conf
~/.config/rofi/scripts/rofilaunch.sh d
```
Expected: Rofi opens with style_5 (icon grid)

Reset: `echo "rofiStyle=style_1" > ~/.config/rofi/style.conf`

**Step 5: Commit**

```bash
git add ~/.config/rofi/scripts/rofilaunch.sh
git commit -m "feat(rofi): add main launcher script with dynamic style + wallpaper"
```

---

### Task 7: Generate style preview assets

**Files:**
- Create: `~/.config/rofi/themes/assets/style_1.png` through `style_12.png` + `launchpad.png`

We need preview images for the style selector. Two approaches:

**Option A (preferred):** Take screenshots of each style using `maim`

```bash
#!/usr/bin/env bash
# generate-previews.sh — Screenshot each rofi style for the selector
ASSET_DIR="$HOME/.config/rofi/themes/assets"
mkdir -p "$ASSET_DIR"

for i in $(seq 1 12); do
    echo "rofiStyle=style_$i" > ~/.config/rofi/style.conf
    ~/.config/rofi/scripts/rofilaunch.sh d &
    sleep 1.5
    maim "$ASSET_DIR/style_$i.png"
    pkill rofi
    sleep 0.5
done

# Launchpad
~/.config/rofi/scripts/rofilaunch.sh d &  # temporarily set launchpad
sleep 1.5
maim "$ASSET_DIR/launchpad.png"
pkill rofi
```

**Option B (fallback):** Download HyDE's preview assets from their repo.

**Step 1: Create assets directory and generate/download previews**

**Step 2: Verify all 13 images exist**

Run: `ls ~/.config/rofi/themes/assets/*.png | wc -l`
Expected: 13

**Step 3: Commit**

```bash
git add ~/.config/rofi/themes/assets/
git commit -m "feat(rofi): add style preview assets"
```

---

### Task 8: Port selector theme and create style selector script

**Files:**
- Create: `~/.config/rofi/themes/selector.rasi`
- Create: `~/.config/rofi/scripts/rofi-style-selector.sh`

**Step 1: Create `selector.rasi`**

Fetch from HyDE and adapt. This is a horizontal icon grid with large preview images.

The selector theme from HyDE uses:
- Full-width window
- Grid listview with large icon sizes (20em)
- Element text disabled (icon-only display)
- Horizontal layout for browsing styles visually

Apply same `@theme` path fix.

**Step 2: Create `rofi-style-selector.sh`**

```bash
#!/usr/bin/env bash
#
# rofi-style-selector.sh — Switch between rofi launcher styles
#
# Scans theme files for launcher styles, shows preview grid,
# saves selection to style.conf.

ROFI_DIR="$HOME/.config/rofi"
THEME_DIR="$ROFI_DIR/themes"
ASSET_DIR="$THEME_DIR/assets"
CONF_FILE="$ROFI_DIR/style.conf"

# Read current style
[[ -f "$CONF_FILE" ]] && source "$CONF_FILE"

# Font override
font_override='* {font: "JetBrainsMono Nerd Font 10";}'

# Get monitor width for column calculation
mon_width=$(xrandr --query | grep ' connected primary' | grep -oP '\d+(?=x)' | head -1)
mon_width=${mon_width:-1920}
col_count=$(( mon_width / 400 ))
[[ $col_count -gt 5 ]] && col_count=5

r_override="window{width:100%;}
    listview{columns:$col_count;}
    element{orientation:vertical;border-radius:16px;}
    element-icon{border-radius:12px;size:20em;}
    element-text{enabled:false;}"

# Build entries: scan for launcher-attributed themes
entries=""
for file in "$THEME_DIR"/style_*.rasi "$THEME_DIR"/launchpad.rasi; do
    [[ -f "$file" ]] || continue
    base=$(basename "$file" .rasi)
    asset="$ASSET_DIR/$base.png"
    if [[ -f "$asset" ]]; then
        entries+="$base\x00icon\x1f$asset\n"
    else
        entries+="$base\n"
    fi
done

chosen=$(echo -en "$entries" | sort -V | rofi -dmenu \
    -theme-str "$font_override" \
    -theme-str "$r_override" \
    -theme "$THEME_DIR/selector" \
    -select "$rofiStyle" \
    -p "Style")

if [[ -n "$chosen" ]]; then
    echo "rofiStyle=$chosen" > "$CONF_FILE"
    notify-send "Rofi Style" "Switched to $chosen" -t 2000 \
        -i "$ASSET_DIR/$chosen.png" 2>/dev/null
fi
```

**Step 3: Make executable**

Run: `chmod +x ~/.config/rofi/scripts/rofi-style-selector.sh`

**Step 4: Test**

Run: `~/.config/rofi/scripts/rofi-style-selector.sh`
Expected: Grid of style previews appears. Selecting one updates `style.conf`.

**Step 5: Verify selection persists**

Run: `cat ~/.config/rofi/style.conf`
Expected: `rofiStyle=<selected_style>`

**Step 6: Commit**

```bash
git add ~/.config/rofi/themes/selector.rasi ~/.config/rofi/scripts/rofi-style-selector.sh
git commit -m "feat(rofi): add style selector theme and script"
```

---

## Phase 4: Utility Menu Themes

### Task 9: Port clipboard dropdown theme

**Files:**
- Create: `~/.config/rofi/themes/clipboard.rasi` (replaces old version)

Fetch HyDE's `clipboard.rasi` and adapt. This is a dropdown-style theme used for:
clipboard, power, screenshot, media, emoji, web search, bookmarks, keybindings.

Key features:
- Windowed (not fullscreen), anchored to top-center or center
- Search bar with wallpaper header
- 11-line scrollable list
- Clean dropdown appearance

Apply `@theme` path fix and icon-theme change.

**Step 1: Fetch and adapt clipboard.rasi**

**Step 2: Test**

Run: `echo -e "test1\ntest2\ntest3" | rofi -dmenu -theme ~/.config/rofi/themes/clipboard.rasi`
Expected: Dropdown-style menu appears

**Step 3: Commit**

```bash
git add ~/.config/rofi/themes/clipboard.rasi
git commit -m "feat(rofi): port HyDE clipboard dropdown theme"
```

---

### Task 10: Create simple single-column theme

**Files:**
- Create: `~/.config/rofi/themes/simple.rasi`

For menus without a HyDE equivalent: bluetooth, display, wallpaper categories, systemd, git profile, tmux, projects, obsidian.

```rasi
/**
 * Simple single-column windowed menu
 * For utility menus without a HyDE-specific style.
 */

@theme "~/.config/rofi/themes/theme.rasi"

configuration {
    show-icons:                  false;
}

window {
    width:                       30em;
    transparency:                "real";
    fullscreen:                  false;
    border:                      0px;
    border-radius:               12px;
    border-color:                @main-br;
    background-color:            @main-bg;
    cursor:                      "default";
}

mainbox {
    enabled:                     true;
    spacing:                     0em;
    padding:                     0em;
    background-color:            transparent;
    children:                    [ "inputbar", "listview" ];
}

inputbar {
    padding:                     1em;
    spacing:                     0.5em;
    background-color:            @main-bg;
    children:                    [ "prompt", "entry" ];
}

prompt {
    background-color:            transparent;
    text-color:                  @main-br;
}

entry {
    background-color:            transparent;
    text-color:                  @main-fg;
    placeholder:                 "Search...";
    placeholder-color:           #6C7086ff;
    cursor:                      text;
}

listview {
    columns:                     1;
    lines:                       10;
    cycle:                       true;
    dynamic:                     false;
    scrollbar:                   false;
    fixed-height:                true;
    padding:                     0.5em;
    spacing:                     0.3em;
    background-color:            transparent;
}

element {
    padding:                     0.8em 1em;
    border-radius:               8px;
    background-color:            transparent;
    text-color:                  @main-fg;
    cursor:                      pointer;
}

element selected.normal {
    background-color:            @select-bg;
    text-color:                  @select-fg;
}

element-text {
    background-color:            transparent;
    text-color:                  inherit;
    cursor:                      inherit;
}
```

**Step 1: Create the file**

**Step 2: Test**

Run: `echo -e "Option A\nOption B\nOption C" | rofi -dmenu -theme ~/.config/rofi/themes/simple.rasi`
Expected: Clean single-column windowed menu

**Step 3: Commit**

```bash
git add ~/.config/rofi/themes/simple.rasi
git commit -m "feat(rofi): add simple single-column windowed theme"
```

---

## Phase 5: Wallpaper Browser

### Task 11: Create wallpaper category selector

**Files:**
- Modify: `~/.config/rofi/scripts/rofi-wallpaper.sh`

Rewrite the wallpaper script for two-step browsing:

Step 1 shows a 6x4 grid of categories from `~/walls/`, each with a random preview image from that folder.

```bash
#!/usr/bin/env bash
#
# rofi-wallpaper.sh — Two-step wallpaper browser
#
# Step 1: Category grid with preview thumbnails
# Step 2: Horizontal wallpaper slider with live preview (rofi-blocks)

ROFI_DIR="$HOME/.config/rofi"
THEME_DIR="$ROFI_DIR/themes"
WALL_DIR="$HOME/walls"
CACHE_DIR="$HOME/.cache/rofi-wallpaper"

if [[ ! -d "$WALL_DIR" ]]; then
    notify-send "Error" "Wallpapers directory not found: $WALL_DIR" -u critical
    exit 1
fi

mkdir -p "$CACHE_DIR/thumbs"

# Generate category thumbnails (random image from each folder)
generate_category_thumbs() {
    for dir in "$WALL_DIR"/*/; do
        [[ -d "$dir" ]] || continue
        cat_name=$(basename "$dir")
        thumb="$CACHE_DIR/thumbs/$cat_name.png"
        # Only regenerate if missing or older than 1 hour
        if [[ ! -f "$thumb" ]] || [[ $(find "$thumb" -mmin +60 2>/dev/null) ]]; then
            # Pick a random image from the category
            img=$(find "$dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n1)
            if [[ -n "$img" ]]; then
                convert "$img" -resize 400x225^ -gravity center -extent 400x225 "$thumb" 2>/dev/null
            fi
        fi
    done
}

generate_category_thumbs

# Build category entries with preview icons
entries=""
for dir in "$WALL_DIR"/*/; do
    [[ -d "$dir" ]] || continue
    cat_name=$(basename "$dir")
    count=$(find "$dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | wc -l)
    thumb="$CACHE_DIR/thumbs/$cat_name.png"
    if [[ -f "$thumb" ]]; then
        entries+="$cat_name ($count)\x00icon\x1f$thumb\n"
    else
        entries+="$cat_name ($count)\n"
    fi
done

# Step 1: Category selector (6-column grid)
r_override="window{width:80%;}
    listview{columns:4;lines:2;}
    element{orientation:vertical;border-radius:16px;padding:1em;}
    element-icon{border-radius:12px;size:14em;}
    element-text{horizontal-align:0.5;}"

chosen_cat=$(echo -en "$entries" | rofi -dmenu \
    -theme "$THEME_DIR/selector" \
    -theme-str "$r_override" \
    -p "Category" \
    -mesg "Select a wallpaper category")

if [[ -z "$chosen_cat" ]]; then
    exit 0
fi

# Strip the count suffix: "dark-minimal (15)" -> "dark-minimal"
chosen_cat=$(echo "$chosen_cat" | sed 's/ ([0-9]*)$//')

# Step 2: Launch the wallpaper slider for the selected category
exec "$ROFI_DIR/scripts/rofi-wallpaper-slider.sh" "$chosen_cat"
```

**Step 1: Write the script**

**Step 2: Make executable**

Run: `chmod +x ~/.config/rofi/scripts/rofi-wallpaper.sh`

**Step 3: Test category selector**

Run: `~/.config/rofi/scripts/rofi-wallpaper.sh`
Expected: Grid of 8 categories with preview thumbnails. Selecting one should try to launch the slider (which doesn't exist yet — will fail gracefully).

**Step 4: Commit**

```bash
git add ~/.config/rofi/scripts/rofi-wallpaper.sh
git commit -m "feat(rofi): rewrite wallpaper picker with category grid"
```

---

### Task 12: Create wallpaper slider theme

**Files:**
- Create: `~/.config/rofi/themes/wallpaper-slider.rasi`

A 16:9 window at 80% of screen width, centered, for the horizontal wallpaper strip.

```rasi
/**
 * Wallpaper Slider — Horizontal wallpaper browser
 * Used with rofi-blocks for dynamic content + live preview.
 * 16:9 aspect, 80% screen width, centered.
 */

@theme "~/.config/rofi/themes/theme.rasi"

window {
    width:                       80%;
    transparency:                "real";
    fullscreen:                  false;
    border:                      0px;
    border-radius:               16px;
    border-color:                @main-br;
    background-color:            @main-bg;
    cursor:                      "default";
    anchor:                      center;
    location:                    center;
}

mainbox {
    enabled:                     true;
    spacing:                     0em;
    padding:                     1em;
    background-color:            transparent;
    children:                    [ "inputbar", "listview", "message" ];
}

inputbar {
    padding:                     0.8em 1em;
    spacing:                     0.5em;
    border-radius:               12px 12px 0 0;
    background-color:            @main-bg;
    children:                    [ "textbox-prompt-colon", "entry" ];
}

textbox-prompt-colon {
    expand:                      false;
    str:                         "󰸉 ";
    text-color:                  @main-br;
    background-color:            transparent;
}

entry {
    background-color:            transparent;
    text-color:                  @main-fg;
    placeholder:                 "Browse wallpapers...";
    placeholder-color:           #6C7086ff;
    cursor:                      text;
}

listview {
    columns:                     5;
    lines:                       1;
    cycle:                       true;
    dynamic:                     true;
    scrollbar:                   false;
    layout:                      vertical;
    spacing:                     1em;
    padding:                     1em;
    background-color:            transparent;
}

element {
    orientation:                 vertical;
    padding:                     0.5em;
    border-radius:               12px;
    background-color:            transparent;
    cursor:                      pointer;
}

element selected.normal {
    background-color:            @select-bg;
    border:                      0 0 3px 0 solid;
    border-color:                @main-br;
}

element-icon {
    size:                        16em;
    border-radius:               10px;
    background-color:            transparent;
    cursor:                      inherit;
}

element-text {
    horizontal-align:            0.5;
    background-color:            transparent;
    text-color:                  @main-fg;
    cursor:                      inherit;
}

element-text selected {
    text-color:                  @select-fg;
}

message {
    padding:                     0.5em 1em;
    background-color:            transparent;
}

textbox {
    background-color:            transparent;
    text-color:                  @main-fg;
    horizontal-align:            0.5;
}
```

**Step 1: Create the file**

**Step 2: Commit**

```bash
git add ~/.config/rofi/themes/wallpaper-slider.rasi
git commit -m "feat(rofi): add wallpaper slider theme"
```

---

### Task 13: Create wallpaper slider script (rofi-blocks)

**Files:**
- Create: `~/.config/rofi/scripts/rofi-wallpaper-slider.sh`

This uses rofi-blocks for dynamic content with live wallpaper preview.

```bash
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
```

Note: The rofi-blocks integration may need iteration. The wrapper communicates via JSON over stdin/stdout. If `rofi-blocks` behavior differs from expected, the dmenu fallback ensures the feature still works with thumbnail icons — just without live preview.

**Step 1: Write the script**

**Step 2: Make executable**

Run: `chmod +x ~/.config/rofi/scripts/rofi-wallpaper-slider.sh`

**Step 3: Test with a category**

Run: `~/.config/rofi/scripts/rofi-wallpaper-slider.sh catppuccin`
Expected: Horizontal strip of wallpaper thumbnails. Navigating changes the desktop wallpaper live. Enter persists. Escape reverts.

**Step 4: Test end-to-end**

Run: `~/.config/rofi/scripts/rofi-wallpaper.sh`
Expected: Category grid → select "catppuccin" → wallpaper slider → live preview → Enter/Escape

**Step 5: Commit**

```bash
git add ~/.config/rofi/scripts/rofi-wallpaper-slider.sh
git commit -m "feat(rofi): add rofi-blocks wallpaper slider with live preview"
```

---

## Phase 6: Update Existing Scripts + Keybindings

### Task 14: Update all utility scripts to use new themes

**Files:**
- Modify: `~/.config/rofi/scripts/rofi-power.sh` — change THEME to `clipboard.rasi`
- Modify: `~/.config/rofi/scripts/rofi-clipboard.sh` — change THEME to `clipboard.rasi`
- Modify: `~/.config/rofi/scripts/rofi-screenshot.sh` — change THEME to `clipboard.rasi`
- Modify: `~/.config/rofi/scripts/rofi-media.sh` — change THEME to `clipboard.rasi`
- Modify: `~/.config/rofi/scripts/rofi-keybindings.sh` — change THEME to `clipboard.rasi`
- Modify: `~/.config/rofi/scripts/rofi-websearch.sh` — change THEME to `clipboard.rasi`
- Modify: `~/.config/rofi/scripts/rofi-bookmarks.sh` — change THEME to `clipboard.rasi`
- Modify: `~/.config/rofi/scripts/rofi-bluetooth.sh` — change THEME to `simple.rasi`
- Modify: `~/.config/rofi/scripts/rofi-display.sh` — change THEME to `simple.rasi`
- Modify: `~/.config/rofi/scripts/rofi-systemd.sh` — change THEME to `simple.rasi`
- Modify: `~/.config/rofi/scripts/rofi-git-profile.sh` — change THEME to `simple.rasi`
- Modify: `~/.config/rofi/scripts/rofi-tmux.sh` — change THEME to `simple.rasi`
- Modify: `~/.config/rofi/scripts/rofi-projects.sh` — change THEME to `simple.rasi`
- Modify: `~/.config/rofi/scripts/rofi-obsidian.sh` — change THEME to `simple.rasi`
- Modify: `~/.config/rofi/scripts/rofi-obsidian-search.sh` — change THEME to `simple.rasi`
- Modify: `~/.config/rofi/scripts/rofi-obsidian-create.sh` — change THEME to `simple.rasi`

**Step 1: Update each script's THEME variable**

In each script, find the line like:
```bash
THEME="$HOME/.config/rofi/themes/power.rasi"
```
And replace with the appropriate new theme:
```bash
THEME="$HOME/.config/rofi/themes/clipboard.rasi"
# or
THEME="$HOME/.config/rofi/themes/simple.rasi"
```

**Step 2: Test a few representative scripts**

```bash
~/.config/rofi/scripts/rofi-power.sh        # should use clipboard style
~/.config/rofi/scripts/rofi-bluetooth.sh     # should use simple style
~/.config/rofi/scripts/rofi-clipboard.sh     # should use clipboard style
```

**Step 3: Commit**

```bash
git add ~/.config/rofi/scripts/*.sh
git commit -m "refactor(rofi): update all scripts to use new HyDE-based themes"
```

---

### Task 15: Update i3 keybindings

**Files:**
- Modify: `~/.config/i3/config`

Changes:
1. `$mod+Space` → calls `rofilaunch.sh d` instead of direct rofi invocation
2. `$mod+Shift+d` → style selector (was run command; run command now accessible via launcher mode-switcher tabs)
3. Remove old `$mod+Shift+d` run command binding
4. Other rofi core bindings (Tab for window, Shift+s for ssh, Shift+f for filebrowser) → use `rofilaunch.sh` with appropriate flag

```
# ── Rofi Core ──────────────────────────────────────────────
bindsym $mod+space exec --no-startup-id ~/.config/rofi/scripts/rofilaunch.sh d
bindsym $mod+Tab exec --no-startup-id ~/.config/rofi/scripts/rofilaunch.sh w
bindsym $mod+Shift+s exec --no-startup-id ~/.config/rofi/scripts/rofilaunch.sh --run
bindsym $mod+Shift+f exec --no-startup-id ~/.config/rofi/scripts/rofilaunch.sh f
bindsym $mod+Shift+d exec --no-startup-id ~/.config/rofi/scripts/rofi-style-selector.sh
bindsym $mod+F1 exec --no-startup-id rofi -show keys -theme ~/.config/rofi/themes/clipboard.rasi
```

**Step 1: Update the i3 config**

**Step 2: Test**

Restart i3: `$mod+Shift+r`
Test `$mod+Space` → launcher opens with saved style
Test `$mod+Shift+d` → style selector opens
Test `$mod+Tab` → window switcher

**Step 3: Commit**

```bash
git add ~/.config/i3/config
git commit -m "refactor(i3): update rofi keybindings to use rofilaunch.sh + style selector"
```

---

## Phase 7: Cleanup

### Task 16: Remove old theme files

**Files:**
- Delete: `~/.config/rofi/themes/shared/list-menu.rasi`
- Delete: `~/.config/rofi/themes/shared/option-menu.rasi`
- Delete: `~/.config/rofi/themes/shared/settings.rasi`
- Delete: `~/.config/rofi/themes/launcher.rasi`
- Delete: `~/.config/rofi/themes/power.rasi`
- Delete: `~/.config/rofi/themes/screenshot.rasi`
- Delete: `~/.config/rofi/themes/media.rasi`
- Delete: `~/.config/rofi/themes/bluetooth.rasi`
- Delete: `~/.config/rofi/themes/display.rasi`
- Delete: `~/.config/rofi/themes/wallpaper.rasi`
- Delete: `~/.config/rofi/themes/systemd.rasi`
- Delete: `~/.config/rofi/themes/calculator.rasi`
- Delete: `~/.config/rofi/themes/emoji.rasi`
- Delete: `~/.config/rofi/themes/websearch.rasi`
- Delete: `~/.config/rofi/themes/projects.rasi`
- Delete: `~/.config/rofi/themes/git-profile.rasi`
- Delete: `~/.config/rofi/themes/tmux.rasi`
- Delete: `~/.config/rofi/themes/bookmarks.rasi`
- Delete: `~/.config/rofi/themes/obsidian.rasi`
- Delete: `~/.config/rofi/themes/obsidian-search.rasi`
- Delete: `~/.config/rofi/themes/keybindings.rasi`
- Keep: `~/.config/rofi/themes/catppuccin-mocha.rasi`
- Keep: `~/.config/rofi/themes/shared/` directory (now empty, remove)

**Step 1: Verify no scripts still reference old themes**

Run: `grep -r "themes/shared\|themes/launcher\|themes/power\|themes/screenshot\|themes/media\|themes/bluetooth\|themes/display\|themes/wallpaper\.rasi\|themes/systemd\|themes/calculator\|themes/emoji\|themes/websearch\|themes/projects\|themes/git-profile\|themes/tmux\|themes/bookmarks\|themes/obsidian\|themes/keybindings" ~/.config/rofi/scripts/ ~/.config/i3/config`
Expected: No matches (all updated in Tasks 14-15)

**Step 2: Remove old files**

```bash
rm ~/.config/rofi/themes/shared/list-menu.rasi
rm ~/.config/rofi/themes/shared/option-menu.rasi
rm ~/.config/rofi/themes/shared/settings.rasi
rmdir ~/.config/rofi/themes/shared
rm ~/.config/rofi/themes/{launcher,power,screenshot,media,bluetooth,display,wallpaper,systemd,calculator,emoji,websearch,projects,git-profile,tmux,bookmarks,obsidian,obsidian-search,keybindings}.rasi
```

**Step 3: Commit**

```bash
git add -A ~/.config/rofi/themes/
git commit -m "chore(rofi): remove old fullscreen-blur theme files"
```

---

### Task 17: Update README and documentation

**Files:**
- Modify: `~/.config/rofi/README.md`
- Modify: `~/.config/i3/README.md`

Update both READMEs to reflect:
- New theme architecture (HyDE windowed styles replacing fullscreen blur)
- Updated directory structure
- New keybindings ($mod+Space, $mod+Shift+d for style selector)
- Wallpaper browser with rofi-blocks
- Updated dependency list (add ImageMagick, rofi-blocks)

**Step 1: Update rofi README.md**

**Step 2: Update i3 README.md**

**Step 3: Commit**

```bash
git add ~/.config/rofi/README.md ~/.config/i3/README.md
git commit -m "docs: update README files for HyDE theme port"
```

---

## Phase 8: End-to-End Testing

### Task 18: Full integration test

**Step 1: Restart i3**

Press `$mod+Shift+r`

**Step 2: Test launcher with all styles**

For each style 1-12 + launchpad:
1. Open style selector: `$mod+Shift+d`
2. Select the style
3. Open launcher: `$mod+Space`
4. Verify it opens correctly with wallpaper preview
5. Dismiss with Escape

**Step 3: Test utility menus**

Test each utility menu keybinding and verify it uses the correct new theme:
- `$mod+c` — Clipboard (clipboard.rasi)
- `$mod+Shift+e` — Power (clipboard.rasi)
- `Print` — Screenshot (clipboard.rasi)
- `$mod+m` — Media (clipboard.rasi)
- `$mod+Shift+b` — Bluetooth (simple.rasi)
- `$mod+Shift+w` — Wallpaper browser (category grid → slider)

**Step 4: Test wallpaper browser end-to-end**

1. Press `$mod+Shift+w`
2. Category grid appears with preview thumbnails
3. Select a category
4. Wallpaper slider appears
5. Navigate — wallpaper changes in real-time
6. Press Escape — reverts to original
7. Repeat, press Enter — persists new wallpaper

**Step 5: Verify everything persists across i3 restart**

Press `$mod+Shift+r` and re-test launcher + a few utility menus.

---

## Summary

| Phase | Tasks | Description |
|-------|-------|-------------|
| 1 | 1-2 | Theme foundation (color mapping + style.conf) |
| 2 | 3-5 | Port 12 launcher styles + launchpad |
| 3 | 6-8 | Launcher script + style selector + preview assets |
| 4 | 9-10 | Utility menu themes (clipboard dropdown + simple) |
| 5 | 11-13 | Wallpaper browser (category grid + rofi-blocks slider) |
| 6 | 14-15 | Update scripts + i3 keybindings |
| 7 | 16-17 | Cleanup old files + update docs |
| 8 | 18 | End-to-end testing |

**Total: 18 tasks across 8 phases**
