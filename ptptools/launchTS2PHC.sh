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
        echo ">>> Launching TS2PHC (NMEA Time Stamp to PHC)"
        ts2phc -f $HOME/ptptools/ptp.config -s nmea -m -q -l 7
        sleep 1

done
