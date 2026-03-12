<p align="center">
  <strong><code>~/.config/rofi</code></strong>
  <br><br>
  <code>rofi, but it does everything now</code>
</p>

<p align="center">

![Shell](https://img.shields.io/badge/shell-bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)
![Rofi](https://img.shields.io/badge/rofi-1.7+-77216F?style=flat-square)
![i3](https://img.shields.io/badge/wm-i3-318CE7?style=flat-square&logo=i3&logoColor=white)
![Stars](https://img.shields.io/github/stars/shaiknoorullah/rofi?style=flat-square&color=yellow)
![works on my machine](https://img.shields.io/badge/works-on%20my%20machine-success?style=flat-square)

</p>

**27 rofi menus. 12 launcher styles. zen browser integration.** rofi as a unified command center for i3/X11. HyDE-inspired themes, and a keybinding for everything.

## what's in the box

**20+ menus** covering just about everything:
- app launcher, power, clipboard, screenshot, bluetooth, display, wallpaper, media, systemd, calculator, emoji, web search, bookmarks, tab switcher, workspace manager, git profiles, tmux, projects, obsidian, keybindings

**12 windowed launcher styles** ported from HyDE:
- sidebar, split-panel, grid, gradient variants — each a self-contained `.rasi` theme with dynamic wallpaper injection

**zen browser integration** built on brotab and fzf:
- fuzzy tab search with favicon preview
- browser-style search bar with live autocomplete and bang syntax
- domain-based tab grouping

## getting started

1. clone the repo
2. install dependencies (see [dependencies](#dependencies))
3. copy example configs
4. add i3 keybindings
5. reload i3

```bash
# clone
git clone https://github.com/shaiknoorullah/rofi.git ~/.config/rofi

# copy example configs
cp ~/.config/rofi/scripts/zen-workspaces.example.conf ~/.config/rofi/scripts/zen-workspaces.conf
cp ~/.config/rofi/scripts/git-profiles.example.conf ~/.config/rofi/scripts/git-profiles.conf

# add to your i3 config (scripts expect to live at ~/.config/rofi/)
# see the keybinding table below for the full list
# example:
#   bindsym $mod+Space exec ~/.config/rofi/scripts/rofilaunch.sh d
#   bindsym $mod+Shift+e exec ~/.config/rofi/scripts/rofi-power.sh

# reload i3
# $mod+Shift+r
```

## how to use

every menu is a keybinding away. organized by category:

**core** — launchers and navigation
**system** — hardware, display, wallpaper, power
**productivity** — calculator, emoji, search
**developer** — git, tmux, projects
**browser** — zen tabs, bookmarks, tab groups
**notes** — obsidian vault actions and search

### keybindings

| Keybinding | Menu | Script |
|---|---|---|
| `$mod+Space` | App Launcher | `rofilaunch.sh d` |
| `$mod+Tab` | Window Switcher | `rofilaunch.sh w` |
| `$mod+Shift+s` | Run Command | `rofilaunch.sh --run` |
| `$mod+Shift+f` | File Browser | `rofilaunch.sh f` |
| `$mod+Shift+d` | Style Selector | `rofi-style-selector.sh` |
| `$mod+Shift+e` | Power Menu | `rofi-power.sh` |
| `$mod+c` | Clipboard | `rofi-clipboard.sh` |
| `$mod+Shift+b` | Bluetooth | `rofi-bluetooth.sh` |
| `$mod+Shift+m` | Display Manager | `rofi-display.sh` |
| `$mod+Shift+w` | Wallpaper Browser | `rofi-wallpaper.sh` |
| `Print` | Screenshot | `rofi-screenshot.sh` |
| `$mod+Shift+p` | Systemd Services | `rofi-systemd.sh` |
| `$mod+equal` | Calculator | `rofi -show calc` |
| `$mod+period` | Emoji Picker | `rofimoji` |
| `$mod+slash` | Web Search | `rofi-websearch-v2.sh` |
| `$mod+p` | Project Manager | `rofi-projects.sh` |
| `$mod+g` | Git Profile Switcher | `rofi-git-profile.sh` |
| `$mod+t` | Tmux Sessions | `rofi-tmux.sh` |
| `$mod+Shift+o` | Zen Bookmarks | `rofi-bookmarks.sh` |
| `$mod+grave` | Zen Tab Switcher | `zen-tab-popup.sh` |
| `$mod+Shift+t` | Zen Tab Groups | `zen-workspaces.sh` |
| `$mod+n` | Obsidian Actions | `rofi-obsidian.sh` |
| `$mod+Shift+n` | Obsidian Search | `rofi-obsidian-search.sh` |
| `$mod+F1` | Rofi Keys | `rofi -show keys` |
| `$mod+F2` | i3 Keybindings | `rofi-keybindings.sh` |
| `$mod+m` | Media Controls | `rofi-media.sh` |
| `prefix+b` | Zen Tab Switcher (tmux) | `zen-tab-switcher.sh` |

## launcher styles

12 windowed styles ported from HyDE, plus a fullscreen launchpad. switch with `$mod+Shift+d`.

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

## zen browser

three integrated systems for managing Zen Browser, built on `brotab` and `fzf`.

### tab switcher

`$mod+grave` (i3) or `prefix+b` (tmux)

fzf-based fuzzy search across all open tabs with favicon preview. launches as a floating kitty window or tmux popup.

| Key | Action |
|-----|--------|
| `Enter` | switch to tab |
| `Ctrl+d` | close tab (list refreshes) |
| `Ctrl+y` | copy tab URL to clipboard |

### search bar

`$mod+slash`

browser-style search bar with live autocomplete via rofi-blocks. type a URL to navigate directly. supports bang syntax:

| Bang | Engine |
|------|--------|
| `!g` | Google |
| `!ddg` / `!d` | DuckDuckGo |
| `!yt` | YouTube |
| `!w` | Wikipedia |
| `!gh` | GitHub |

suggestions combine search engine autocomplete, bookmark matches, and history matches in parallel. falls back to simple input without rofi-blocks.

### tab groups

`$mod+Shift+t`

domain-based tab grouping with three actions:

- **switch group** — select a configured tab group, pick a tab within it
- **domain overview** — all domains sorted by tab count, drill into any
- **find duplicates** — detect tabs with identical URLs, close extras

configured via `zen-workspaces.conf` (copy from `zen-workspaces.example.conf` in `scripts/`).

## directory structure

```
rofi/
├── config.rasi                        # global rofi config (modi, matching, icons)
├── style.conf                         # saved launcher style preference
├── themes/
│   ├── theme.rasi                     # color variables (wallust-generated)
│   ├── style_{1..12}.rasi             # 12 launcher styles
│   ├── launchpad.rasi                 # fullscreen app grid
│   ├── selector.rasi                  # style selector preview grid
│   ├── clipboard.rasi                 # dropdown utility menu
│   ├── simple.rasi                    # single-column utility menu
│   ├── searchbar.rasi                 # fullscreen search overlay
│   ├── wallpaper-slider.rasi          # horizontal wallpaper browser
│   ├── shared/
│   │   └── catppuccin-mocha.rasi      # full catppuccin mocha palette
│   └── assets/                        # style preview images
├── scripts/
│   ├── rofilaunch.sh                  # main launcher (reads style.conf + wallpaper)
│   ├── rofi-style-selector.sh         # visual style switcher
│   ├── rofi-power.sh                  # power menu
│   ├── rofi-clipboard.sh             # clipboard (greenclip)
│   ├── rofi-screenshot.sh            # screenshot tool
│   ├── rofi-bluetooth.sh             # bluetooth manager
│   ├── rofi-display.sh               # display layout manager
│   ├── rofi-wallpaper.sh             # wallpaper category selector
│   ├── rofi-wallpaper-slider.sh      # wallpaper slider (rofi-blocks)
│   ├── rofi-media.sh                 # media controls
│   ├── rofi-systemd.sh               # systemd service manager
│   ├── rofi-keybindings.sh           # i3 keybinding viewer
│   ├── rofi-git-profile.sh           # git profile switcher
│   ├── rofi-tmux.sh                  # tmux session manager
│   ├── rofi-projects.sh              # project launcher
│   ├── rofi-obsidian.sh              # obsidian quick actions
│   ├── rofi-obsidian-search.sh       # obsidian note search
│   ├── rofi-obsidian-create.sh       # obsidian note creator
│   ├── rofi-bookmarks.sh             # zen browser bookmarks
│   ├── rofi-websearch.sh             # web search (legacy)
│   ├── rofi-websearch-v2.sh          # search bar with live suggestions
│   ├── zen-utils.sh                  # shared zen browser utilities
│   ├── zen-tab-switcher.sh           # fzf tab search with preview
│   ├── zen-tab-preview.sh            # fzf preview pane (favicon + metadata)
│   ├── zen-tab-popup.sh              # popup launcher (kitty/tmux)
│   ├── zen-search-handler.sh         # rofi-blocks handler (bangs + suggestions)
│   ├── zen-workspaces.sh             # tab group manager
│   ├── zen-workspaces.example.conf   # tab group definitions template
│   ├── git-profiles.example.conf     # git profile definitions template
│   ├── generate-previews.sh          # screenshot each style for selector
│   └── apis/
│       ├── google-suggest.sh         # google autocomplete API
│       ├── ddg-suggest.sh            # duckduckgo autocomplete API
│       ├── youtube-suggest.sh        # youtube suggestions API
│       ├── wikipedia-suggest.sh      # wikipedia opensearch API
│       └── suggest-aggregator.sh     # unified suggestions (API + bookmarks + history)
└── tests/                            # bats test suite
    ├── run_tests.sh
    ├── test_helper/
    └── *.bats
```

## theme system

themes are ported from [HyDE](https://github.com/HyDE-Project/HyDE), adapted for i3/X11. the launcher reads the current wallpaper from `~/.fehbg` and injects it at runtime. border radius is pulled from picom config.

theme layering:

```
theme.rasi              <- color variables (wallust-generated)
├── style_{1..12}.rasi  <- 12 launcher styles
├── launchpad.rasi      <- fullscreen app grid
├── selector.rasi       <- style selector
├── clipboard.rasi      <- dropdown utility menu
├── simple.rasi         <- single-column menu
├── searchbar.rasi      <- fullscreen search overlay
└── wallpaper-slider.rasi
```

`catppuccin-mocha.rasi` (in `shared/`) contains the full palette for reference.

## dependencies

### required

- **rofi** (1.7+) — menu framework
- **picom** — compositor (transparency, corner radius)
- **i3** — window manager
- **feh** — wallpaper setter (writes `~/.fehbg`)
- **JetBrainsMono Nerd Font** — icon font used throughout
- **notify-send** — desktop notifications

### per-feature

| Feature | Packages |
|---|---|
| Screenshot | `maim`, `xclip`, `xdotool` |
| Clipboard | `greenclip` |
| Emoji | `rofimoji` (via pipx) |
| Calculator | `rofi-calc` plugin |
| Media | `playerctl` |
| Wallpaper | `feh`, `ImageMagick` |
| Wallpaper (live preview) | `rofi-blocks` plugin |
| Bluetooth | `bluetoothctl` |
| Display | `xrandr` |
| Systemd | `pkexec` |
| Bookmarks | `sqlite3`, Zen Browser |
| Web Search | `curl`, `jq`, `python3` |
| Web Search v2 | `rofi-blocks` (optional) |
| Zen Tab Switcher | `brotab`, `fzf` (0.60+), `kitty`, `xclip` |
| Zen Tab Groups | `brotab` |
| Projects | `code` (VS Code), `kitty` |
| Obsidian | `code` (VS Code) |
| Tmux | `tmux`, `kitty` |

## configuration

**changing launcher style** — press `$mod+Shift+d` to open the style selector, or edit `style.conf` directly:
```bash
echo "rofiStyle=style_5" > ~/.config/rofi/style.conf
```

**customizing colors** — edit `themes/theme.rasi` to change color variables

**zen workspace groups** — copy `scripts/zen-workspaces.example.conf` to `scripts/zen-workspaces.conf`, edit domain patterns:
```
Work|github.com,linear.app,vercel.com
Personal|youtube.com,reddit.com
```

**git profiles** — copy `scripts/git-profiles.example.conf` to `scripts/git-profiles.conf`, add entries:
```
Work|Your Name|you@company.com
Personal|username|you@personal.com
```

**obsidian vault path** — default `~/powerhouse/`, edit `VAULT_DIR` in the obsidian scripts

**project directory** — default `~/work/`, edit `PROJECTS_DIR` in `scripts/rofi-projects.sh`

## troubleshooting

- **launcher wrong style** — check `style.conf` contents, make sure the style file exists in `themes/`
- **no wallpaper in sidebar** — check `~/.fehbg` exists and contains a valid path
- **style selector no previews** — run `scripts/generate-previews.sh`
- **greenclip not working** — check daemon is running: `pgrep greenclip`
- **tab switcher no tabs** — check `bt list`, make sure brotab extension is installed in zen
- **tab switcher doesn't float** — check i3 floating rule for zen-tab-switcher
- **search bar no suggestions** — check rofi-blocks is installed, falls back to simple input without it
- **wrong zen window class** — run `xprop WM_CLASS`, update `ZEN_WM_CLASS` in `scripts/zen-utils.sh`

## contributing

PRs welcome. keep it clean, keep it useful. if you add a new menu, include an i3 keybinding suggestion and pick a theme (`clipboard.rasi`, `simple.rasi`, or `searchbar.rasi`).

## acknowledgements

- [HyDE](https://github.com/HyDE-Project/HyDE) — launcher styles and theme system
- [Catppuccin](https://github.com/catppuccin/catppuccin) — color palette

---

<p align="center">
  <a href="https://github.com/shaiknoorullah">@shaiknoorullah</a>
  <br>
  <sub>rofi does everything if you let it</sub>
</p>
