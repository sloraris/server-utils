#!/bin/bash
#
# SCRIPT: docker.sh
# DESCRIPTION: This script prompts the user to verify the contents of the docker convenience installer script before running it.
#
################################################################################

set -e

echo "## Please review the Docker convenience script at https://get.docker.com before continuing."

read -r -p "Do you want to run the Docker installation script? (y/N): " docker_choice
if [[ "$docker_choice" =~ ^[Yy]$ ]]; then
    echo "Running convenience script..."
    curl -fsSL https://get.docker.com -o /tmp/install-docker.sh
    sudo sh /tmp/install-docker.sh
    rm /tmp/install-docker.sh
else
    echo "Please install Docker manually using the documentation at https://docs.docker.com/engine/install."
fi
