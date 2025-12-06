#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to print messages with color
echo_msg() {
    echo -e "\033[1;34m[Dotfiles] \033[1;32m$1\033[0m"
}

echo_msg "Starting essentials installation script..."

# 1. Install yay (AUR Helper) if not installed
if ! command -v yay &> /dev/null; then
    echo_msg "yay not detected. Proceeding to install..."
    
    # Install dependencies needed for compilation
    echo_msg "Installing git and base-devel..."
    sudo pacman -S --needed --noconfirm git base-devel

    # Clone and install yay
    echo_msg "Cloning yay repository..."
    git clone https://aur.archlinux.org/yay.git
    cd yay
    echo_msg "Compiling and installing yay..."
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
    echo_msg "yay installed successfully."
else
    echo_msg "yay is already installed."
fi

# 2. Install requested packages
# update-grub is usually in AUR for Arch Linux
PKGS="update-grub os-prober kitty waybar rofi hyprlock amixer alsa-utils networkmanager-dmenu-git nwg-look ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd ttf-font-awesome papirus-icon-theme

echo_msg "Installing the following packages with yay: $PKGS"
yay -S --needed --noconfirm $PKGS

# 3. Deploy Configurations

# Define source and target directories
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_SRC="$DOTFILES_DIR/.config"
FONTS_SRC="$DOTFILES_DIR/fonts"

CONFIG_DEST="$HOME/.config"
FONTS_DEST="$HOME/.local/share/fonts"

# Create destination directories if they don't exist
mkdir -p "$CONFIG_DEST"
mkdir -p "$FONTS_DEST"

# Deploy .config files
if [ -d "$CONFIG_SRC" ] && [ "$(ls -A $CONFIG_SRC)" ]; then
    echo_msg "Copying configurations from $CONFIG_SRC to $CONFIG_DEST..."
    cp -r "$CONFIG_SRC/"* "$CONFIG_DEST/"
    echo_msg "Configurations deployed."
else
    echo_msg "No configurations found in $CONFIG_SRC to deploy."
fi

# Deploy fonts
if [ -d "$FONTS_SRC" ] && [ "$(ls -A $FONTS_SRC)" ]; then
    echo_msg "Copying fonts from $FONTS_SRC to $FONTS_DEST..."
    cp -r "$FONTS_SRC/"* "$FONTS_DEST/"
    
    echo_msg "Updating font cache..."
    fc-cache -fv
    echo_msg "Fonts deployed and cache updated."
else
    echo_msg "No fonts found in $FONTS_SRC to deploy."
fi

echo_msg "Essentials installation completed!"
