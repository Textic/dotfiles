#!/bin/bash

echo_msg "Running final steps (99)..."

if [ -f /usr/bin/awww-daemon ]; then
    echo_msg "Creating symbolic link from awww-daemon to swww-daemon..."
    sudo ln -sf /usr/bin/awww-daemon /usr/bin/swww-daemon
else
    echo_msg "Warning: /usr/bin/awww-daemon not found. Skipping link."
fi

if [ -f /usr/bin/awww ]; then
    echo_msg "Creating symbolic link from awww to swww..."
    sudo ln -sf /usr/bin/awww /usr/bin/swww
else
    echo_msg "Warning: /usr/bin/awww not found. Skipping link."
fi

echo_msg "Final steps completed."

if ask_confirmation "Do you want to reboot to apply all changes?"; then
    echo_msg "Rebooting now..."
    sudo reboot
fi