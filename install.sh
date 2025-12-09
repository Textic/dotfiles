#!/bin/bash
set -e

# Import utilities (so echo_msg and ask_confirmation are available everywhere)
source ./scripts/00_utils.sh

echo_msg "Starting modular installation..."

# Run scripts one by one
source ./scripts/01_yay.sh
source ./scripts/02_packages.sh
source ./scripts/03_sddm.sh
source ./scripts/04_dotfiles.sh

source ./scripts/99_final.sh

echo_msg "All modules executed successfully!"