.PHONY: install check symlinks picom polybar wal xorg sddm all

install:
	./install.sh

check:
	@echo "=== Dependencies ==="
	pacman -Qi i3-wm polybar picom alacritty rofi dunst feh \
	         python-pywal i3lock-color network-manager-applet \
	         polkit-gnome xfce4-power-manager flameshot jq \
	         pulseaudio-alsa pavucontrol playerctl \
	         ttf-jetbrains-mono-nerd nwg-look papirus-icon-theme \
	         xorg xorg-xinit sddm 2>&1 | grep -E '^(Nome|Vers.*o|Status)'

symlinks:
	@echo "=== Symlinks ==="
	for d in i3 polybar rofi picom dunst; do \
		[ -L "$(HOME)/.config/$$d" ] && echo "  OK  $$d" || echo "  MISS $$d"; \
	done
	[ -L "$(HOME)/.config/alacritty/alacritty.toml" ] && echo "  OK  alacritty.toml" || echo "  MISS alacritty.toml"

picom:
	picom --config $(HOME)/.config/picom/picom.conf --log-level debug 2>&1 | head -30

polybar:
	polybar main -l debug 2>&1 | head -30

wal:
	wal -i $(HOME)/Imagens/wallpapers/wallpaper.png -e -q 2>&1

xorg:
	@echo "=== Xorg errors ==="
	grep -E '(EE)' /var/log/Xorg.0.log 2>/dev/null || echo "No errors found"
	@echo "=== Xorg warnings ==="
	grep -E '(WW)' /var/log/Xorg.0.log 2>/dev/null || echo "No warnings found"

sddm:
	systemctl status display-manager --no-pager 2>&1 | head -10

all: check symlinks picom polybar wal
