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

# Set keyboard layout
Keyboard() {
    echo "List layouts? [y/n]"
    read ANSW
    ANSW=$( echo $ANSW | tr "[:upper:]" "[:lower:]" ) # Convert to lower case
    if [ $ANSW = y ]; then
        less ls /usr/share/kbd/keymaps/**/*.map.gz
    fi
    echo "Choosen layout: "
    read ANSW
    loadkeys ANSW
}

# Connects to wifi and test the connection
Wifi() {
    ANSW=n
    while [ $ANSW != y ]; do
        wifi-menu
        echo "Done? [y/n]"
        read ANSW
    done
    echo "Test internet? [y/n]"
    read ANSW
    if [ $ANSW = y ]; then
        ping -c3 google.com
    fi
}

# Init
echo "Welcome to PARIS (Personal Arch linux Installation Script)."
Menu
case $CHOICE in
    0) return ;;
    1) Keyboard;;
    2) Wifi;;
    3);;
    4);;
    5);;
    6);;
    7);;
    8);;
esac
