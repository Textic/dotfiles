# Module: Download and Install Wallpapers

# Variables based on your configuration
REPO_URL="https://github.com/santoshxshrestha/wallpaper-archive"
WALLPAPER_DIR="$HOME/.config/wallpapers"

if ask_confirmation "Do you want to download and install wallpapers from github?"; then
    # Ensure the destination directory exists
    if [ ! -d "$WALLPAPER_DIR" ]; then
        echo_msg "Creating directory $WALLPAPER_DIR..."
        mkdir -p "$WALLPAPER_DIR"
    fi

    echo_msg "Starting repository download..."
    TEMP_DIR=$(mktemp -d)
    
    # Clone the repo into a temporary folder to keep your system clean
    git clone --depth 1 "$REPO_URL" "$TEMP_DIR/wallpaper-archive"

    echo_msg "Copying images (static and animated) to $WALLPAPER_DIR..."

    # Recursively find image files compatible with your selector (jpg, png, gif, webp)
    # The -n flag in cp prevents overwriting if you already have an image with the same name
    find "$TEMP_DIR/wallpaper-archive" -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) \
        -exec cp -n -v {} "$WALLPAPER_DIR" \;

    echo_msg "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"

    echo_msg "Done! The images have been added."
    
    # Notification using your existing system configuration
    notify-send "Wallpaper Downloader" "New wallpapers downloaded from santoshxshrestha/wallpaper-archive"
else
    echo_msg "Skipping wallpaper installation."
fi