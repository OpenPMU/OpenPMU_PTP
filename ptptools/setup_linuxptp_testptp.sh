#!/bin/bash

# Configurable variables
HOME_DIR=${HOME_DIR:-/home/pi}                # Default to /home/pi if not set
TESTPTP_URL=${TESTPTP_URL:-"https://raw.githubusercontent.com/JohnORaw/TimeBandits/refs/heads/main/RPi/testptp.c"}
CURRENT_USER=$(whoami)                        # Get the current user running the script

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

# Suggest the user updates and upgrades the system
echo -e "${CYAN}>>> Suggestion: It is recommended to update and upgrade your system before running this script.${CLR_RESET}"
echo -e "${CYAN}>>> You can do so by running:${GREEN} sudo apt update && sudo apt upgrade -y${CLR_RESET}"

# Check if /dev/ptp0 exists, and only proceed with PTP-related setup if it does
if [ -e /dev/ptp0 ]; then
  echo -e "${CYAN}>>>${YELLOW} /dev/ptp0 found, proceeding with PTP-related setup.${CLR_RESET}"

  # Install LinuxPTP
  echo -e "${CYAN}>>>${YELLOW} Installing LinuxPTP...${CLR_RESET}"
  sudo apt install linuxptp -y

  # Create directory for testptp.c and download it
  echo -e "${CYAN}>>>${YELLOW} Creating directory for testptp and downloading testptp.c from $TESTPTP_URL...${CLR_RESET}"
  mkdir -p "$HOME_DIR/ptptools/"
  wget -O "$HOME_DIR/ptptools/testptp.c" "$TESTPTP_URL"

  # Compile testptp.c
  echo -e "${CYAN}>>>${YELLOW} Compiling testptp.c...${CLR_RESET}"
  gcc -o "$HOME_DIR/ptptools/testptp" "$HOME_DIR/ptptools/testptp.c"

  # Ensure the compiled file has the necessary permissions
  echo -e "${CYAN}>>>${YELLOW} Setting execute permissions on the compiled testptp file...${CLR_RESET}"
  chmod +x "$HOME_DIR/ptptools/testptp"

  # Create a group called ptpusers and add the current user to it
  echo -e "${CYAN}>>>${YELLOW} Creating group 'ptpusers' and adding the user '$CURRENT_USER' to it...${CLR_RESET}"
  sudo groupadd ptpusers
  sudo usermod -aG ptpusers "$CURRENT_USER"

  # Add a udev rule for /dev/ptp0 and assign it to ptpusers
  echo -e "${CYAN}>>>${YELLOW} Adding udev rule for /dev/ptp0 with MODE=0666...${CLR_RESET}"
  echo 'SUBSYSTEM=="ptp", KERNEL=="ptp0", GROUP="ptpusers", MODE="0666"' | sudo tee /etc/udev/rules.d/99-ptpusers.rules

  # Reload udev rules
  echo -e "${CYAN}>>>${YELLOW} Reloading udev rules...${CLR_RESET}"
  sudo udevadm control --reload-rules
  sudo udevadm trigger

  # Set the necessary capabilities for ptp4l
  echo -e "${CYAN}>>>${YELLOW} Setting capabilities for ptp4l...${CLR_RESET}"
  sudo setcap 'cap_net_admin=ep cap_net_bind_service=ep' /usr/sbin/ptp4l

  # Print completion message
  echo -e "${CYAN}>>>${GREEN} PTP setup completed successfully.${CLR_RESET}"
  echo ""
  
  # Advise the user they can now test running ptp4l without root privileges
  echo -e "${CYAN}>>> You can now test running 'ptp4l' using the following command:"
  echo -e "${CYAN}>>> ptp4l -i eth0 -s -m --uds_address /home/$CURRENT_USER/ptp4l"
  echo -e "${CYAN}>>> Note: It should not be necessary to run this command as root."

else
  echo -e "${CYAN}>>>${MAGENTA} /dev/ptp0 not found, skipping PTP-related setup."
fi
