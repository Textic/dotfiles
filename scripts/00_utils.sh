#!/bin/bash

# Function to print messages with color (Blue for title, Green for message)
echo_msg() {
    echo -e "\033[1;34m[Installer] \033[1;32m$1\033[0m"
}

# Function to ask for confirmation (Y/n)
# Returns 0 (true) for Yes, 1 (false) for No
ask_confirmation() {
    local prompt="$1"
    local response
    read -p "$prompt [Y/n]: " response
    # Default to 'Y' if enter is pressed
    response=${response:-Y}
    if [[ "$response" =~ ^[yYsS]$ ]]; then
        return 0 # True (Yes)
    else
        return 1 # False (No)
    fi
}