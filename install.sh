#!/bin/bash

# Cores para output
GREEN='\033[0;32m'
NC='\033[0m' # Sem cor

echo -e "${GREEN}Instalando dotfiles do tema Frieren...${NC}"

# Define o diretório atual do script
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Lista de pastas/configs para instalar
configs=(
    "i3"
    "polybar"
    "alacritty"
    "rofi"
    "picom"
)

# Função para criar link simbólico ou copiar
install_config() {
    local src="$DOTFILES_DIR/$1"
    local dest="$HOME/.config/$1"

    if [ -e "$dest" ]; then
        echo "⚠️  $dest já existe. Removendo..."
        rm -rf "$dest"
    fi

    # Cria o diretório pai se não existir
    mkdir -p "$(dirname "$dest")"

    # Cria link simbólico (recomendado para atualizações automáticas)
    ln -s "$src" "$dest"
    echo -e "${GREEN}✓$NC Link criado: $dest -> $src"
}

# Instala cada configuração
for cfg in "${configs[@]}"; do
    if [ -d "$DOTFILES_DIR/$cfg" ]; then
        install_config "$cfg"
    else
        echo "❌ Pasta $cfg não encontrada em $DOTFILES_DIR"
    fi
done

# Instala wallpaper (opcional)
if [ -f "$DOTFILES_DIR/wallpapers/frieren.jpg" ]; then
    mkdir -p "$HOME/Imagens/wallpapers"
    cp "$DOTFILES_DIR/wallpapers/frieren.jpg" "$HOME/Imagens/wallpapers/"
    echo -e "${GREEN}✓$NC Wallpaper copiado para ~/Imagens/wallpapers/"
else
    echo "⚠️  Wallpaper não encontrado. Ignorando."
fi

echo -e "${GREEN}Pronto! Recarregue o i3 com Alt+Shift+c (ou Super+Shift+c) para aplicar.${NC}"
