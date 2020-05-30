#!/bin/sh

THEMES_LIST="themes-list.txt" # use an absolute path if you're using an alias
SAVE_FILE="/tmp/bat-theme" # file where to save last theme used

which bat >/dev/null || { echo "Install bat from : https://github.com/sharkdp/bat" >&2 && exit 1; }
[ ! -f "$THEMES_LIST" ] && { echo "$THEMES_LIST : no such file" >&2 && exit 1; }

old_theme=$(cat "$SAVE_FILE" 2>/dev/null)
theme="$(grep -G -v "^$old_theme$" "$THEMES_LIST" | shuf -n1)"
echo "$theme" >"$SAVE_FILE"

bat --theme "$theme" "$@"
