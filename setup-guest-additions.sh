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

    sudo ./VBoxLinuxAdditions.run
    sudo usermod -aG vboxsf ${USER}

    echo
    echo -e "${GREEN}VBox Linux Additions has been successfully installed and your user has been added the the vboxsf group.${NC}"
    echo
    echo -e "${WHITE}You need to shutdown this server and add the 2 shared volumes to the image in Virtual Box."
    echo -e "Please refer to the readme file for more details.${NC}"
    echo
    read -p "${RED}Shutdown the server to add your shared folders?${NC} [y/N]" -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        sudo shutdown -h now
    fi
fi
