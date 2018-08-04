#!/usr/bin/env bash

echo
read -p "${RED}Have you set the CDROM in VirtualBox to use the VBoxLinuxAdditions.iso ?${NC} [y/N]" -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo
    echo 'Updating package manager and installing required packages...'
    echo

    sudo apt-get update && sudo apt-get upgrade
    sudo apt-get install -y dkms build-essential linux-headers-generic apt-transport-https linux-headers-$(uname -r)

    echo
    echo 'Setting up mount to load the VBox Linux Additions'
    echo

    sudo mkdir /media/cdrom
    sudo mount -r /dev/cdrom --target /media/cdrom
    cd /media/cdrom/

    echo
    echo 'Running VBox Linux Additions'
    echo

    sudo groupadd -g 998 vboxsf
    sudo ./VBoxLinuxAdditions.run
    sudo usermod -aG vboxsf ${USER}
else
    echo -e "${RED}Please insert the guest additions iso into the VM as per readme file and then try again!${NC}"
    echo
    read -p "Press any key to exit"
    exit 1
fi
