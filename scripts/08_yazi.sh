# Module: Install Yazi and dependencies

# Dependencies list based on Yazi documentation
# Core: yazi, file
# Extensions/Preview: ffmpeg, 7zip, jq, poppler, fd, ripgrep, fzf, zoxide, imagemagick
# Clipboard: wl-clipboard (since we are on Hyprland/Wayland)
# SVG: resvg (if available, otherwise yay handles it)

YAZI_PKGS="yazi file ffmpeg 7zip jq poppler fd ripgrep fzf zoxide imagemagick wl-clipboard"

if ask_confirmation "Do you want to install Yazi and its dependencies?"; then
    echo_msg "Installing Yazi packages: $YAZI_PKGS"
    yay -S --needed --noconfirm $YAZI_PKGS
    echo_msg "Yazi and dependencies installed."
else
    echo_msg "Skipping Yazi installation."
fi
