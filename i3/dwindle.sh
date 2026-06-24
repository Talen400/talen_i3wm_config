#!/bin/bash
eval $(i3-msg -t get_tree | jq -r '
    .. | select(.focused? == true) |
    "W=\(.rect.width)\nH=\(.rect.height)"')
if [ "$W" -gt "$H" ]; then
    i3-msg split vertical
else
    i3-msg split horizontal
fi
alacritty &
