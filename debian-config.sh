#!/bin/bash
#
# SCRIPT: raspi-config.sh
# DESCRIPTION: Performs apt updates and sets timezone on a pre-configured Raspberry Pi OS Lite install.
#
################################################################################

set -e

# --- Configuration Variables ---
TIME_ZONE="America/Denver"    # <<< SET YOUR TIMEZONE (e.g., 'America/New_York', 'Europe/London')
# -------------------------------

# Check for root privilege
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo or as root!"
   exit 1
fi

## 1. System Updates
# ----------------------------------------------------
echo "## 1. Running System Updates and Upgrades..."
# Update package lists
sudo apt update -y
# Upgrade all installed packages
sudo apt upgrade -y

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
sudo curl -fsSL https://raw.githubusercontent.com/sloraris/server-utils/refs/heads/main/motd.sh | sudo bash

## 5. Install Docker
# ----------------------------------------------------
echo "## 5. Installing Docker"

read -r -p "Do you want to install Docker? (y/N): " docker_install_choice
if [[ "$docker_install_choice" =~ ^[Yy]$ ]]; then
    if ! command -v docker &> /dev/null; then
        echo "## Please review the Docker convenience script at https://get.docker.com before continuing."
        read -r -p "Do you want to run the Docker installation script? (y/N): " docker_script_choice
        if [[ "$docker_script_choice" =~ ^[Yy]$ ]]; then
            echo "Running convenience script..."
            sudo curl -fsSL https://get.docker.com -o ./install-docker.sh
            sudo bash ./install-docker.sh
            sudo rm ./install-docker.sh
        else
            echo "Please install Docker manually using the documentation at https://docs.docker.com/engine/install."
        fi
    else
        echo "Docker is already installed. Skipping installation script."
    fi
else
    echo "Skipping Docker install."
fi

## 6. Finalizing
# ----------------------------------------------------
echo "--- Setup Script Finished ---"
echo "Debian is now updated and configured."

read -r -p "Do you want to perform a soft reboot now? (y/N): " reboot_choice
if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
    echo "Rebooting now..."
    reboot
else
    echo "Please consider rebooting manually soon (sudo reboot)."
fi
