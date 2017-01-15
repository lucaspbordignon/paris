#!/bin/sh

# Useful
Read_lower() {
    read ANSW
    ANSW=$( echo $ANSW | tr "[:upper:]" "[:lower:]" ) # Convert to lower case
}

echo "Installing script dependencies."
pacman -S vim

echo -e "\nSetting the timezone and setting hw clock."
ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
vim /etc/locale.gen
echo "Generating locale, for language support"
locale-gen

echo -e "\nCreating a host name"
vim /etc/hostname

echo -e "\nInstalling wifi related packages and "
pacman -S iw wpa_supplicant dialog

echo -e "\nCreating root password."
passwd
echo "Create a new user?[y/n]"
Read_lower
if [ $ANSW = y ]; then
    echo "User name:"
    Read_lower
    useradd -m -G wheel -s /bin/bash $ANSW
    passwd $ANSW
fi

# Bootloader
echo -e "\nInstalling bootloader (grub)"
pacman -S grub efibootmgr
echo "Device to install: "
read ANSW
grub-install $ANSW
grub-mkconfig -o /boot/grub/grub.cfg
# Desktop Environment

# Removing this script from the system
rm second.sh
