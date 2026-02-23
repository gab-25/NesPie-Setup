#!/bin/bash

# Exit on error
set -e

# Store script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check if running as root
if [[ "$(id -u)" -ne 0 ]]; then
    echo "Script must be run as root. Try 'sudo $0'"
    exit 1
fi

echo "Starting Batocera SNES Setup..."

# Check if running on Batocera
if [ ! -d "/userdata" ]; then
    echo "Error: /userdata not found. This script is designed to run on Batocera Linux."
    exit 1
fi

BATOCERA_CONF="/userdata/system/batocera.conf"
ROMS_DIR="/userdata/roms"
ES_CONFIG_DIR="/userdata/system/configs/emulationstation"

# Create required directories
mkdir -p "$ES_CONFIG_DIR"
mkdir -p "$ROMS_DIR/snes"

# Back up existing configuration if present, then apply new one
echo "Applying Batocera configuration..."
if [ -f "$BATOCERA_CONF" ]; then
    cp "$BATOCERA_CONF" "${BATOCERA_CONF}.bak"
    echo "Existing configuration backed up to ${BATOCERA_CONF}.bak"
fi
cp "$SCRIPT_DIR/configs/batocera.conf" "$BATOCERA_CONF"

# Restrict EmulationStation to SNES only
echo "Configuring EmulationStation for SNES only..."
cp "$SCRIPT_DIR/configs/es_systems.cfg" "$ES_CONFIG_DIR/es_systems.cfg"

echo "Batocera SNES Setup Complete!"
echo "Add your SNES ROMs to $ROMS_DIR/snes/"
echo "Reboot to apply changes."
