#!/bin/bash

# Source utilities
# This is sourced from install.sh, so utils are already available.
# However, for standalone execution, this line is good practice.
source "$(dirname "$0")/00_utils.sh"

echo_msg "Configuring Pacman (multilib)"

if ask_confirmation "Do you want to enable the multilib repository? (for 32-bit support, e.g., Steam, Wine)"; then
    echo_msg "Enabling multilib repository..."
    
    # This command requires sudo. The user will be prompted for their password.
    # It finds the line with '#[multilib]' and the line below it ('#Include = ')
    # and removes the '#' comment prefix from both.
    if sudo sed -i "/^#\[multilib\]$/,/^#Include = / s/^#//" /etc/pacman.conf; then
        echo_msg "Multilib repository enabled successfully."
        echo_msg "Synchronizing package databases..."
        if sudo pacman -Syy; then
            echo_msg "Package databases synchronized."
        else
            echo_msg "Error: Failed to synchronize package databases. Please run 'sudo pacman -Syy' manually."
        fi
    else
        echo_msg "Error: Failed to edit /etc/pacman.conf. You may need to do it manually."
    fi
else
    echo_msg "Skipping multilib repository setup."
fi
