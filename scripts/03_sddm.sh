# Module: Install and Configure SDDM Themes (Silent & Astronaut)

if ask_confirmation "Do you want to install SilentSDDM (Rei config) and Astronaut themes?"; then
    echo_msg "Starting SDDM themes installation..."

    # 1. Install SDDM dependencies for Arch (Common for both themes)
    echo_msg "Installing SDDM dependencies..."
    # Dependencies merged from both projects
    yay -S --needed --noconfirm sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg qt6-declarative qt6-5compat

    # Create temp dir for downloads
    TEMP_DIR=$(mktemp -d)

    # ==========================================
    # PART A: Install SilentSDDM (Targeting rei.conf)
    # ==========================================
    echo_msg "--- Handling SilentSDDM ---"
    echo_msg "Cloning SilentSDDM..."
    git clone -b main --depth=1 https://github.com/uiriansan/SilentSDDM "$TEMP_DIR/SilentSDDM"

    # Install SilentSDDM theme
    echo_msg "Installing SilentSDDM files..."
    sudo mkdir -p /usr/share/sddm/themes/silent
    sudo cp -rf "$TEMP_DIR/SilentSDDM/." /usr/share/sddm/themes/silent/

    # Install SilentSDDM fonts
    echo_msg "Installing SilentSDDM fonts..."
    sudo mkdir -p /usr/share/fonts/SilentSDDM
    if [ -d "$TEMP_DIR/SilentSDDM/fonts" ]; then
        sudo cp -r "$TEMP_DIR/SilentSDDM/fonts/"* /usr/share/fonts/SilentSDDM/
    elif [ -d "/usr/share/sddm/themes/silent/fonts" ]; then
        sudo cp -r /usr/share/sddm/themes/silent/fonts/* /usr/share/fonts/SilentSDDM/
    fi

    # Configure Avatar using the included script
    # We assume 'assets' folder is located one level up from this script (e.g., inside dotfiles root)
    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    PROFILE_IMG="$SCRIPT_DIR/../assets/profile.png"
    CURRENT_USER=$(whoami)

    echo_msg "Configuring Avatar for user: $CURRENT_USER..."
    
    if [ -f "$PROFILE_IMG" ]; then
        echo_msg "Found profile image at: $PROFILE_IMG"
        # The change_avatar.sh script is inside the cloned repo
        AVATAR_SCRIPT="$TEMP_DIR/SilentSDDM/change_avatar.sh"
        
        if [ -f "$AVATAR_SCRIPT" ]; then
            chmod +x "$AVATAR_SCRIPT"
            # Execute change_avatar.sh <username> <image_path>
            # Note: The script uses sudo internally
            "$AVATAR_SCRIPT" "$CURRENT_USER" "$PROFILE_IMG"
        else
            echo_msg "WARNING: change_avatar.sh not found in downloaded files."
        fi
    else
        echo_msg "WARNING: Profile image not found at '$PROFILE_IMG'. Skipping avatar setup."
    fi

    # Configure SilentSDDM to use rei.conf if available
    echo_msg "Setting SilentSDDM variant to 'rei'..."
    TARGET_CONFIG="rei.conf"
    METADATA_FILE="/usr/share/sddm/themes/silent/metadata.desktop"
    
    # Try to find where the config file is located inside the theme
    REI_PATH=$(find /usr/share/sddm/themes/silent -name "$TARGET_CONFIG" | head -n 1)

    if [ -n "$REI_PATH" ]; then
        # Extract relative path for metadata.desktop (e.g., Themes/rei.conf)
        REL_PATH=$(realpath --relative-to="/usr/share/sddm/themes/silent" "$REI_PATH")
        echo_msg "Found $TARGET_CONFIG at $REL_PATH. Applying..."
        sudo sed -i "s|^ConfigFile=.*|ConfigFile=$REL_PATH|" "$METADATA_FILE"
    else
        echo_msg "WARNING: $TARGET_CONFIG not found in SilentSDDM. Using default configuration."
    fi

    # ==========================================
    # PART B: Install sddm-astronaut-theme
    # ==========================================
    echo_msg "--- Handling sddm-astronaut-theme ---"
    echo_msg "Cloning sddm-astronaut-theme..."
    git clone -b master --depth=1 https://github.com/Keyitdev/sddm-astronaut-theme "$TEMP_DIR/sddm-astronaut-theme"

    # Install Astronaut theme
    echo_msg "Installing Astronaut theme files..."
    sudo mkdir -p /usr/share/sddm/themes/sddm-astronaut-theme
    sudo cp -rf "$TEMP_DIR/sddm-astronaut-theme/." /usr/share/sddm/themes/sddm-astronaut-theme/

    # Install Astronaut fonts
    echo_msg "Installing Astronaut fonts..."
    sudo mkdir -p /usr/share/fonts/sddm-astronaut-theme
    if [ -d "$TEMP_DIR/sddm-astronaut-theme/Fonts" ]; then
        sudo cp -r "$TEMP_DIR/sddm-astronaut-theme/Fonts/"* /usr/share/fonts/sddm-astronaut-theme/
    fi

    # ==========================================
    # PART C: Final Configuration
    # ==========================================
    
    echo_msg "Updating font cache..."
    fc-cache -fv

    echo_msg "Configuring /etc/sddm.conf..."
    # Backup existing config
    if [ -f /etc/sddm.conf ]; then
        sudo cp /etc/sddm.conf /etc/sddm.conf.bak
    fi

    # Write configuration
    # We set Current=silent because we configured 'rei.conf' inside 'silent' theme metadata.
    sudo bash -c 'cat > /etc/sddm.conf <<EOF
[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard

[Theme]
Current=silent
EOF'

    # Cleanup
    rm -rf "$TEMP_DIR"
    echo_msg "SDDM themes installed. Active theme: Silent (Rei config)."
    echo_msg "Note: The Astronaut theme is also installed in /usr/share/sddm/themes/sddm-astronaut-theme if you want to switch later."
else
    echo_msg "Skipping SDDM themes installation."
fi