# Module: Install Essential Packages

# Package list
PKGS="update-grub os-prober kitty waybar rofi hyprlock alsa-utils wireplumber pamixer pavucontrol nwg-look xorg-xrandr xdg-desktop-portal-hyprland imagemagick btop wallust fastfetch
ntfs-3g awww dosfstools exfatprogs plocate libnotify grim slurp wl-clipboard matugen-bin"

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
