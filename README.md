# Rofi Mega-Setup

Rofi configured as a unified command center with 20+ functions. HyDE-inspired windowed launcher styles with Catppuccin Mocha theme, designed for i3/X11.

## Architecture

### HyDE Theme System

The theme system is ported from [HyDE](https://github.com/HyDE-Project/HyDE), adapted for i3/X11:

- **12 windowed launcher styles** — each a self-contained `.rasi` file with unique layouts (sidebar, split-panel, grid, etc.)
- **Launchpad** — fullscreen macOS-style 7x5 icon grid
- **Style selector** — visual grid for switching styles, saved to `style.conf`
- **Dynamic wallpaper injection** — launcher reads current wallpaper from `~/.fehbg` and injects it at runtime
- **Runtime overrides** — border radius (from picom), font, and icon theme applied via `-theme-str`

### Theme Layering

```
theme.rasi                  <- HyDE-compatible color mapping (Catppuccin Mocha → HyDE vars)
    |
+-- style_{1..12}.rasi      <- 12 launcher styles (self-contained, import theme.rasi)
+-- launchpad.rasi           <- Fullscreen app grid
+-- selector.rasi            <- Style selector preview grid
+-- clipboard.rasi           <- Dropdown utility menu (search + scrollable list)
+-- simple.rasi              <- Single-column utility menu
+-- wallpaper-slider.rasi    <- Horizontal wallpaper browser
```

`catppuccin-mocha.rasi` (in `shared/`) contains the full Catppuccin Mocha palette for reference.

## Directory Structure

```
~/.config/rofi/
├── README.md                    <- This file
├── config.rasi                  <- Global config (modi, matching, icons - NO theme)
├── style.conf                   <- Saved launcher style preference
├── themes/
│   ├── shared/
│   │   └── catppuccin-mocha.rasi  <- Full Catppuccin Mocha palette (reference)
│   ├── theme.rasi                 <- HyDE color variable mapping
│   ├── style_{1..12}.rasi         <- 12 launcher styles
│   ├── launchpad.rasi             <- Fullscreen app grid
│   ├── selector.rasi              <- Style selector grid
│   ├── clipboard.rasi             <- Dropdown utility menu
│   ├── simple.rasi                <- Single-column utility menu
│   ├── wallpaper-slider.rasi      <- Horizontal wallpaper browser
│   └── assets/                    <- Style preview images (for selector)
├── scripts/
│   ├── rofilaunch.sh              <- Main launcher (reads style.conf + wallpaper)
│   ├── rofi-style-selector.sh     <- Visual style switcher
│   ├── rofi-wallpaper.sh          <- Wallpaper browser (category grid)
│   ├── rofi-wallpaper-slider.sh   <- Wallpaper slider (rofi-blocks + live preview)
│   ├── generate-previews.sh       <- Screenshot each style for selector assets
│   ├── rofi-power.sh              <- Power menu
│   ├── rofi-media.sh              <- Media controls
│   ├── rofi-screenshot.sh         <- Screenshot tool
│   ├── rofi-keybindings.sh        <- i3 keybinding viewer
│   ├── rofi-wallpaper.sh          <- Wallpaper category selector
│   ├── rofi-clipboard.sh          <- Clipboard (greenclip wrapper)
│   ├── rofi-git-profile.sh        <- Git profile switcher
│   ├── rofi-tmux.sh               <- Tmux session manager
│   ├── rofi-projects.sh           <- Project launcher
│   ├── rofi-obsidian.sh           <- Obsidian quick actions hub
│   ├── rofi-obsidian-search.sh    <- Obsidian note search
│   ├── rofi-obsidian-create.sh    <- Obsidian note creator
│   ├── rofi-bluetooth.sh          <- Bluetooth manager
│   ├── rofi-display.sh            <- Display layout manager
│   ├── rofi-systemd.sh            <- Systemd service manager
│   ├── rofi-bookmarks.sh          <- Firefox bookmark browser
│   ├── rofi-websearch.sh          <- Web search with suggestions
│   ├── git-profiles.conf          <- Git profile definitions
│   └── apis/
│       ├── google-suggest.sh      <- Google autocomplete API
│       ├── ddg-suggest.sh         <- DuckDuckGo autocomplete API
│       ├── youtube-suggest.sh     <- YouTube suggestions API
│       └── wikipedia-suggest.sh   <- Wikipedia OpenSearch API
```

## Launcher Styles

| Style | Layout | Size |
|-------|--------|------|
| style_1 | Sideview — wallpaper sidebar left, list right | 63x33em |
| style_2 | TwinPanel — wallpaper header, 2-col list | 56x35em |
| style_3 | ModeSidebar — blurred bg, mode icons + list | 37x30em |
| style_4 | TopPanel — wallpaper left, modes center, list right | 46x30em |
| style_5 | ModeGrid — 5-column icon grid + mode buttons | 50x31em |
| style_6 | SimpleStack — mode icons left, text list right | 37x31em |
| style_7 | ModeBar — compact horizontal bar | 38x12em |
| style_8 | SplitPanel — list+modes left, wallpaper right | 37x30em |
| style_9 | CenterStack — square wallpaper left, list right | 57x30em |
| style_10 | CompactPanel — narrow vertical, wallpaper header | 25x40em |
| style_11 | DiagonalSplit — quad wallpaper left, list right | 58x30em |
| style_12 | GradientView — list left, gradient wallpaper right | 60x30em |
| launchpad | Fullscreen 7x5 icon grid | fullscreen |

## Keybinding Reference

| Keybinding | Menu | Type | Script/Command |
|---|---|---|---|
| `$mod+Space` | App Launcher | Core | `rofilaunch.sh d` |
| `$mod+Tab` | Window Switcher | Core | `rofilaunch.sh w` |
| `$mod+Shift+s` | Run Command | Core | `rofilaunch.sh --run` |
| `$mod+Shift+f` | File Browser | Core | `rofilaunch.sh f` |
| `$mod+Shift+d` | Style Selector | Core | `rofi-style-selector.sh` |
| `$mod+F1` | Rofi Keys | Core | `rofi -show keys` |
| `$mod+Shift+e` | Power Menu | System | `rofi-power.sh` |
| `$mod+c` | Clipboard | System | `rofi-clipboard.sh` |
| `$mod+Shift+b` | Bluetooth | System | `rofi-bluetooth.sh` |
| `$mod+Shift+m` | Display Manager | System | `rofi-display.sh` |
| `$mod+Shift+w` | Wallpaper Browser | System | `rofi-wallpaper.sh` |
| `Print` | Screenshot | System | `rofi-screenshot.sh` |
| `$mod+Shift+p` | Systemd Services | System | `rofi-systemd.sh` |
| `$mod+equal` | Calculator | Productivity | `rofi -show calc` |
| `$mod+period` | Emoji Picker | Productivity | `rofimoji` |
| `$mod+slash` | Web Search | Productivity | `rofi-websearch.sh` |
| `$mod+p` | Project Manager | Developer | `rofi-projects.sh` |
| `$mod+g` | Git Profile | Developer | `rofi-git-profile.sh` |
| `$mod+t` | Tmux Sessions | Developer | `rofi-tmux.sh` |
| `$mod+Shift+o` | Firefox Bookmarks | Browser | `rofi-bookmarks.sh` |
| `$mod+n` | Obsidian Actions | Notes | `rofi-obsidian.sh` |
| `$mod+Shift+n` | Obsidian Search | Notes | `rofi-obsidian-search.sh` |
| `$mod+F2` | i3 Keybindings | Other | `rofi-keybindings.sh` |
| `$mod+m` | Media Controls | Other | `rofi-media.sh` |

## Theme Assignment

Utility scripts use one of two base themes:

**clipboard.rasi** (dropdown with search): power, clipboard, screenshot, media, keybindings, websearch, bookmarks, calculator, emoji, rofi keys

**simple.rasi** (single-column list): bluetooth, display, systemd, git-profile, tmux, projects, obsidian, obsidian-search, obsidian-create

## Dependencies

### Required

- **rofi** (1.7+) - Menu framework
- **picom** - Compositor (transparency, corner radius)
- **i3** - Window manager
- **feh** - Wallpaper setter (writes `~/.fehbg`)
- **JetBrainsMono Nerd Font** - Icon font used throughout
- **dunst** / **notify-send** - Desktop notifications

### Per-Feature Dependencies

| Feature | Packages |
|---|---|
| Screenshot | `maim`, `xclip`, `xdotool` |
| Clipboard | `greenclip` (daemon, auto-started by i3) |
| Emoji | `rofimoji` (via pipx) |
| Calculator | `rofi-calc` plugin |
| Media | `playerctl` |
| Wallpaper | `feh`, `ImageMagick` (thumbnails) |
| Wallpaper (live preview) | `rofi-blocks` plugin (optional, falls back to dmenu) |
| Bluetooth | `bluetoothctl` (from `bluez-utils`) |
| Display | `xrandr` |
| Systemd | `pkexec` (for privilege elevation) |
| Bookmarks | `sqlite3`, `firefox` |
| Web Search | `curl`, `jq`, `python3` |
| Projects | `code` (VS Code), `kitty` |
| Obsidian | `code` (VS Code) |
| Tmux | `tmux`, `kitty` |
| Style Previews | `maim` (for generating screenshots) |

## Configuration

### Changing Launcher Style

1. Press `$mod+Shift+d` to open the style selector
2. Select a style from the visual preview grid
3. Selection is saved to `style.conf` and used on next `$mod+Space`

Or manually: `echo "rofiStyle=style_5" > ~/.config/rofi/style.conf`

### Customizing Colors

Edit `themes/theme.rasi` to change the HyDE color variables. The mapping is:

| Variable | Catppuccin Mocha Color |
|---|---|
| `main-bg` | Base (#1E1E2E) with alpha |
| `main-fg` | Text (#CDD6F4) |
| `main-br` | Mauve (#CBA6F7) |
| `main-ex` | Rosewater (#F5E0DC) |
| `select-bg` | Lavender (#B4BEFE) |
| `select-fg` | Base (#1E1E2B) |

### Generating Style Previews

Run `~/.config/rofi/scripts/generate-previews.sh` to screenshot each style. Requires a display and `maim`.

### Adding a New Menu

1. Create a script in `scripts/` using `clipboard.rasi` or `simple.rasi`:

   ```bash
   #!/usr/bin/env bash
   THEME="$HOME/.config/rofi/themes/simple.rasi"
   chosen=$(echo -e "$options" | rofi -dmenu -theme "$THEME" -p "Prompt")
   ```

2. Add keybinding in `~/.config/i3/config`
3. Reload i3: `$mod+Shift+r`

### Git Profiles

Edit `scripts/git-profiles.conf` with pipe-delimited entries:

```
Work|Your Name|you@company.com
Personal|username|you@personal.com
```

### Obsidian Vault

Default vault path is `~/powerhouse/`. Edit `VAULT_DIR` in the obsidian scripts to change.

### Project Directory

Default is `~/work/`. Edit `PROJECTS_DIR` in `scripts/rofi-projects.sh`.

## Troubleshooting

### Launcher shows wrong style

- Check `style.conf` contents: `cat ~/.config/rofi/style.conf`
- Ensure the style file exists in `themes/`

### No wallpaper in launcher sidebar

- Check `~/.fehbg` exists and contains a valid wallpaper path
- Verify wallpaper file exists at the path in `~/.fehbg`

### Style selector shows no previews

- Run `generate-previews.sh` to create preview assets
- Check `themes/assets/` for `.png` files

### Greenclip not working

- Check daemon: `pgrep greenclip`
- Start manually: `greenclip daemon &`

### Calculator not showing

- Verify rofi-calc plugin: `rofi -dump-config | grep calc`

### Emoji picker not working

- Verify: `which rofimoji`
- Install: `pipx install rofimoji`
