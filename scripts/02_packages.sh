# Module: Install Essential Packages

# Package list
# Package list (excluding fonts)
PKGS="update-grub os-prober kitty waybar rofi hyprlock amixer alsa-utils networkmanager-dmenu-git nwg-look xorg-xrandr imagemagick btop Wallust"

# Font list
FONTS="ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd ttf-font-awesome papirus-icon-theme"

if ask_confirmation "Do you want to install the essential packages listed (kitty, waybar, hyprlock, etc.)?"; then
    echo_msg "Installing packages with yay: $PKGS"
    # We use yay to handle both official repo and AUR packages
    yay -S --needed --noconfirm $PKGS
    echo_msg "Essential packages installed."

    echo_msg "Installing fonts: $FONTS"
    yay -S --needed --noconfirm $FONTS
    echo_msg "Updating font cache..."
    sudo fc-cache -fv
    echo_msg "Fonts installed and cache updated."
else
    echo_msg "Skipping essential packages installation."
fi