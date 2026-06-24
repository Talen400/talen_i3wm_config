#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}╔══════════════════════════════════════╗"
echo -e "║   Frieren i3wm - Installation        ║"
echo -e "╚══════════════════════════════════════╝${NC}"

# Get the current script directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ──────────────────────────────────────────────────
# PLATFORM DETECTION
# ──────────────────────────────────────────────────
detect_platform() {
    if command -v VBoxControl &> /dev/null || \
       lspci 2>/dev/null | grep -qi "virtualbox" || \
       systemd-detect-virt 2>/dev/null | grep -qi "oracle"; then
        echo "virtualbox"
    elif lspci 2>/dev/null | grep -qi "vmware" || \
         systemd-detect-virt 2>/dev/null | grep -qi "vmware"; then
        echo "vmware"
    else
        echo "bare-metal"
    fi
}

PLATFORM=$(detect_platform)
echo -e "${GREEN}✓${NC} Platform detected: ${PLATFORM}"

# ──────────────────────────────────────────────────
# 1. INSTALL DEPENDENCIES (Arch Linux)
# ──────────────────────────────────────────────────
echo -e "\n${GREEN}[1/5] Checking dependencies...${NC}"

PACKAGES_BASE=(
    i3-wm polybar picom alacritty rofi dunst feh
    pulseaudio-alsa pavucontrol playerctl
)

PACKAGES_WALL=(
    python-pywal i3lock-color
)

PACKAGES_FONT=(
    ttf-jetbrains-mono-nerd ttf-font-awesome noto-fonts
)

PACKAGES_UTIL=(
    network-manager-applet polkit-gnome xfce4-power-manager
    flameshot light jq
    xdg-desktop-portal xdg-desktop-portal-gtk
)

PACKAGES_GTK=(
    nwg-look papirus-icon-theme
)

PACKAGES_SDDM=(
    sddm qt5-declarative qt5-graphicaleffects qt5-quickcontrols2 qt5-svg
)

PACKAGES_XORG=(
    xorg xorg-xinit
)

PACKAGES_PLATFORM=()
case "$PLATFORM" in
    virtualbox)
        PACKAGES_PLATFORM=(virtualbox-guest-utils mesa)
        ;;
    vmware)
        PACKAGES_PLATFORM=(open-vm-tools xf86-video-vmware mesa)
        ;;
    bare-metal)
        PACKAGES_PLATFORM=(mesa)
        ;;
esac

ALL_PACKAGES=(
    "${PACKAGES_BASE[@]}"
    "${PACKAGES_WALL[@]}"
    "${PACKAGES_FONT[@]}"
    "${PACKAGES_UTIL[@]}"
    "${PACKAGES_GTK[@]}"
    "${PACKAGES_SDDM[@]}"
    "${PACKAGES_XORG[@]}"
    "${PACKAGES_PLATFORM[@]}"
)

# Check if running Arch
if command -v pacman &> /dev/null; then
    for pkg in "${ALL_PACKAGES[@]}"; do
        if ! pacman -Qi "$pkg" &> /dev/null; then
            echo -e "${YELLOW}⚠ Installing: $pkg${NC}"
            sudo pacman -S --noconfirm "$pkg" 2>/dev/null || \
                echo -e "${YELLOW}  → $pkg not found (may need AUR)${NC}"
        else
            echo -e "${GREEN}✓${NC} $pkg already installed"
        fi
    done
else
    echo -e "${YELLOW}⚠ Arch Linux not detected (pacman not found)"
    echo -e "  Install packages manually:${NC}"
    echo "  ${ALL_PACKAGES[*]}"
fi

# ──────────────────────────────────────────────────
# 1.5 HYPERVISOR SETUP
# ──────────────────────────────────────────────────
case "$PLATFORM" in
    virtualbox)
        echo -e "\n${GREEN}[1.5/5] VirtualBox detected. Setting up guest utilities...${NC}"

        # Remove conflicting VMware driver if present
        if pacman -Qi xf86-video-vmware &>/dev/null; then
            sudo pacman -Rns --noconfirm xf86-video-vmware
        fi

        sudo systemctl enable vboxservice
        sudo usermod -aG video,input "$USER"

        # Install Xorg modesetting config if not already present
        if [ -f "$DOTFILES_DIR/xorg/20-vbox.conf" ]; then
            sudo mkdir -p /etc/X11/xorg.conf.d
            sudo cp "$DOTFILES_DIR/xorg/20-vbox.conf" /etc/X11/xorg.conf.d/20-vbox.conf
            echo -e "${GREEN}✓${NC} Xorg modesetting config installed"
        fi

        echo -e "${GREEN}✓${NC} vboxservice enabled, user added to video/input groups"
        ;;
    vmware)
        echo -e "\n${GREEN}[1.5/5] VMware detected. Setting up guest tools...${NC}"
        sudo systemctl enable vmtoolsd
        echo -e "${GREEN}✓${NC} vmtoolsd enabled"
        ;;
    bare-metal)
        echo -e "\n${GREEN}[1.5/5] Bare-metal detected. No hypervisor setup needed.${NC}"
        ;;
