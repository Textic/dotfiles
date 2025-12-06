# Module: Install yay (AUR Helper)

if ! command -v yay &> /dev/null; then
    if ask_confirmation "yay was not detected. Do you want to install it now?"; then
        echo_msg "Installing base dependencies (git, base-devel)..."
        sudo pacman -S --needed --noconfirm git base-devel

        echo_msg "Cloning and installing yay..."
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
        echo_msg "yay installed successfully."
    else
        echo_msg "Skipping yay installation. Note that subsequent steps might fail."
    fi
else
    echo_msg "yay is already installed."
fi