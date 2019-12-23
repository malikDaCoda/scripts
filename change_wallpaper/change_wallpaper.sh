#!/bin/bash

if [ "$1" == '-h' -o "$1" == '--help' ]; then
  echo "Changes background wallpaper when a window is closed."
  echo "This script should be run in the background (you can configurate it to run in autostart)."
  echo "Change the values in the script as you please"

  exit 0
fi

# Change these as you please

refresh_rate=0.3 # in seconds
img_folders="/home/malik/Pictures/Wallpapers/" # space separated folders where to find wallpapers
search_depth=1 # search depth in img_folders
img_formats="jpg JPG png PNG jpeg JPEG" # accepted formats
sleep=1

function load_images {
  for folder in "$img_folders"; do
    for format in "$img_formats"; do
      img_array+=($(find "$folder" -maxdepth $search_depth -name "*.$format" 2> /dev/null))
    done
  done
}

function set_background {
  if [ -f "$1" ]; then
    gsettings set org.gnome.desktop.background picture-uri "file://"$1""
  fi
}

IFS='
'
img_folders="$(echo "$img_folders" | tr ' ' '\n')"
img_formats="$(echo "$img_formats" | tr ' ' '\n')"

if ! which wmctrl &> /dev/null; then
  echo "Package 'wmctrl' is not installed !"
  echo "Exiting..."
  exit 1
fi

load_images

# Nothing to do if there are no images loaded
if [ ${#img_folders[@]} -eq 0 ]; then
  exit 1
fi

# Only one image loaded
if [ ${#img_folders} -eq 1 ]; then
  set_background "${img_array[0]}"
  exit 0
fi


set_background "${img_array[0]}"
let i=1

while true; do
  sleep $sleep
  open_windows="$((wmctrl -l | wc -l) 2> /dev/null)" # number open windows
  sleep $refresh_rate
  # if current number is less (i.e : a window was closed) : change wallpaper
  if [ "$((wmctrl -l | wc -l) 2> /dev/null)" -lt $open_windows ]; then
    set_background "${img_array[$i]}"
    let i++
    if [ ! -f "${img_array[$i]}" ]; then
      let i=0
    fi
  fi
  load_images
done
