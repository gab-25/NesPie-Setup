#!/bin/bash

# Exit on error
set -e

# Store script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# check, if sudo is used
if [[ "$(id -u)" -ne 0 ]]; then
    echo "Script must be run under sudo from the user you want to install for. Try 'sudo $0'"
    exit 1
fi

echo "Starting SnesPie Setup..."

# Install basic dependencies
echo "Installing dependencies..."
apt-get update
apt-get install -y git lsb-release

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

echo "Installing lr-snes9x..."
rp_installModule "lr-snes9x"

echo "Configuring EmulationStation settings..."
ES_SYSTEMS_DIR="/etc/emulationstation"
ES_SYSTEMS_CFG="$ES_SYSTEMS_DIR/es_systems.cfg"
ES_SETTINGS_DIR="$USER_HOME/.emulationstation"
ES_SETTINGS_CFG="$ES_SETTINGS_DIR/es_settings.cfg"

mkdir -p "$ES_SYSTEMS_DIR"
cp "$SCRIPT_DIR/configs/es_systems.cfg" "$ES_SYSTEMS_CFG"

mkdir -p "$ES_SETTINGS_DIR"
cp "$SCRIPT_DIR/configs/es_settings.cfg" "$ES_SETTINGS_CFG"
chown "$__user":"$__group" "$ES_SETTINGS_CFG"

echo "Enabling autostart..."
rp_installModule "autostart"
enable_autostart

echo "SnesPie Setup Complete!"
echo "Reboot your system to start EmulationStation."
