# Module: Install and Configure SilentSDDM Theme

if ask_confirmation "Do you want to automatically install and configure the SilentSDDM theme (requires sudo)?"; then
    echo_msg "Starting SilentSDDM installation..."

    # 1. Install SDDM dependencies for Arch
    # Based on the official README requirements
    echo_msg "Installing SDDM dependencies..."
    yay -S --needed --noconfirm sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg

    # 2. Clone repo to a temp folder to avoid cluttering
    TEMP_DIR=$(mktemp -d)
    echo_msg "Cloning SilentSDDM into $TEMP_DIR..."
    git clone -b main --depth=1 https://github.com/uiriansan/SilentSDDM "$TEMP_DIR/SilentSDDM"
    
    # 3. Copy theme to /usr/share/sddm/themes/
    echo_msg "Copying theme files..."
    sudo mkdir -p /usr/share/sddm/themes/silent
    sudo cp -rf "$TEMP_DIR/SilentSDDM/." /usr/share/sddm/themes/silent/

    # 4. Install fonts
    echo_msg "Installing theme fonts..."
    sudo mkdir -p /usr/share/fonts/SilentSDDM
    sudo cp -r /usr/share/sddm/themes/silent/fonts/* /usr/share/fonts/SilentSDDM/
    echo_msg "Updating font cache..."
    fc-cache -fv

    # 5. Configure /etc/sddm.conf
    echo_msg "Configuring /etc/sddm.conf..."
    
    # Backup existing config if it exists
    if [ -f /etc/sddm.conf ]; then
        echo_msg "Backup created at /etc/sddm.conf.bak"
        sudo cp /etc/sddm.conf /etc/sddm.conf.bak
    fi

    # Write the recommended configuration
    # This sets the theme and the virtual keyboard environment
    sudo bash -c 'cat > /etc/sddm.conf <<EOF
[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard

[Theme]
Current=silent
EOF'

    # 6. Cleanup
    rm -rf "$TEMP_DIR"
    echo_msg "SilentSDDM installed and configured successfully."
else
    echo_msg "Skipping SilentSDDM installation."
fi