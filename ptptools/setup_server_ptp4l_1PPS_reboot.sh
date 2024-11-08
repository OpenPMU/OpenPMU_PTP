#!/bin/bash

# Define paths and variables
HOME_DIR="$HOME/ptptools"
# --------------------------
SERVER_CRON_FILE="/etc/cron.d/PTP4L_server"
SERVER_LAUNCH_SCRIPT="$HOME_DIR/launchPTPserver.sh"
SERVER_SCREEN_NAME="PTP4Lserver"
# --------------------------
TS2PHC_CRON_FILE="/etc/cron.d/TS2PHC"
TS2PHC_LAUNCH_SCRIPT="$HOME_DIR/launchTS2PHC.sh"
TS2PHC_SCREEN_NAME="TS2PHC"

# Install GNU Screen
echo ">>> Installing GNU Screen..."
sudo apt-get install screen -y

# Make sure the launch scripts are executable
echo ">>> Making $SERVER_LAUNCH_SCRIPT executable..."
chmod +x "$SERVER_LAUNCH_SCRIPT"
echo ">>> Making $TS2PHC_LAUNCH_SCRIPT executable..."
chmod +x "$TS2PHC_LAUNCH_SCRIPT"

# SERVER SCRIPT CRON JOB
# ======================
CRON_FILE=$SERVER_CRON_FILE
LAUNCH_SCRIPT=$SERVER_LAUNCH_SCRIPT
SCREEN_NAME=$SERVER_SCREEN_NAME

# Add cron job to launch the script in a screen session on reboot
echo ">>> Setting up cron job to launch $LAUNCH_SCRIPT at reboot in a screen session..."

# Write the cron job to the cron.d directory
echo "PATH=/usr/bin:/bin:/usr/local/bin" | sudo tee $CRON_FILE
echo "@reboot $USER screen -dmS $SCREEN_NAME $LAUNCH_SCRIPT" | sudo tee -a $CRON_FILE

# Ensure the cron file has correct permissions
sudo chmod 644 $CRON_FILE
sudo chown root:root $CRON_FILE

echo ">>> The script will now run in a Screen session named '$SCREEN_NAME' on reboot."

# TS2PHC SCRIPT CRON JOB
# ======================
CRON_FILE=$TS2PHC_CRON_FILE
LAUNCH_SCRIPT=$TS2PHC_LAUNCH_SCRIPT
SCREEN_NAME=$TS2PHC_SCREEN_NAME

# Add cron job to launch the script in a screen session on reboot
echo ">>> Setting up cron job to launch $LAUNCH_SCRIPT at reboot in a screen session..."

# Write the cron job to the cron.d directory
echo "PATH=/usr/bin:/bin:/usr/local/bin" | sudo tee $CRON_FILE
echo "@reboot $USER screen -dmS $SCREEN_NAME $LAUNCH_SCRIPT" | sudo tee -a $CRON_FILE

# Ensure the cron file has correct permissions
sudo chmod 644 $CRON_FILE
sudo chown root:root $CRON_FILE

echo ">>> The script will now run in a Screen session named '$SCREEN_NAME' on reboot."

echo ">>> Setup complete."
