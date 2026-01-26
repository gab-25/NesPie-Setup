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
apt-get install -y git lsb-release

RPS_HOME="$HOME/RetroPie-Setup"
REPO_URL="https://github.com/RetroPie/RetroPie-Setup.git"

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

# if no user is specified
if [[ -z "$__user" ]]; then
    # get the calling user from sudo env
    __user="$SUDO_USER"
fi

if [[ -z "$__group" ]]; then
    __group="$(id -gn "$__user")"
fi

home="$(eval echo ~$__user)"
datadir="$home/RetroPie"
biosdir="$datadir/BIOS"
romdir="$datadir/roms"
emudir="$rootdir/emulators"
configdir="$rootdir/configs"
scriptdir="$RPS_HOME"

__logdir="$scriptdir/logs"
__tmpdir="$scriptdir/tmp"
__builddir="$__tmpdir/build"

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
for package in $core_packages; do
    echo "Installing $package..."
    rp_installModule "$package"
done

echo "Installing lr-fceumm..."
rp_installModule "lr-fceumm"

echo "Enabling autostart..."
rp_installModule "autostart"
enable_autostart

echo "NesPie Setup Complete!"
echo "Reboot your system to start EmulationStation."
