# Module: Deploy Dotfiles (Configurations and Fonts)

if ask_confirmation "Do you want to deploy your configuration files (config) and local fonts?"; then
    # Define source and target directories
    # We use 'dirname' on the main script path or assume we are running from root of the repo
    # Since this is sourced, BASH_SOURCE[0] might refer to this file itself.
    # To be safe, we assume the script is run from the root of the repo, or we look relative to this file.
    
    # Getting the root of the repo (assuming scripts/04_dotfiles.sh structure)
    CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    REPO_ROOT="$(dirname "$CURRENT_SCRIPT_DIR")"
    
    CONFIG_SRC="$REPO_ROOT/config"
    FONTS_SRC="$REPO_ROOT/fonts"

    CONFIG_DEST="$HOME/.config"
    FONTS_DEST="$HOME/.local/share/fonts"

    # Create destination directories if they don't exist
    mkdir -p "$CONFIG_DEST"
    mkdir -p "$FONTS_DEST"

    # 1. Deploy .config files
    if [ -d "$CONFIG_SRC" ] && [ "$(ls -A $CONFIG_SRC)" ]; then
        echo_msg "Copying configurations from $CONFIG_SRC to $CONFIG_DEST..."
        cp -r "$CONFIG_SRC/"* "$CONFIG_DEST/"
        echo_msg "Configurations deployed."
    else
        echo_msg "No configurations found in $CONFIG_SRC to deploy."
    fi

    # 2. Deploy fonts
    if [ -d "$FONTS_SRC" ] && [ "$(ls -A $FONTS_SRC)" ]; then
        echo_msg "Copying fonts from $FONTS_SRC to $FONTS_DEST..."
        cp -r "$FONTS_SRC/"* "$FONTS_DEST/"
        
        echo_msg "Updating font cache..."
        fc-cache -fv
        echo_msg "Fonts deployed."
    else
        echo_msg "No fonts found in $FONTS_SRC to deploy."
    fi
else
    echo_msg "Skipping dotfiles deployment."
fi