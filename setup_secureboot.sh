#!/bin/bash

# ==============================================================================
# Arch Linux Secure Boot Setup Script (Shim + GRUB Monolithic)
# ==============================================================================

# --- Configuration Variables ---
DISK="/dev/nvme0n1"           # Your Disk
EFI_PART_NUM="6"              # Your EFI Partition Number
EFI_MOUNT="/boot"             # Where your EFI partition is mounted
KEY_DIR="/etc/secureboot"     # Directory for MOK keys
GRUB_EFI_DIR="$EFI_MOUNT/EFI/GRUB"
GRUB_MOD_DIR="/boot/grub/x86_64-efi"

# Modules list for Monolithic GRUB (Shim Lock bypass)
GRUB_MODULES="all_video boot btrfs cat chain configfile echo efifwsetup efinet ext2 fat font gettext gfxmenu gfxterm gfxterm_background gzio halt help iso9660 jpeg keystatus loadenv loopback linux ls lsefi lsefimmap lsefisystab minicmd normal ntfs part_msdos part_gpt password_pbkdf2 png probe reboot regexp search search_fs_uuid search_fs_file search_label sleep smbios test true video"

# --- 1. Permissions & Dependencies Check ---

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root."
   exit 1
fi

echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
read -p "Do you want to DELETE existing keys and configurations to start from scratch? (y/N): " choice
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

case "$choice" in 
  y|Y|s|S ) 
    echo "-> Deleting old keys in $KEY_DIR..."
    rm -rf "$KEY_DIR"
    
    echo "-> Attempting to clean old 'Arch Secure Boot' entries in NVRAM..."
    # This finds the entry and deletes it to avoid duplicates
    efibootmgr | grep "Arch Secure Boot" | awk '{print $1}' | sed 's/*//' | xargs -I {} efibootmgr -b {} -B > /dev/null 2>&1
    
    echo "-> Cleanup complete. New keys will be generated."
    ;;
  * ) 
    echo "-> Keeping existing files (if any)."
    ;;
esac

echo "========================================================"
echo " STEP 1: Installing/Verifying Dependencies"
echo "========================================================"

# Install official packages automatically
echo "-> Updating repositories and installing official tools..."
pacman -Sy --needed --noconfirm grub efibootmgr sbsigntools openssl mokutil

# If /etc/default/grub is missing, force reinstalling grub to restore it
if [ ! -f /etc/default/grub ]; then
    echo "-> /etc/default/grub is missing. Reinstalling 'grub' to restore it..."
    pacman -S --noconfirm grub
fi

# Check for shim-signed (AUR package)
# We cannot install AUR packages as root easily/safely, so we just check for it.
if [ ! -f /usr/share/shim-signed/shimx64.efi ]; then
    echo ""
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo " ERROR: 'shim-signed' is missing!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo " This package is in the AUR. Since this script runs as root,"
    echo " it cannot safely install AUR packages."
    echo ""
    echo " PLEASE RUN THIS MANUALLY (as a normal user) BEFORE CONTINUING:"
    echo "    yay -S shim-signed"
    echo "    (or use your preferred AUR helper)"
    echo ""
    exit 1
else
    echo "-> 'shim-signed' is found. Proceeding..."
fi

# ==============================================================================
# 2. Key Generation
# ==============================================================================
echo ""
echo "========================================================"
echo " STEP 2: Setting up Keys in $KEY_DIR"
echo "========================================================"
mkdir -p "$KEY_DIR"

if [ -f "$KEY_DIR/MOK.key" ]; then
    echo "-> Existing keys found. Using them."
else
    echo "-> Generating new MOK keys..."
    openssl req -new -x509 -newkey rsa:2048 \
    -keyout "$KEY_DIR/MOK.key" \
    -out "$KEY_DIR/MOK.crt" \
    -nodes -days 3650 \
    -subj "/CN=ArchLinuxMOK/"
    echo "-> Keys generated successfully."
fi

echo "-> Converting certificate to DER format (required for BIOS)..."
openssl x509 -in "$KEY_DIR/MOK.crt" -out "$KEY_DIR/MOK.der" -outform DER

echo "-> Importing key to MOK registry..."
echo "--------------------------------------------------------"
echo " ACTION REQUIRED: Enter a one-time password below."
echo " REMEMBER THIS PASSWORD. You will need it after reboot."
echo " TYPE AN EASY PASSWORD, LIKE '1234' OR 'password'"
echo "--------------------------------------------------------"
mokutil --import "$KEY_DIR/MOK.der"

# ==============================================================================
# 3. GRUB Installation (Monolithic)
# ==============================================================================
echo ""
echo "========================================================"
echo " STEP 3: Installing GRUB (Monolithic Mode)"
echo "========================================================"

# We use embedded modules to avoid 'prohibited by secure boot policy'
grub-install --target=x86_64-efi \
    --efi-directory="$EFI_MOUNT" \
    --bootloader-id=GRUB \
    --modules="$GRUB_MODULES" \
    --sbat /usr/share/grub/sbat.csv

