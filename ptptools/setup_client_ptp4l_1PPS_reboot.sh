#!/bin/bash

# Define paths and variables
HOME_DIR="$HOME/ptptools"
LAUNCH_SCRIPT="$HOME_DIR/launchPTPclient.sh"
CRON_FILE="/etc/cron.d/PTP4L_client"
SCREEN_NAME="PTP4Lclient"

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

# Install GNU Screen
echo -e "${CYAN}>>>${YELLOW} Installing GNU Screen...${CLR_RESET}"
sudo apt-get install screen -y

# Make sure the launch script is executable
echo -e "${CYAN}>>>${YELLOW} Making $LAUNCH_SCRIPT executable...${CLR_RESET}"
chmod +x "$LAUNCH_SCRIPT"

# Add cron job to launch the script in a screen session on reboot
echo -e "${CYAN}>>>${YELLOW} Setting up cron job to launch $LAUNCH_SCRIPT at reboot in a screen session...${CLR_RESET}"

# Write the cron job to the cron.d directory
echo "PATH=/usr/bin:/bin:/usr/local/bin" | sudo tee $CRON_FILE
echo "@reboot $USER screen -dmS $SCREEN_NAME $LAUNCH_SCRIPT" | sudo tee -a $CRON_FILE

# Ensure the cron file has correct permissions
sudo chmod 644 $CRON_FILE
sudo chown root:root $CRON_FILE

echo -e "${CYAN}>>>${GREEN} Setup complete. The script will now run in a Screen session named '$SCREEN_NAME' on reboot.${CLR_RESET}"
