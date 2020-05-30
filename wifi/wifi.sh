#!/bin/sh

state() {
if [ "$(nmcli radio wifi 2>/dev/null)" = disabled ]; then
  STATE=on
else
  STATE=off
fi
}

turn() {
[ $# -eq 0 ] && { state; set $STATE; }
if [ $1 = on ]; then
  printf "Turning wifi \e[32mon\e[0m...\n"
else
  printf "Turning wifi \e[31moff\e[0m...\n"
fi
nmcli radio wifi $1 || exit 1
}

display_help() {
echo "\
Usage: turn wifi on/off, list available wireless networks, connect to a wireless network (using nmcli)

Without any options, it turns wifi on/off
Options:
  -c, --connect <SSID>  connect to access point <SSID>
  -h, --help  display this help and exit
  -l, --list  list available access points
  -r, --restart  restart the wifi"
exit $1
}

# sleep time in seconds before listing wifis or connecting to one when the wifi has just been turned on
SLEEP_TIME=3.2 

which nmcli >/dev/null || exit 1

[ $# -eq 0 ] && { turn; exit 0; }

set -- $(echo "$@" | sed 's/--connect/-c/;s/--help/-h/;s/--list/-l/;s/--restart/-r/')

while getopts :rc:hl arg; do
  case $arg in
    c) # connect <SSID>
      state
      [ $STATE = on ] && { turn on; sleep $SLEEP_TIME; }
      if ! nmcli con up id "$OPTARG" >/dev/null 2>&1; then
        nmcli dev wifi connect "$OPTARG" >/dev/null 2>&1 || \
          { printf "\e[31mUnable to establish connection with \"$OPTARG\"\n\e[0m" >&2; exit 1; }
      fi
      printf "\e[32mConnection established with \"$OPTARG\"\n\e[0m"
      exit 0;;
    h) # help
      display_help 0;;
    l) # list
      if [ "$RESTARTED" ]; then # when restart is called before
        sleep $SLEEP_TIME
        echo
      else
        state
        [ $STATE = on ] && { turn on; sleep $SLEEP_TIME; echo; }
      fi
      nmcli dev wifi list
      exit 0;;
    r) # restart
      state
      [ $STATE = off ] && turn off
      turn on
      RESTARTED=yes;;
    :)
      printf "$0: must supply an argument to -$OPTARG\n\n" >&2
      display_help 1;;
    \?)
      printf "$0: invalid option -$OPTARG\n\n" >&2
      display_help 1;;
  esac
done

[ ! "$RESTARTED" ] && display_help 1
