#!/bin/bash

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games"

path="$(dirname "$(realpath "$0")")";
initSleep=2
script="StartEstimation.py"


echo PATH: $path
cd $path

echo Initial sleep, give time for system to boot
sleep $initSleep

echo Starting loop

while true; do

echo This is a test
./testptp/testptp -d /dev/ptp0 -L 0,2
./testptp/testptp -d /dev/ptp0 -p 1000000000 -w 1000
ptp4l -i eth0 --slaveOnly 1 -m --tx_timestamp_timeout 200 --max_frequency 900000000 --step_threshold 0.1


sleep 1

done
