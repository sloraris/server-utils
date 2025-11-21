#!/bin/bash
#
# SCRIPT: raspi-config.sh
# DESCRIPTION: Performs apt updates and sets timezone on a pre-configured Raspberry Pi OS Lite install.
#
################################################################################

# --- Configuration Variables ---
TIME_ZONE="America/Denver"    # <<< SET YOUR TIMEZONE (e.g., 'America/New_York', 'Europe/London')
# -------------------------------

## 1. System Updates
# ----------------------------------------------------
echo "## 1. Running System Updates and Upgrades..."
# Update package lists
apt update -y
# Upgrade all installed packages
apt upgrade -y

## 2. Set Timezone
# ----------------------------------------------------
echo "## 2. Setting Timezone to: ${TIME_ZONE}"
timedatectl set-timezone "${TIME_ZONE}"

## 3. Disable wireless interfaces
# ----------------------------------------------------
# Use dtoverlay to disable the wireless chips on the Pi
echo "## 3. Disabling wireless interfaces"
CONFIG_FILE="/boot/firmware/config.txt"
if ! grep -q "dtoverlay=disable-wifi" "$CONFIG_FILE"; then
    echo "dtoverlay=disable-wifi" >> "$CONFIG_FILE"
    echo "-> Added disable-wifi to config.txt"
fi

if ! grep -q "dtoverlay=disable-bt" "$CONFIG_FILE"; then
    echo "dtoverlay=disable-bt" >> "$CONFIG_FILE"
    echo "-> Added disable-bt to config.txt"
fi

## 4. Configure motd
# ----------------------------------------------------
echo "## 4. Configuring ANSI motd"
curl https://raw.githubusercontent.com/sloraris/server-utils/refs/heads/main/motd.sh | bash

## 5. Install Docker
# ----------------------------------------------------
echo "## 5. Installing Docker"
curl https://raw.githubusercontent.com/sloraris/server-utils/refs/heads/main/docker.sh | bash


## 6. Finalizing
# ----------------------------------------------------
echo "--- Setup Script Finished ---"
echo "Your Pi is now updated and configured."

read -r -p "Do you want to perform a soft reboot now? (y/N): " reboot_choice
if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
    echo "Rebooting now..."
    reboot
else
    echo "Please consider rebooting manually soon (sudo reboot)."
fi
