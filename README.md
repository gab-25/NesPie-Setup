# SnesPie Setup

**SnesPie** is a minimalist setup script for configuring a dedicated SNES (Super Nintendo Entertainment System) emulation station using **Batocera Linux**.

It configures Batocera to use only the SNES system with:
- **SNES Emulator** (`snes9x` via libretro)
- **Kiosk UI mode** (hides settings menus from end users)
- **SNES as the default system** at startup

## Requirements

- A device with **Batocera Linux** already installed (see [batocera.linux.com](https://batocera.linux.com) for installation instructions).

## Installation

1. Clone this repository (on your Batocera device):
   ```bash
   git clone https://github.com/gab-25/SnesPie-Setup.git
   cd SnesPie-Setup
   ```

2. Make the script executable:
   ```bash
   chmod +x batocera_setup.sh
   ```

3. Run the setup script:
   ```bash
   sudo ./batocera_setup.sh
   ```

## What it does
The `batocera_setup.sh` script performs the following steps automatically:
- Writes `configs/batocera.conf` to `/userdata/system/batocera.conf`, setting SNES as the default system and enabling kiosk mode.
- Copies `configs/es_systems.cfg` to `/userdata/system/configs/emulationstation/es_systems.cfg`, restricting EmulationStation to display only the SNES system.
- Creates the `/userdata/roms/snes/` directory for your ROM files.

## Usage
After running the script, reboot your device. Batocera will start directly into the SNES system.
Add your SNES ROMs to `/userdata/roms/snes/`.
