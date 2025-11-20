#!/bin/bash
# ----------------------------------------------------------------------
# MOTD CUSTOMIZATION SCRIPT (Ubuntu/Debian Compatible)
#
# This script configures the dynamic MOTD by:
# 1. Removing unwanted promotional scripts (using rm -f for tolerance).
# 2. Removing the Debian-specific legal/warranty notice.
# 3. Touching Ubuntu-specific files to hide ESM/Pro messages permanently.
# 4. Installing 'toilet' and the 'ansi_shadow' font.
# 5. Creating the custom 11-ansi-hostname banner script.
# ----------------------------------------------------------------------

echo "Starting MOTD setup and cleanup..."

# --- 1. System Update and Dependency Installation ---

echo "Updating package lists and installing 'toilet'..."
sudo apt update
sudo apt install toilet curl -y

# --- 2. Dynamic MOTD Cleanup (Handling Debian/Ubuntu differences) ---

# Use rm -f (force removal, ignore missing files) for scripts that may not exist on Debian
echo "Removing unwanted promotional scripts..."

# Ubuntu Promotion/Help Text scripts
sudo rm -f /etc/update-motd.d/10-help-text
sudo rm -f /etc/update-motd.d/50-motd-news
sudo rm -f /etc/update-motd.d/91-contract-ua-esm-status
sudo rm -f /etc/update-motd.d/91-release-upgrade
sudo rm -f /etc/update-motd.d/95-hwe-eol

# Remove the Debian legal/warranty notice
sudo rm -f /etc/motd

# --- 3. Remove Ubuntu-specific update/ESM status files ---

# These files/directories are specific to Ubuntu's update-notifier and Pro service.
# Check existence before attempting to touch/remove to avoid errors.
if [ -d "/var/lib/update-notifier" ]; then
    echo "Handling Ubuntu-specific update notifier files..."
    # Permanently hides the ESM status message by marking it as seen/hidden
    sudo touch /var/lib/update-notifier/hide-esm-in-motd

    # Removes the cached file containing the list of available updates (forcing a refresh)
    sudo rm -f /var/lib/update-notifier/updates-available
fi

# --- 4. Font Download and Installation ---

# Download the ANSI Shadow font file (.flf) and place it where toilet/figlet can find it.
FONT_URL="https://raw.githubusercontent.com/xero/figlet-fonts/master/ANSI%20Shadow.flf"
FONT_DEST="/usr/share/figlet/ansi_shadow.flf"

echo "Downloading and installing ANSI Shadow font to $FONT_DEST..."
# Ensure the destination directory exists
sudo mkdir -p /usr/share/figlet
sudo curl -o "$FONT_DEST" "$FONT_URL"

# --- 5. Create Custom ANSI Hostname Script ---

# Use a heredoc with 'sudo bash -c' to write the new dynamic script file.
echo "Creating /etc/update-motd.d/11-ansi-hostname..."

# NOTE: The filename has been changed to 11-ansi-hostname as requested.
sudo bash -c 'cat > /etc/update-motd.d/11-ansi-hostname << EOF
#!/bin/sh
#
# Custom ANSI Art Banner using Toilet
#
# Runs early (11) to place the banner above system information
# and after the default OS header (00 or 10).

# Check if toilet and the font are installed before running
if command -v toilet > /dev/null 2>&1 && [ -f "/usr/share/figlet/ansi_shadow.flf" ]; then
    # Newlines for separation
    echo ""

    # Use the ANSI Shadow font with the metal filter and the system hostname
    toilet -f ansi_shadow \$(hostname) -F metal

    # Newlines for separation
    echo ""
fi

EOF'

# Make the new script executable
sudo chmod +x /etc/update-motd.d/11-ansi-hostname

echo "MOTD customization complete! Log out and log back in to see the changes."
# ----------------------------------------------------------------------
