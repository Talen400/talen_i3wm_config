#!/bin/bash
WALLPAPER=~/Imagens/wallpapers/frieren.jpg

i3lock \
    -i "$WALLPAPER" \
    --inside-color=0F0E17aa \
    --ring-color=A77BFFff \
    --insidever-color=7DC4E4aa \
    --ringver-color=7DC4E4ff \
    --insidewrong-color=FF6B9Daa \
    --ringwrong-color=FF6B9Dff \
    --line-color=0F0E17ff \
    --separator-color=A77BFFff \
    --keyhl-color=7DC4E4ff \
    --bshl-color=FF6B9Dff \
    --verif-color=E0E0E0ff \
    --wrong-color=E0E0E0ff \
    --layout-color=E0E0E0ff \
    --time-color=E0E0E0ff \
    --date-color=E0E0E0ff \
    --time-str="%H:%M" \
    --date-str="%a, %d %b" \
    --screen 1 \
    --blur 5 \
    --clock \
    --indicator \
    --radius 120 \
    --ring-width 8
