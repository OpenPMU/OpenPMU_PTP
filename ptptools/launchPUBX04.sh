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
        echo -e "${CYAN}>>>${YELLOW} Launching PUBX04 from PHC${CLR_RESET}"
        python /home/pi/ptptools/pubx04_from_phc.py
        sleep 1

done
