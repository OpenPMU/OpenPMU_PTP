#!/bin/bash

PATH=/bin:/usr/bin:/usr/local/bin:/usr/sbin

path="$(dirname "$(realpath "$0")")";
initSleep=5

# Define ANSI colour codes
BLACK='\e[30m'
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
MAGENTA='\e[35m'
CYAN='\e[36m'
WHITE='\e[37m'
CLR_RESET='\e[0m'


echo -e "${CYAN}>>>${YELLOW} PATH where this script is:${CLR_RESET}" $path

echo -e "${CYAN}>>>${YELLOW} Initial sleep, give time for system to boot${CLR_RESET}"
sleep $initSleep

echo -e "${CYAN}>>>${YELLOW} Starting loop${CLR_RESET}"

while true
do
        echo -e "${CYAN}>>>${GREEN} Configuring Sync0 as output${CLR_RESET}"
        $HOME/ptptools/testptp -d /dev/ptp0 -L 0,2

        echo -e "${CYAN}>>>${GREEN} Configuring Sync0 as 1PPS${CLR_RESET}"
        $HOME/ptptools/testptp -d /dev/ptp0 -p 1000000000 -w 4000

        echo -e "${CYAN}>>>${YELLOW} Launching PTP4L as client/slave clock${CLR_RESET}"
        ptp4l -i eth0 -m -q -s --uds_address $HOME/ptp4l
        sleep 1

done
