#!/bin/sh
echo "Setting the timezone"
ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hweclock --systohc
vim /etc/locale.gen
echo "Generating locale, for language support"
locale-gen
echo "Creating a host name"
vim /etc/hostname
wifi-menu
pacman -S iw wpa_supplicant dialog
mkinitcpio -p linux
passwd
# Bootloader
echo "Installing bootloader (grub)"
pacman -S grub efibootmgr
echo "Device to install: "
Read_choice
grub-install $ANSW
grub-mkconfig -o /boot/grub/grub.cfg
echo "Defining root passwd."
passwd
# Desktop Environment
