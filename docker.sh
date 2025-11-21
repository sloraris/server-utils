#!/bin/bash
#
# SCRIPT: docker.sh
# DESCRIPTION: This script prompts the user to verify the contents of the docker convenience installer script before running it.
#
################################################################################

echo "## Please review the Docker convenience script at https://get.docker.com before continuing."
read -r -p "Do you want to run the Docker installation script? (y/N): " docker_choice
if [[ "$docker_choice" =~ ^[Yy]$ ]]; then
    echo "Running convenience script..."
    curl https://get.docker.com | sudo bash
else
    echo "Please install Docker manually using the documentation at https://docs.docker.com/engine/install."
fi
