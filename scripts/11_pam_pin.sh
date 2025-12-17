#!/bin/bash

# Module: Configure PIN Authentication for Sudo, SDDM, and Hyprlock

if ask_confirmation "Do you want to configure a short PIN for Sudo, SDDM, and Hyprlock?"; then
    echo_msg "Installing dependencies (libpam_pwdfile, whois)..."
    
    # 'whois' es necesario para el comando mkpasswd
    if yay -Si libpam-pwdfile-git &> /dev/null; then
        yay -S --needed --noconfirm libpam-pwdfile-git whois
    else
        # Fallback a otros nombres posibles
        yay -S --needed --noconfirm pam_pwdfile whois
    fi

    # 1. Get PIN from user
    echo -e "\033[1;33m" # Yellow color
    read -s -p "Enter your desired PIN (input will be hidden): " USER_PIN
    echo -e "\033[0m" # Reset color
    echo ""
    
    if [ -z "$USER_PIN" ]; then
        echo_msg "Error: PIN cannot be empty. Aborting."
        exit 1
    fi

    # 2. Generate Hash and Create Auth File
    AUTH_FILE="/etc/auth_pin"
    CURRENT_USER=$(whoami)
    
    echo_msg "Generating hash and creating secure file at $AUTH_FILE..."
    
    # Generate SHA-512 hash
    PIN_HASH=$(mkpasswd -m sha-512 "$USER_PIN")
    
    # Create file if not exists
    if [ ! -f "$AUTH_FILE" ]; then
        sudo touch "$AUTH_FILE"
    fi
    
    # Set strict permissions (only root can read)
    sudo chmod 600 "$AUTH_FILE"
    
    # Write user:hash to file
    sudo sh -c "echo '$CURRENT_USER:$PIN_HASH' > $AUTH_FILE"
    
    echo_msg "PIN file created successfully."

    # Define the PAM line to insert
    PAM_LINE="auth    sufficient  pam_pwdfile.so pwdfile=$AUTH_FILE"

    # Function to apply PAM config safely
    configure_pam() {
        local TARGET_FILE="$1"
        local SERVICE_NAME="$2"

        # Check if file exists, if not create a default one (useful for hyprlock)
        if [ ! -f "$TARGET_FILE" ]; then
            echo_msg "$TARGET_FILE not found. Creating default configuration..."
            # Default minimal config referencing system-auth
            sudo bash -c "echo 'auth include system-auth' > $TARGET_FILE"
        fi

        if grep -q "pam_pwdfile.so" "$TARGET_FILE"; then
            echo_msg "PAM PIN already configured for $SERVICE_NAME. Skipping."
        else
            echo_msg "Configuring $SERVICE_NAME ($TARGET_FILE)..."
            sudo cp "$TARGET_FILE" "$TARGET_FILE.bak"
            
            # Insert at the very top (line 1) or strictly before other auth modules
            # Using '1i' puts it at the very first line.
            sudo sed -i "1i $PAM_LINE" "$TARGET_FILE"
        fi
    }

    # 3. Configure PAM for SUDO
    configure_pam "/etc/pam.d/sudo" "sudo"

    # 4. Configure PAM for SDDM
    configure_pam "/etc/pam.d/sddm" "sddm"

    # 5. Configure PAM for HYPRLOCK
    # Hyprlock uses /etc/pam.d/hyprlock. If it doesn't exist, it fails or fallbacks badly.
    configure_pam "/etc/pam.d/hyprlock" "hyprlock"

    echo_msg "PIN Authentication configured successfully!"
    echo_msg "You can now use your PIN for: Sudo, SDDM Login, and Hyprlock screen unlock."

else
    echo_msg "Skipping PIN configuration."
fi