#!/bin/bash

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

# Install lldpad
echo -e "${CYAN}>>>${YELLOW} Installing lldpad...${CLR_RESET}"
sudo apt-get install -y lldpad
echo -e "${CYAN}>>>${YELLOW} Installing lldpd...${CLR_RESET}"
sudo apt-get install -y lldpd

# Start lldpad service
echo -e "${CYAN}>>>${YELLOW} Starting lldpad service...${CLR_RESET}"
lldpad -d

# Find network interfaces and enable LLDP
echo -e "${CYAN}>>>${YELLOW} Finding network interfaces and enabling LLDP...${CLR_RESET}"
for i in $(ls /sys/class/net/ | grep 'eth\|ens\|eno') ;
do
  echo "Enabling LLDP for interface: $i" ;
  sudo lldptool set-lldp -i $i adminStatus=rxtx ;
  sudo lldptool -T -i $i -V sysName enableTx=yes ;
  sudo lldptool -T -i $i -V portDesc enableTx=yes ;
  sudo lldptool -T -i $i -V sysDesc enableTx=yes ;
  sudo lldptool -T -i $i -V sysCap enableTx=yes ;
  sudo lldptool -T -i $i -V mngAddr enableTx=yes ;
done

echo -e "${CYAN}>>>${GREEN} LLDP has been configured successfully.${CLR_RESET}"


# PI Commands
echo -e "${CYAN}>>>${WHITE} If you're on a Raspberry Pi and want to identify the port you're connected to, use the following commands:${CLR_RESET}"
echo -e "${CYAN}>>>${WHITE} --- ${CYAN}sudo lldpcli show neighbors${CLR_RESET}"
echo -e "${CYAN}>>>${WHITE} --- ${CYAN}sudo lldpcli show neighbors${CLR_RESET}"