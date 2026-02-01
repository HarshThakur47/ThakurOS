#!/bin/bash

# FIX 1: Remove parentheses. This was creating an array, but you want a string variable.
airootfs="airootfs/etc"

# Grub
mkdir -p "$airootfs/default"
# FIX 2: Fixed typo "Şairootfs" -> "$airootfs"
# FIX 3: Check if host has grub config, otherwise create a basic one to prevent error
if [ -f "/etc/default/grub" ]; then
    cp "/etc/default/grub" "$airootfs/default/grub"
else
    echo "GRUB_DISTRIBUTOR=\"ThakurOS\"" > "$airootfs/default/grub"
    echo "GRUB_DEFAULT=0" >> "$airootfs/default/grub"
    echo "GRUB_TIMEOUT=5" >> "$airootfs/default/grub"
fi

# os-release
# FIX 4: Use -f to force overwrite if it exists
cp -rf "/usr/lib/os-release" "$airootfs/"
sed -i 's/NAME="Arch Linux"/NAME="ThakurOS Linux"/' "$airootfs/os-release"

# Wheel Group
mkdir -p "$airootfs/sudoers.d"
g_wheel="$airootfs/sudoers.d/g_wheel"
echo "%wheel ALL=(ALL:ALL) ALL" > "$g_wheel" # Added % for group syntax

# Symbolic Links
# FIX 5: Added '-f' (force) to ALL ln commands to fix "File exists" errors
## NetworkManager
mkdir -p "$airootfs/systemd/system/multi-user.target.wants"
ln -sfv "/usr/lib/systemd/system/NetworkManager.service" "$airootfs/systemd/system/multi-user.target.wants"

mkdir -p "$airootfs/systemd/system/network-online.target.wants"
ln -sfv "/usr/lib/systemd/system/NetworkManager-wait-online.service" "$airootfs/systemd/system/network-online.target.wants"

ln -sfv "/usr/lib/systemd/system/NetworkManager-dispatcher.service" "$airootfs/systemd/system/dbus.org.freedesktop.dispatcher.service"

## Bluetooth
ln -sfv "/usr/lib/systemd/system/bluetooth.service" "$airootfs/systemd/system/network-online.target.wants"

## Graphical target
# FIX 6: Fixed typo "$atrootfs" -> "$airootfs"
ln -sfv "/usr/lib/systemd/system/graphical.target" "$airootfs/systemd/system/default.target"

## SDDM
ln -sfv "/usr/lib/systemd/system/sddm.service" "$airootfs/systemd/system/display-manager.service"

# SDDM conf
mkdir -p "$airootfs/sddm.conf.d"
# FIX 7: Check if sddm.conf exists on host before reading it
if [ -f "/usr/lib/sddm.conf.d/default.conf" ]; then
    sed -n '1,35p' /usr/lib/sddm.conf.d/default.conf > "$airootfs/sddm.conf"
    sed -n '38,137p' /usr/lib/sddm.conf.d/default.conf > "$airootfs/sddm.conf.d/kde_settings.conf"
else
    echo "[General]" > "$airootfs/sddm.conf"
    echo "DisplayServer=wayland" >> "$airootfs/sddm.conf"
    echo "Numlock=on" >> "$airootfs/sddm.conf"
fi

# Desktop Environment
# Only run sed if the file exists
if [ -f "$airootfs/sddm.conf" ]; then
    sed -i 's/Session=/Session=hyprland/' "$airootfs/sddm.conf" # Changed plasma to hyprland for your build
    sed -i 's/DisplayServer=x11/DisplayServer=wayland/' "$airootfs/sddm.conf"
    # FIX 8: Added missing slash / at the end of the sed command
    sed -i 's/Numlock=none/Numlock=on/' "$airootfs/sddm.conf"
fi

# User
user=thakur
if [ -f "$airootfs/sddm.conf" ]; then
    sed -i 's/User=/User='$user'/' "$airootfs/sddm.conf"
fi

## Hostname
echo thakuros > "$airootfs/hostname"

# Adding the new user
# FIX 9: Corrected path to check airootfs/passwd (removed /etc/ since variable has it)
if grep -q "$user" "$airootfs/passwd" 2> /dev/null; then
    echo -e "\nUser Found...."
else
    # Appending to end of file is safer than '1 a' (line 1 append)
    echo "$user:x:1000:1000::/home/$user:/usr/bin/bash" >> "$airootfs/passwd"
    echo -e "\nUser not Found. Added."
fi

# Password
hash_pd=$(openssl passwd -6 ThakurOS@001)

if grep -o "$user" "$airootfs/shadow" > /dev/null; then
    echo -e "\nPassword exists, Not Modifying."
else
    echo "$user:$hash_pd:14871::::::" >> "$airootfs/shadow"
    echo -e "\nModifying the password"
fi

# Group
touch "$airootfs/group"
echo -e "root:x:0:root\nadm:x:4:$user\nwheel:x:10:$user\nuucp:x:14:$user\n$user:x:1000:$user" > "$airootfs/group"

# gshadow
touch "$airootfs/gshadow"
echo -e "root:!*::root\n$user:!*::" > "$airootfs/gshadow"

# Grub cfg
# FIX 10: Verify file exists before sed
grubcfg="grub/grub.cfg"
if [ -f "$grubcfg" ]; then
    sed -i 's/default=archlinux/default=thakuros/' "$grubcfg"
    sed -i 's/timeout=15/timeout=20/' "$grubcfg"
    sed -i 's/menuentry \"Arch/menuentry \"ThakurOS/' "$grubcfg"
    sed -i 's/play/#play/' "$grubcfg"
fi

# Entries (EFI)
# FIX 11: Check if file exists to prevent crash
efientry1="efiboot/loader/entries/01-archiso-linux.conf"
if [ -f "$efientry1" ]; then
    sed -i 's/Arch/ThakurOS/' "$efientry1"
else
    echo "Warning: $efientry1 not found. Skipping."
fi

efientry2="efiboot/loader/entries/02-speech-linux.conf"
if [ -f "$efientry2" ]; then
    sed -i 's/Arch/ThakurOS/' "$efientry2"
fi

# Loader
loaderconf="efiboot/loader/loader.conf"
if [ -f "$loaderconf" ]; then
    sed -i 's/timeout 15/timeout 20/' "$loaderconf"
    sed -i 's/beep on/beep off/' "$loaderconf"
fi
