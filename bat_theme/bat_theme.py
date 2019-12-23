#! /usr/bin/env python3

# Get random bat theme different from last one set
# Note that you need to have 'bat' installed (github : https://github.com/sharkdp/bat)
# To use this script properly, you can add in your .bashrc "export BAT_THEME=$(python3 /path/to/script/bat_theme.py)"
# Or you can edit your crontab to run "export BAT_THEME=$(python3 /path/to/script/bat_theme.py)" at any time you please

import random
import sys
from subprocess import Popen, PIPE

proc = Popen("which bat", stdout=PIPE, shell=True)
proc.wait()
if proc.returncode != 0: sys.exit()

# list of themes supported by the command 'bat'
list_of_themes = ["1337","DarkNeon","GitHub","Monokai Extended","Monokai Extended Bright","Monokai Extended Light","Monokai Extended Origin","OneHalfDark","OneHalfLight","Sublime Snazzy","TwoDark","ansi-dark","ansi-light","base16","zenburn"]
list_of_dark_themes = ["1337", "DarkNeon", "Monokai Extended", "Monokai Extended Bright", "Monokai Extended Origin", "OneHalfDark", "Sublime Snazzy", "TwoDark", "ansi-dark", "base16", "zenburn"]

# the current_theme is stored in $BAT_THEME
proc = Popen("echo \"$BAT_THEME\"", stdout=PIPE, shell=True) 
current_theme = proc.communicate()[0].decode("utf-8").replace("\n", "")

try:
  # list_of_dark_themes.remove(current_theme)
  list_of_themes.remove(current_theme)
  
  # Just in case "$BAT_THEME" is not properly set
except ValueError:
  pass

finally:
  # next_theme = random.choice(list_of_dark_themes)
  next_theme = random.choice(list_of_themes)
  print(next_theme)