if [ $? -eq 0 ]; then
    echo "-> GRUB installed successfully."
else
    echo "-> Error installing GRUB."
    exit 1
fi

# ==============================================================================
# 4. Signing Binaries
# ==============================================================================
echo ""
echo "========================================================"
echo " STEP 4: Signing GRUB and Kernel"
echo "========================================================"

echo "-> Signing GRUB binary..."
sbsign --key "$KEY_DIR/MOK.key" \
       --cert "$KEY_DIR/MOK.crt" \
       --output "$GRUB_EFI_DIR/grubx64.efi" \
       "$GRUB_EFI_DIR/grubx64.efi"

echo "-> Signing all GRUB modules (This prevents 'prohibited by policy' errors)..."
GRUB_MOD_DIR="/boot/grub/x86_64-efi"

if [ -d "$GRUB_MOD_DIR" ]; then
    find "$GRUB_MOD_DIR" -name "*.mod" -print0 | while IFS= read -r -d '' module; do
        sbsign --key "$KEY_DIR/MOK.key" \
               --cert "$KEY_DIR/MOK.crt" \
               --output "$module" \
               "$module"
    done
    echo "-> All modules signed successfully."
else
    echo "WARNING: Could not find modules in $GRUB_MOD_DIR"
fi

echo "-> Signing the current kernel..."
if [ -f "$EFI_MOUNT/vmlinuz-linux" ]; then
    sbsign --key "$KEY_DIR/MOK.key" \
           --cert "$KEY_DIR/MOK.crt" \
           --output "$EFI_MOUNT/vmlinuz-linux" \
           "$EFI_MOUNT/vmlinuz-linux"
    echo "-> Kernel signed."
else
    echo "-> WARNING: vmlinuz-linux not found in $EFI_MOUNT. Skipping."
fi

# ==============================================================================
# 5. Shim Setup & Boot Entry
# ==============================================================================
echo ""
echo "========================================================"
echo " STEP 5: Setting up Shim and Boot Entry"
echo "========================================================"

echo "-> Copying Shim and MokManager..."
cp /usr/share/shim-signed/shimx64.efi "$GRUB_EFI_DIR/shimx64.efi"
cp /usr/share/shim-signed/mmx64.efi "$GRUB_EFI_DIR/mmx64.efi"

echo "-> Creating UEFI Boot Entry for Shim..."
# Cleanup old entries if needed (commented out for safety)
# efibootmgr | grep "Arch Secure Boot" | awk '{print $1}' | sed 's/*//' | xargs -I {} efibootmgr -b {} -B > /dev/null 2>&1

efibootmgr --create --disk "$DISK" --part "$EFI_PART_NUM" \
    --label "Arch Secure Boot" \
    --loader /EFI/GRUB/shimx64.efi

# ==============================================================================
# 6. Automation Hook
# ==============================================================================
echo ""
echo "========================================================"
echo " STEP 6: Creating Pacman Hook"
echo "========================================================"
mkdir -p /etc/pacman.d/hooks

cat <<EOF > /etc/pacman.d/hooks/99-secureboot.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = linux
# Target = linux-lts

[Action]
Description = Signing Kernel for Secure Boot
When = PostTransaction
Exec = /usr/bin/sbsign --key $KEY_DIR/MOK.key --cert $KEY_DIR/MOK.crt --output /boot/vmlinuz-linux /boot/vmlinuz-linux
Depends = sbsigntools
EOF

echo "-> Hook created at /etc/pacman.d/hooks/99-secureboot.hook"


# echo ""
# echo "========================================================"
# echo " STEP 6: Creating Pacman Hook"
# echo "========================================================"
# mkdir -p /etc/pacman.d/hooks

# cat <<EOF > /etc/pacman.d/hooks/98-sign-grub-modules.hook
# [Trigger]
# Operation = Install
# Operation = Upgrade
# Type = Package
# Target = grub

# [Action]
# Description = Signing GRUB Modules for Secure Boot
# When = PostTransaction
# Exec = /bin/sh -c 'find /boot/grub/x86_64-efi -name "*.mod" -exec sbsign --key $KEY_DIR/MOK.key --cert $KEY_DIR/MOK.crt --output {} {} \;'
# Depends = sbsigntools
# EOF

# echo "-> GRUB modules hook created at /etc/pacman.d/hooks/98-sign-grub-modules.hook"

# ==============================================================================
# DONE
# ==============================================================================
echo ""
echo "##########################################################"
echo " SETUP COMPLETE!"
echo "##########################################################"
echo " Next steps:"
echo " 1. Reboot."
echo " 2. Ensure Secure Boot is ON in BIOS."
echo " 3. On the blue 'Shim UEFI key management' screen:"
echo "    Enroll MOK -> View key 0 -> Continue -> Yes."
echo "##########################################################"
