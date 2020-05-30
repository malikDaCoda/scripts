#!/bin/bash

# Change these parameters how you want
REFRESH_RATE=0.3 # in seconds
IMG_FOLDERS=("$HOME/Pictures/Wallpapers" "$HOME/Pictures") # folders where to find wallpapers
SEARCH_DEPTH=1 # search depth in IMG_FOLDERS
SLEEP_TIME=1 # in seconds, to avoid killing your system

load_images() {
  local IFS='
  '
  IMGS=($(find ${IMG_FOLDERS[@]} -maxdepth $SEARCH_DEPTH -type f))
}

set_background() {
  [ -f "$1" ] && gsettings set org.gnome.desktop.background picture-uri "file://"$1""
}

if [ "$1" == '-h' -o "$1" == '--help' ]; then
  echo "\
Change background wallpaper when a window is closed.

Options:
  -h, --help  display this help and exit

This script should be run in the background (you can configure it to run in autostart using crontab)
Change the following parameters in the script :
refresh rate, image folders, search depth and sleep time"
  exit 0
fi

which wmctrl >/dev/null || exit 1

load_images
[ "$IMGS" ] || { echo "$0: no images loaded" >&2 && exit 1; }

set_background "${IMGS[0]}"
i=0
while true; do
  old_num="$((wmctrl -l | wc -l) 2> /dev/null)" # number of open windows
  sleep $REFRESH_RATE
  # if current number is less (a window was closed) : change wallpaper
  if (( $((wmctrl -l | wc -l) 2> /dev/null) < old_num )); then
    set_background "${IMGS[$i]}"
    (( i++ ))
    [ ! "${IMGS[$i]}" ] && i=0
  fi
  load_images
  sleep $SLEEP_TIME
done