esac

# ──────────────────────────────────────────────────
# 2. CREATE DIRECTORIES
# ──────────────────────────────────────────────────
echo -e "\n${GREEN}[2/5] Creating directories...${NC}"
mkdir -p "$HOME/Imagens/wallpapers"
mkdir -p "$HOME/Imagens/screenshots"
mkdir -p "$HOME/.config/gtk-3.0"

# ──────────────────────────────────────────────────
# 3. INSTALL DOTFILES (SYMLINKS)
# ──────────────────────────────────────────────────
echo -e "\n${GREEN}[3/5] Installing dotfiles...${NC}"

install_config() {
    local src="$DOTFILES_DIR/$1"
    local dest="$2"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo -e "${YELLOW}⚠  $dest already exists. Removing...${NC}"
        rm -rf "$dest"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    echo -e "${GREEN}✓${NC} Linked: $dest → $src"
}

# Standard configs (folder → ~/.config/folder/)
for cfg in i3 polybar rofi picom dunst; do
    if [ -d "$DOTFILES_DIR/$cfg" ]; then
        install_config "$cfg" "$HOME/.config/$cfg"
    else
        echo -e "${YELLOW}❌ Folder $cfg not found${NC}"
    fi
done

# Make lock/dwindle scripts executable
chmod +x "$HOME/.config/i3/lock.sh" 2>/dev/null || true
chmod +x "$HOME/.config/i3/dwindle.sh" 2>/dev/null || true

# Alacritty — cleanup old folder symlink, then link single file
if [ -L "$HOME/.config/alacritty" ]; then
    rm -f "$HOME/.config/alacritty"
fi
mkdir -p "$HOME/.config/alacritty"
install_config "alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"

# GTK (different paths)
install_config "gtk/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
install_config "gtk/.gtkrc-2.0"   "$HOME/.gtkrc-2.0"

# ──────────────────────────────────────────────────
# 4. WALLPAPER + PYwal
# ──────────────────────────────────────────────────
echo -e "\n${GREEN}[4/5] Setting up wallpaper...${NC}"

if [ -f "$DOTFILES_DIR/wallpapers/wallpaper.png" ]; then
    cp "$DOTFILES_DIR/wallpapers/wallpaper.png" "$HOME/Imagens/wallpapers/wallpaper.png"

    # Generate color palette with pywal
    if command -v wal &> /dev/null; then
        wal -i "$HOME/Imagens/wallpapers/wallpaper.png" -e -q 2>/dev/null
        echo -e "${GREEN}✓${NC} Pywal: palette generated from wallpaper"
    else
        echo -e "${YELLOW}⚠ pywal not installed. Install python-pywal.${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Wallpaper not found at wallpapers/wallpaper.png${NC}"
fi

# ──────────────────────────────────────────────────
# 5. SDDM (OPTIONAL)
# ──────────────────────────────────────────────────
echo -e "\n${GREEN}[5/5] Setting up SDDM...${NC}"

if command -v sddm &> /dev/null; then
    # Sugar Dark theme
    if [ -d "$DOTFILES_DIR/sddm/themes/sugar-dark" ]; then
        echo -e "${GREEN}✓${NC} Installing SDDM Sugar Dark theme..."
        sudo mkdir -p /usr/share/sddm/themes/sugar-dark
        sudo cp -r "$DOTFILES_DIR/sddm/themes/sugar-dark/"* /usr/share/sddm/themes/sugar-dark/

        if [ -f "$DOTFILES_DIR/wallpapers/wallpaper.png" ]; then
            sudo cp "$DOTFILES_DIR/wallpapers/wallpaper.png" /usr/share/sddm/themes/sugar-dark/
        fi

        sudo cp "$DOTFILES_DIR/sddm/sddm.conf" /etc/sddm.conf
        echo -e "${GREEN}✓${NC} SDDM Sugar Dark theme installed"
    fi

    echo -e "${YELLOW}[?] Enable SDDM as display manager? (y/N)${NC}"
    read -r resp
    if [[ "$resp" =~ ^[Yy]$ ]]; then
        sudo systemctl enable sddm
        echo -e "${GREEN}✓${NC} SDDM enabled at boot"
    else
        echo -e "${GREEN}✓${NC} SDDM installed but not enabled (use: sudo systemctl enable sddm)"
    fi
fi

# ──────────────────────────────────────────────────
# FINAL
# ──────────────────────────────────────────────────
echo -e "\n${GREEN}╔══════════════════════════════════════╗"
echo -e "║   Installation complete! 🧙‍♀️           ║"
echo -e "╚══════════════════════════════════════╝${NC}"
echo -e "  Reload i3:  ${GREEN}Alt+Shift+c${NC}"
echo -e "  Or restart: ${GREEN}Alt+Shift+r${NC}"
echo -e ""
echo -e "  Post-install tips:"
echo -e "  - nwg-look: customize GTK theme"
echo -e "  - Change wallpaper: ${GREEN}wal -i /path/to/image.jpg${NC}"
