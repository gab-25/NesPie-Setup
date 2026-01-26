# NesPie Setup

**NesPie** is a minimalist automated installer for setting up a dedicated NES (Nintendo Entertainment System) emulation station on Raspberry Pi (or Debian-based systems) using RetroPie.

It strips away the bloat and installs only the essentials:
- **Core RetroPie System** (RetroArch, EmulationStation)
- **NES Emulator** (`lr-fceumm`)

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/gab-25/NesPie-Setup.git
   cd NesPie-Setup
   ```

2. Make the script executable:
   ```bash
   chmod +x nespie_setup.sh
   ```

3. Run the setup script:
   ```bash
   ./nespie_setup.sh
   ```

## What it does
The `nespie_setup.sh` script performs the following steps automatically:
- Installs necessary system dependencies (`git`, `lsb-release`).
- Clones the official `RetroPie-Setup` repository.
- Installs the RetroPie "Core" packages (required for EmulationStation and basic functionality).
- Installs **only** the `lr-fceumm` NES emulator.
- Enables autostart to boot directly into EmulationStation.

## Usage
After installation is complete, reboot your system. EmulationStation will start automatically.
You can add your NES ROMs to `~/RetroPie/roms/nes/`.
