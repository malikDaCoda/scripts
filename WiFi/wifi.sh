#!/bin/bash

function wifi_state {
  if [ $(nmcli radio wifi) == "disabled" ]; then
    state="on"
  else
    state="off"
  fi
}

function turn_wifi {
  nmcli radio wifi $1 &> /dev/null
}

which nmcli &> /dev/null
if [ $? -ne 0 ]; then
  echo -e "\e[1;31m\"nmcli\" is not installed on the system\e[0m"
  exit 1
fi

wifi_state

if [ $# -eq 0 ]; then
    echo "Turning wifi $state..."
    turn_wifi $state
  exit 0
else
  if [ $# -eq 1 -a $1 == "-l" -o $1 == "--list" ]; then
    if [ $state == "on" ]; then
      turn_wifi on
      sleep 3.5
    fi
    nmcli device wifi list
    exit 0
  else
    if [ $# -eq 1 -a $1 == "-r" -o $1 == "--restart" ]; then
      echo "Restarting wifi..."
      turn_wifi off
      sleep 1
      turn_wifi on
    else
      if [ $# -eq 2 -a $1 == "-c" -o $1 == "--connect" ]; then
         if [ $state == "on" ]; then
          turn_wifi on
          sleep 3.5
         fi
        nmcli device wifi connect "$2" &> /dev/null
        if [ $? -eq 0 ]; then
          echo -e "\e[1;32mConnection established with \"$2\" !\e[0m"
          exit 0
        else
          echo -e "\e[1;31mConnection with \"$2\" failed !\e[0m"
          exit 1
        fi
      else
        echo "Usage : turn wifi on/off, list available wireless networks, connect to a wireless network

              Without any options, it turns wifi on/off

               -h, --help             display this help message and exit
               -l, --list             list all available wireless networks
               -r, --restart          restart the wifi
               -c, --connect <ssid>   connect to wireless network <ssid> (AP name)"
        if [ $# -eq 1 -a $1 == "--help" -o $1 == "-h" ]; then
          exit 0
        else
          exit 1
        fi
      fi
    fi
  fi
fi
