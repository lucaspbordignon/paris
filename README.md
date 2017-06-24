# paris
My Personal Arch Installation Script. Note that some steps are pre-defined (Using grub as bootloader, timezone, etc.)

# Installation
## Installing without git (recommended)
* Connect to internet. If using a wireless interface, type the following:

`wifi-menu`

* Download and execute the script:

`wget git.io/vMF2a -O init && sh init`

## Installing with git
* Connect to internet. Same as descripted above.
* In order to be able to install the git package, remount the cowspace of the arch linux iso:

`mount -o remount,size=1G /run/archiso/cowspace`
* After that, just clone the repo and execute the script

# Predefined settings
The script, as it is a personal one (the P from paris), has some conventions listed below. Feel free to fork the repository and modify it.

* Single boot system.
* UEFI installation (/boot formated as an EFI partititon).
* Using gdisk to partition the disk.
* / and /home are formated in ext4.
* Timezone set to America/Sao_Paulo.
* Bootloader used is grub.
* If bumblebee isn't installed (to use intel and nvidia graphics together), none other driver will be installed.
* Installing bumblebee: Using the proprietary nvidia drivers.
