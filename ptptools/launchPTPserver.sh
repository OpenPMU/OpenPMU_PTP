#!/bin/bash

PATH=/bin:/usr/bin:/usr/local/bin:/usr/sbin

path="$(dirname "$(realpath "$0")")";
initSleep=5

echo ">>> PATH where this script is:" $path

echo ">>> Initial sleep, give time for system to boot"
sleep $initSleep

echo ">>> Starting loop"

while true
do
        echo ">>> Launching PTP4L as server/master clock"
        ptp4l -i eth0 --masterOnly 1 -m --tx_timestamp_timeout 200 --uds_address $HOME/ptp4l
        sleep 1

done
