# SnesPie Setup

**SnesPie** is a minimalist automated installer for setting up a dedicated SNES (Super Nintendo Entertainment System) emulation station on Raspberry Pi (or Debian-based systems) using RetroPie.

It strips away the bloat and installs only the essentials:
- **Core RetroPie System** (RetroArch, EmulationStation)
- **SNES Emulator** (`lr-snes9x`)

## Installation

**Important System Recommendation:** For optimal performance and to utilize pre-compiled binaries (significantly reducing installation time), it is highly recommended to use **Raspberry Pi OS (Legacy, 32-bit) based on Debian Bookworm**.

1. Clone this repository:
   ```bash
   git clone https://github.com/gab-25/SnesPie-Setup.git
   cd SnesPie-Setup
   ```

2. Make the script executable:
   ```bash
   chmod +x snespie_setup.sh
   ```

3. Run the setup script:
   ```bash
   sudo ./snespie_setup.sh
   ```

## What it does
The `snespie_setup.sh` script performs the following steps automatically:
- Installs necessary system dependencies (`git`, `lsb-release`).
- Clones the official `RetroPie-Setup` repository.
- Installs the RetroPie "Core" packages (required for EmulationStation and basic functionality).
- Installs **only** the `lr-snes9x` SNES emulator.
- Enables autostart to boot directly into EmulationStation.

## Usage
After installation is complete, reboot your system. EmulationStation will start automatically.
You can add your SNES ROMs to `~/RetroPie/roms/snes/`.
