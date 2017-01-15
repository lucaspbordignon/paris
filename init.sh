#!/bin/sh

Menu() {
    CHOICE=-1
    while [ $CHOICE -lt 0 -o $CHOICE -gt 8 ]
    do
        echo "Choose one option"
        echo "1 - Set keyboard"
        echo "2 - Connect to wifi"
        echo "3 - Update system clock"
        echo "4 - Partition the disk"
        echo "5 - Format the partitions"
        echo "6 - Mount the file systems"
        echo "7 - Change mirrorlist and install base"
        echo "8 - Genfstab & Chroot"
        echo "9 - Configure the new system"
        echo "0 - Exit script"
        read CHOICE
    done
}

# Useful
Read_choice() {
    read ANSW
    ANSW=$( echo $ANSW | tr "[:upper:]" "[:lower:]" ) # Convert to lower case
}

# Set keyboard layout
Keyboard() {
    echo "List layouts? [y/n]"
    Read_choice
    if [ $ANSW = y ]; then
        less ls /usr/share/kbd/keymaps/**/*.map.gz
    fi
    echo "Choosen layout: "
    read ANSW
    loadkeys ANSW
}

# Connects to wifi and tests the connection
Wifi() {
    ANSW=n
    while [ $ANSW != y ]; do
        wifi-menu
        echo "Done? [y/n]"
        Read_choice
    done
    echo "Test internet? [y/n]"
    Read_choice
    if [ $ANSW = y ]; then
        ping -c3 google.com
    fi
}

Disk() {
    FINISHED=n
    while [ $FINISHED != y ]; do
        echo "List devices? [y/n]"
        Read_choice
        if [ $ANSW = y ]; then
            fdisk -l
        fi
        echo "Device to be used (/dev/sda, etc.):"
        read ANSW
        fdisk ANSW
        echo "Done? [y/n]"
        Read_choice
        FINISHED=ANSW
    done 
}

Format() {
    echo "Format de partitions."
    FINISHED=n
    while [ $FINISHED != y ]; do 
        echo "Boot partition:"
        read ANSW
        mkfs.fat -F32 -n Boot $ANSW
        echo "Swap:"
        mkswap -L  Swap $ANSW && swapon $ANSW
        echo "Root:"
        read ANSW
        mkfs.ext4 -L Root $ANSW
        echo "Want to format some /home partition? [y/n]"
        Read_choice
        if [ $ANSW = y ]; then
            echo "/home:"
            read ANSW
            mkfs.ext4 $ANSW
        fi
        echo "Done? [y/n]"
        Read_choice
        FINISHED=ANSW
    done
}

Mount() {
    echo "Mounting root, type the partition:"
    read ANSW
    mount $ANSW /mnt
    echo "Mounting home, type the partition:"
    read ANSW
    mkdir /mnt/home && mount $ANSW /mnt/home
    echo "Mounting boot, type the partition:"
    echo "(note that grub will be used.)"
    read ANSW
    mkdir -p /mnt/boot/efi && mount $ANSW /mnt/boot/efi
}

Mirrorlist() {
    vim /etc/pacman.d/mirrorlist
    echo "Installing the base packages."
    pacstrap /mnt base base-devel
}

Genfstab() {
    echo "Generating file systems table"
    genfstab -p /mnt >> /mnt/etc/fstab
    echo "Chrooting on the system."
    arch-chroot /mnt
}

Inside_chroot() {
    echo "Setting the timezone"
    ln -s /usr/share/zoneinfo/Region/City /etc/localtime    # TODO
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
}

# Init
echo "Welcome to PARIS (Personal Arch linux Installation Script)."
Menu
case $CHOICE in
    0) return ;;
    1) Keyboard;;
    2) Wifi;;
    3) timedatectl set-ntp true;;
    4) Disk;;
    5) Format;;
    6) Mount;;
    7) Mirrorlist;;
    8) Genfstab;;
    9) Inside_chroot;;
esac
