#!/bin/sh

HARD_DISK=""
DONE_ACTIONS_0="-"
DONE_ACTIONS_1="-"
DONE_ACTIONS_2="-"
DONE_ACTIONS_3="-"
DONE_ACTIONS_4="-"
DONE_ACTIONS_5="-"
DONE_ACTIONS_6="-"
DONE_ACTIONS_7="-"

Menu() {
    CHOICE=-1
    while [ $CHOICE -lt 0 -o $CHOICE -gt 8 ]
    do
        echo "----------------------------------------------------------------"
        echo "Choose one option"
        echo "[$DONE_ACTIONS_0] 1 - Set keyboard"
        echo "[$DONE_ACTIONS_1] 2 - Test the internet connection"
        echo "[$DONE_ACTIONS_2] 3 - Update system clock"
        echo "[$DONE_ACTIONS_3] 4 - Partition the disk"
        echo "[$DONE_ACTIONS_4] 5 - Format the partitions"
        echo "[$DONE_ACTIONS_5] 6 - Mount the file systems"
        echo "[$DONE_ACTIONS_6] 7 - Change mirrorlist and install base"
        echo "[$DONE_ACTIONS_7] 8 - Genfstab & Chroot"
        echo "0 - Exit script"
        read CHOICE
        echo "----------------------------------------------------------------"
    done
}

# Reads a keyboard input and returns the lower case version of it
Read_lower() {
    read ANSW
    ANSW=$( echo $ANSW | tr "[:upper:]" "[:lower:]" ) # Convert to lower case
}

# Set keyboard layout
Keyboard() {
    echo "List layouts? [y/n]"
    Read_lower
    if [ $ANSW = y ]; then
        ls /usr/share/kbd/keymaps/i386/qwerty | less
    fi
    echo "Choosen layout: "
    read ANSW
    loadkeys $ANSW
    DONE_ACTIONS_0="*"
}

# Tests the connection
Internet() {
    echo "Test internet? [y/n]"
    Read_lower
    if [ $ANSW = y ]; then
        ping -c3 google.com
    fi
    DONE_ACTIONS_1="*"
}

# Partition the disk
Disk() {
    ANSW=n
    while [ $ANSW != y ]; do
        echo "List devices? [y/n]"
        Read_lower
        if [ $ANSW = y ]; then
            fdisk -l
        fi
        echo -e "\nDevice to be used (/dev/sda, etc.):"
        read HARD_DISK
        gdisk $HARD_DISK
        echo "Done? [y/n]"
        Read_lower
    done 
    DONE_ACTIONS_3="*"
}

# Format the disk
Format() {
    echo "Format de partitions."
    ANSW=n
    while [ $ANSW != y ]; do 
        fdisk -l $HARD_DISK
        echo "Boot partition:"
        read ANSW
        mkfs.fat -F32 -n Boot $ANSW
        echo "Swap:"
        read ANSW
        mkswap -L  Swap $ANSW && swapon $ANSW
        echo "Root:"
        read ANSW
        mkfs.ext4 -L Root $ANSW
        echo "Want to format some /home partition? [y/n]"
        Read_lower
        if [ $ANSW = y ]; then
            echo "/home:"
            read ANSW
            mkfs.ext4 $ANSW
        fi
        echo "Done? [y/n]"
        Read_lower
    done
    DONE_ACTIONS_4="*"
}

# Mount the partitions
Mount() {
    ANSW=n
    while [ $ANSW != y ]; do
        fdisk -l $HARD_DISK
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
        echo "Done? [y/n]"
        Read_lower
    done
    DONE_ACTIONS_5="*"
}

# Change mirrors and install the base
Mirrorlist() {
    vim /etc/pacman.d/mirrorlist
    echo "Installing the base packages."
    pacstrap /mnt base base-devel
    DONE_ACTIONS_6="*"
}

# Generate the fstab and access the system (chroot)
Genfstab() {
    echo "Generating file systems table"
    genfstab -p /mnt > /mnt/etc/fstab
    echo "Chrooting on the system."
    wget git.io/vMFa6 -qO second.sh
    cp second.sh /mnt
    arch-chroot /mnt sh second.sh
    echo "Do you want to enter chroot again? [y/n]"
    echo "Obs: If enter again, after exit, run 'umount -R /mnt'"
    Read_lower
    if [ $ANSW = y ]; then
        arch-chroot /mnt
    fi
    umount -R /mnt
    DONE_ACTIONS_7="*"
}

# Init
echo "Welcome to PARIS (Personal Arch linux Installation Script)."
echo "Updating the pacman database, for future use."
pacman -Sy
EXIT=0
while [ $EXIT != 1 ]; do
    Menu
    case $CHOICE in
        0) EXIT=1 ;;
        1) Keyboard;;
        2) Internet;;
        3) echo "Updating..." && timedatectl set-ntp true && DONE_ACTIONS_2="*";;
        4) Disk;;
        5) Format;;
        6) Mount;;
        7) Mirrorlist;;
        8) Genfstab;;
    esac
done
