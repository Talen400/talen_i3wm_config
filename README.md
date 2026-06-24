# Frieren i3wm Config 🧙‍♀️

i3wm configuration inspired by **Frieren (Sousou no Frieren)**.

## Components

| Component | Purpose |
|-----------|---------|
| **i3-wm** | Window manager |
| **polybar** | Status bar |
| **alacritty** | Terminal emulator |
| **rofi** | Application launcher |
| **picom** | Compositor (transparency, blur) |
| **dunst** | Notification daemon |
| **i3lock-color** | Lock screen |
| **pywal** | Wallpaper + dynamic color palette |

## Color Palette

| Color | Usage | Hex |
|-------|-------|-----|
| Magenta purple | Focused / active accent | `#A77BFF` |
| Ice blue | Secondary accent | `#7DC4E4` |
| Silver white | Text / foreground | `#E0E0E0` |
| Deep shadow | Background | `#0F0E17` |
| Cherry pink | Urgent / error | `#FF6B9D` |
| Muted gray | Inactive text | `#888888` |

## Installation

```bash
git clone https://github.com/Talen400/talen_i3wm_config.git
cd talen_i3wm_config
chmod +x install.sh
./install.sh
```

Then reload i3 with `Alt+Shift+c` or restart your session.

## Dependencies (Arch Linux)

The `install.sh` script handles installation via `pacman` automatically:

```
i3-wm polybar picom alacritty rofi dunst feh
python-pywal i3lock-color
ttf-jetbrains-mono-nerd ttf-font-awesome noto-fonts
network-manager-applet polkit-gnome xfce4-power-manager
flameshot light pulseaudio-alsa pavucontrol playerctl
nwg-look papirus-icon-theme
sddm qt5-declarative qt5-graphicaleffects qt5-quickcontrols2 qt5-svg
```

## Keybindings

| Shortcut | Action |
|----------|--------|
| `Alt+Enter` | Terminal (alacritty) |
| `Alt+d` | Rofi launcher |
| `Alt+q` | Close window |
| `Alt+h/j/k/l` | Focus (Vim keys) |
| `Alt+Arrow keys` | Focus |
| `Alt+Shift+h/j/k/l` | Move window |
| `Alt+Shift+Arrow keys` | Move window |
| `Alt+[1-9]` | Switch workspace |
| `Alt+Shift+[1-9]` | Move to workspace |
| `Alt+r` | Resize mode (h/j/k/l) |
| `Alt+f` | Fullscreen toggle |
| `Alt+Shift+x` | Lock screen |
| `Alt+Shift+c` | Reload i3 config |
| `Alt+Shift+r` | Restart i3 |
| `Print` | Screenshot (flameshot GUI) |
| `Shift+Print` | Full screenshot |
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Mute toggle |
| `XF86AudioPlay/Prev/Next` | Media controls |
| `XF86MonBrightnessUp/Down` | Brightness |

## Change Wallpaper

```bash
wal -i ~/Imagens/wallpapers/your-image.jpg

> ℹ️ A `wallpapers/wallpaper.png` padrão é um gradiente neutro.
> Substitua pela sua própria imagem antes de rodar o install.sh,
> ou coloque manualmente em `~/Imagens/wallpapers/` e rode `wal -i`.
```
