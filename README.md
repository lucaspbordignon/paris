# paris
My Personal Arch Installation Script. Note that some steps are pre-defined (Using grub as bootloader, timezone, etc.)

# Installing without git (recommended)
* Connect to internet. If using a wireless interface, type the following:

`wifi-menu`

* Download and execute the script:

`wget git.io/vMF2a -O init && sh init`

# Installing with git
* Connect to internet. Same as descripted above.
* In order to be able to install the git package, remount the cowspace of the arch linux iso:

`mount -o remount,size=1G /run/archiso/cowspace`
* After that, just clone the repo and execute the script
