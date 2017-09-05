#!/bin/sh


# Useful
Read_lower() {
    read ANSW
    ANSW=$( echo $ANSW | tr "[:upper:]" "[:lower:]" ) # Convert to lower case
}

Install_gnome() {
   pacman -S gnome-shell gdm arc-icon-theme termite gnome-control-center networkmanager
   systemctl enable gdm
   systemctl enable NetworkManager
}

Install_i3() {
    ANSW=n
    while [ $ANSW != y ]; do
        echo "User to be added the 'exec i3' command (username):"
        read ANSW
        USER_NAME=$ANSW
        echo "Username is $USER_NAME, right? [y/n]"
        Read_lower
    done 
    pacman -S i3 gdm
    echo "exec i3" >> /home/$USER_NAME/.xinitrc 
    systemctl enable gdm
}

###############################################################################

echo "Installing script dependencies and util packages."
pacman -Sy vim xorg-server xorg-xinit iw wpa_supplicant dialog intel-ucode termite

# Clock and language
echo -e "\nSetting the timezone and setting hw clock."
ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
vim /etc/locale.gen
echo "Generating locale, for language support"
locale-gen

# Hostname
echo -e "\nCreating a host name"
vim /etc/hostname

# Creating users and passwords
echo -e "\nCreating root password."
passwd
echo "Create a new user? [y/n]"
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
ANSW=n
while [ $ANSW = n ]; do
    echo "Device to install: "
    read ANSW
    echo "DEVICE is $ANSW, right? [y/n]"
    Read_lower
done
grub-install $ANSW
grub-mkconfig -o /boot/grub/grub.cfg

# Bumblebee and video drivers
echo "Installing video drivers."
echo "Do you want to install bumblebee? (If you have intel + nvidia gpus on the same system)[y/n]"
Read_lower
if [ $ANSW = y ]; then
    # Enable multilib repo
    echo "Uncomment the multilib repository.\nPress enter to continue..."
    read ANSW
    vim /etc/pacman.conf
    pacman -Sy bumblebee mesa xf86-video-intel nvidia lib32-virtualgl lib32-nvidia-utils lib32-mesa-libgl mesa-demos
    echo "Type the user name to be added to the bumblebee group:"
    read ANSW
    gpasswd -a $ANSW bumblebee
    systemctl enable bumblebeed.service
else
    echo "Do you want to install intel drivers? [y/n]"
    Read_lower
    if [ $ANSW = y ]; then
        sudo pacman -S xf86-video-intel vulkan-intel mesa
    fi
fi

# Desktop Environment
echo "Do you want to install a desktop environment? [y/n]:"
Read_lower
if [ $ANSW = y ]; then
    ANSW=0
    while [ $ANSW -lt 1 -o $ANSW -gt 2 ]; do
        echo "1 - Gnome (minimal)"
        echo "2 - i3"
        read ANSW
    done
    case $ANSW in
        1) Install_gnome;;
        2) Install_i3;;
    esac
fi

# Removing this script from the system
rm second.sh
