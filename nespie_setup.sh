#!/bin/bash

# Exit on error
set -e

# check, if sudo is used
if [[ "$(id -u)" -ne 0 ]]; then
    echo "Script must be run under sudo from the user you want to install for. Try 'sudo $0'"
    exit 1
fi

echo "Starting NesPie Setup..."

# Install basic dependencies
echo "Installing dependencies..."
apt-get update
apt-get install -y git lsb-release xmlstarlet

# if no user is specified
if [[ -z "$__user" ]]; then
    # get the calling user from sudo env
    __user="$SUDO_USER"
fi
export __user

USER_HOME=$(getent passwd "$__user" | cut -d: -f6)
RPS_HOME="$USER_HOME/RetroPie-Setup"
REPO_URL="https://github.com/RetroPie/RetroPie-Setup.git"
scriptdir="$RPS_HOME"

# Clone RetroPie Setup
if [ ! -d "$RPS_HOME" ]; then
    echo "Cloning RetroPie-Setup..."
    git clone --depth=1 "$REPO_URL" "$RPS_HOME"
else
    echo "RetroPie-Setup already exists. Pulling latest..."
    cd "$RPS_HOME"
    git pull
fi

# main retropie install location
rootdir="/opt/retropie"
export rootdir

if [[ -z "$__group" ]]; then
    __group="$(id -gn "$__user")"
fi
export __group

configdir="$rootdir/configs"

__builddir="$scriptdir/tmp/build"

# source the scripts with the needed functions
source "$scriptdir/scriptmodules/system.sh"
source "$scriptdir/scriptmodules/helpers.sh"
source "$scriptdir/scriptmodules/inifuncs.sh"
source "$scriptdir/scriptmodules/packages.sh"

# create config directory and retropie.cfg if they don't exist
mkdir -p "$configdir/all"
touch "$configdir/all/retropie.cfg"
chown -R "$__user":"$__group" "$rootdir"

# setup the environment
setup_env

# register all modules
rp_registerAllModules

# get the list of core packages
core_packages=$(rp_getSectionIds core)

# install each core package
echo "Installing core packages..."
__default_binary=1
for package in $core_packages; do
    echo "Installing $package..."
    rp_installModule "$package"
done

echo "Installing lr-fceumm..."
rp_installModule "lr-fceumm"

# Correct the NES ROM path in EmulationStation config
ES_SYSTEM_CONFIG="/etc/emulationstation/es_systems.cfg"
echo "Ensuring correct NES ROM path..."
xmlstarlet ed --inplace --update "/systemList/system[name='nes']/path" --value "$USER_HOME/RetroPie/roms/nes" "$ES_SYSTEM_CONFIG"

# Remove the 'retropie' system from es_systems.cfg
echo "Removing 'retropie' system from EmulationStation config..."
xmlstarlet ed --inplace --delete "/systemList/system[name='retropie']" "$ES_SYSTEM_CONFIG"

echo "Enabling autostart..."
rp_installModule "autostart"
enable_autostart

echo "Configuring EmulationStation settings..."
ES_SETTINGS_DIR="$USER_HOME/.emulationstation"
ES_SETTINGS_CFG="$ES_SETTINGS_DIR/es_settings.cfg"

mkdir -p "$ES_SETTINGS_DIR"
touch "$ES_SETTINGS_CFG"

# Ensure the settings file is a valid XML document for xmlstarlet
if ! grep -q "<settings>" "$ES_SETTINGS_CFG"; then
    echo "<settings></settings>" > "$ES_SETTINGS_CFG"
fi

chown -R "$__user":"$__group" "$ES_SETTINGS_DIR"

# Helper function to set a value in es_settings.cfg using xmlstarlet
update_es_setting() {
    # $1=file, $2=type (string/bool), $3=name, $4=value
    # Delete the node if it exists to ensure a clean state
    xmlstarlet ed --inplace --delete "/settings/${2}[@name='${3}']" "$1"
    # Add the node with its attributes
    xmlstarlet ed --inplace \
        --subnode "/settings" --type elem -n "${2}" \
        --insert "/settings/${2}[last()]" --type attr -n "name" --value "${3}" \
        --insert "/settings/${2}[@name='${3}']" --type attr -n "value" --value "${4}" \
        "$1"
}

update_es_setting "$ES_SETTINGS_CFG" "string" "UIMode" "kiosk"
update_es_setting "$ES_SETTINGS_CFG" "string" "StartupSystem" "nes"
update_es_setting "$ES_SETTINGS_CFG" "bool" "StartOnGamelist" "true"

echo "NesPie Setup Complete!"
echo "Reboot your system to start EmulationStation."
