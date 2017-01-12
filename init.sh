#!/bin/sh

Menu() {
    CHOICE=-1
    while [ $CHOICE -lt 0 -o $CHOICE -gt 8 ]
    do
        echo "Choose one option"
        echo "1 - Set keyboard"
        echo "2 - Connect to wifi"
        echo "3 - Update system clock"
        echo "4 - Partition and format the disk"
        echo "5 - Mount the file systems"
        echo "6 - Change mirrorlist and install base"
        echo "7 - Genfstab & Chroot"
        echo "8 - Configure the new system"
        echo "0 - Exit script"
        read CHOICE
    done
}

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
# Init
echo "Welcome to PARIS (Personal Arch linux Installation Script)."
Menu
case $CHOICE in
    0) return ;;
    1) Keyboard;;
    2) Wifi;;
    3) timedatectl set-ntp true;;
    4) Disk;;
    5);;
    6);;
    7);;
    8);;
esac
