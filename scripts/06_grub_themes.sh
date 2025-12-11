#!/bin/bash

# Get the directory of the currently running script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


if ask_confirmation "Do you want to install GRUB themes and set 'yorha-1920x1080' as default?"; then
    echo_msg "Starting GRUB themes installation..."
    
    # Define paths
    # Assuming the script is in dotfiles/scripts/ and themes are in dotfiles/grub/themes/
    DOTFILES_ROOT="$SCRIPT_DIR/.."
    GRUB_THEMES_SRC="$DOTFILES_ROOT/grub/themes"
    GRUB_THEMES_DEST="/boot/grub/themes"
    TARGET_THEME_NAME="yorha-1920x1080"
    
    # Check source directory
    if [ ! -d "$GRUB_THEMES_SRC" ]; then
        echo_msg "Error: Source directory '$GRUB_THEMES_SRC' not found."
        echo_msg "Please ensure the themes are in '$DOTFILES_ROOT/grub/themes'."
        exit 1
    fi

    # Create destination directory if it doesn't exist
    if [ ! -d "$GRUB_THEMES_DEST" ]; then
        echo_msg "Creating destination directory: $GRUB_THEMES_DEST"
        sudo mkdir -p "$GRUB_THEMES_DEST"
    fi

    # Copy all themes
    echo_msg "Copying themes from '$GRUB_THEMES_SRC' to '$GRUB_THEMES_DEST'..."
    # Using specific copy to avoid copying the directory itself into itself if bad paths, 
    # and ensuring we just update/add themes.
    sudo cp -r "$GRUB_THEMES_SRC/"* "$GRUB_THEMES_DEST/"

    # Verify target theme exists in destination
    THEME_FILE_PATH="$GRUB_THEMES_DEST/$TARGET_THEME_NAME/theme.txt"
    if [ ! -f "$THEME_FILE_PATH" ]; then
        echo_msg "Error: The target theme file '$THEME_FILE_PATH' was not found after copy."
        echo_msg "Skipping configuration update."
        exit 1
    else
        echo_msg "Target theme found: $THEME_FILE_PATH"
    fi

    # Configure /etc/default/grub
    GRUB_CONFIG="/etc/default/grub"
    echo_msg "Configuring $GRUB_CONFIG..."
    
    # Backup existing config
    sudo cp "$GRUB_CONFIG" "$GRUB_CONFIG.bak.$(date +%F_%T)"
    
    # Update GRUB_THEME line
    # If GRUB_THEME is set (commented or not), replace it. 
    # If not present at all, append it.
    if grep -q "^[#]*GRUB_THEME=" "$GRUB_CONFIG"; then
        sudo sed -i "s|^[#]*GRUB_THEME=.*|GRUB_THEME=\"$THEME_FILE_PATH\"|" "$GRUB_CONFIG"
    else
        echo "GRUB_THEME=\"$THEME_FILE_PATH\"" | sudo tee -a "$GRUB_CONFIG" > /dev/null
    fi
    
    echo_msg "GRUB_THEME set to '$THEME_FILE_PATH'."

    # Update GRUB_DISABLE_OS_PROBER line
    # If GRUB_DISABLE_OS_PROBER is set (commented or not), replace it.
    # If not present at all, append it.
    if grep -q "^[#]*GRUB_DISABLE_OS_PROBER=" "$GRUB_CONFIG"; then
        sudo sed -i "s|^[#]*GRUB_DISABLE_OS_PROBER=.*|GRUB_DISABLE_OS_PROBER=false|" "$GRUB_CONFIG"
    else
        echo "GRUB_DISABLE_OS_PROBER=false" | sudo tee -a "$GRUB_CONFIG" > /dev/null
    fi
    echo_msg "GRUB_DISABLE_OS_PROBER set to 'false'."

    # Update GRUB bootloader
    echo_msg "Updating GRUB bootloader..."
    if command -v update-grub &> /dev/null; then
        sudo update-grub
    elif command -v grub-mkconfig &> /dev/null; then
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    else
        echo_msg "Warning: Could not find 'update-grub' or 'grub-mkconfig'. Please update GRUB manually."
    fi

    echo_msg "GRUB theme installation and configuration complete!"
else
    echo_msg "Skipping GRUB themes installation."
fi
