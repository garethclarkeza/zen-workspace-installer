#!/usr/bin/env bash

#COLOURS
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
PURPLE=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`
BLACK=`tput setaf 8`
NC=`tput sgr0` # reset colour

ENV_LOADED=false
INSTALL_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
STATUS_FILE=${INSTALL_FOLDER}/status
WORKSPACE_ENV_FILE=~/.zen
TAB_SPACES='    '

tabs 4

#/etc/netplan/<config-file>.cfg
#network:
#  version: 2
#  renderer: networkd
#  ethernets:
#    enp0s3:
#      addresses: [192.168.100.102/24]
#      dhcp4: no
#    enp0s8:
#      dhcp4: yes

#sudo netplan generate
#sudo netplan apply

# INITIALIZE THE SETUP AND CHECKING FOR CONTINUED INSTALLS
. ${INSTALL_FOLDER}/init.sh

# ALWAYS INCLUDE THE UTILS
echo -e "${CYAN}[CONFIG]${WHITE}\t\tIncluding installation utilities${NC}"
. ${INSTALL_FOLDER}/utils.sh

# This can only be loaded after the .env file is setup
if [[ $(cat ${STATUS_FILE}) =~ 'start' ]]
then
    echo -e "${CYAN}[CONFIG]${WHITE}\t\tMaking installation files executable${NC}"
    chmod 775 ${INSTALL_FOLDER}/*.sh
    update_status 'ssh'
else
    echo -e "${YELLOW}[CONFIG]${WHITE}\t\tContinuing from previous installation...${NC}"
fi

# GET THE SSH SERVER RUNNING WITH ACCESS
if [[ $(cat ${STATUS_FILE}) =~ 'ssh' ]]
then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tSetting up SSH access and automation${NC}"
    . ${INSTALL_FOLDER}/setup-ssh.sh
    update_status 'guest-additions'
else
    echo -e "${YELLOW}[INSTALLING]${WHITE}\tSSH already setup, skipping...${NC}"
fi

# ADD VBOX UBUNTU GUEST ADDITIONS
# The process will need to stop at this point so that you can add the required shared volumes to
# the virtual box container, which can only be done once the server is not running.
if [[ $(cat ${STATUS_FILE}) =~ 'guest-additions' ]]
then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tUpdating Ubuntu package manager${NC}"
    sudo apt update -y && sudo apt upgrade -y

    echo -e "${GREEN}[INSTALLING]${WHITE}\tSetting up VirtualBox Guest Additions${NC}"

    . ${INSTALL_FOLDER}/setup-guest-additions.sh

    update_status 'samba'
    echo -e "${GREEN}[INSTALLING]${WHITE}\tVirtualBox Guest Additions has been installed and your user has been added the the vboxsf group.${NC}"
    echo
    echo -e "\t${WHITE}You need to make SURE that you added the 2 virtualbox shares."
    echo -e "\tPlease refer to the readme file for more details.${NC}"
    echo
    echo -e "${PURPLE}[INSTALLING]${WHITE}\tYou need to logout now and back in again in order to continue with the installation!${NC}"
    echo
    exit 0
else
    echo -e "${YELLOW}[INSTALLING]${WHITE}\tSkipping guest additions installation...${NC}"
fi

# ZEN WORKSPACE SETUP
if [[ $(cat ${STATUS_FILE}) =~ 'samba' ]]
then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tSetting Samba shares for Windows access${NC}"

    sudo mkdir -p ${SAMBA_PUBLIC}
    sudo chown -R nobody:nogroup ${SAMBA_PUBLIC}
    sudo chmod -R 0775 ${SAMBA_PUBLIC}

    sudo addgroup smbgroup
    sudo usermod -aG smbgroup ${USER}
    sudo smbpasswd -a ${USER}

    sudo chown -R root:smbgroup ${WORKSPACE_WWW_FOLDER}
    sudo chmod -R 0770 ${WORKSPACE_WWW_FOLDER}

    sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
    sudo cp ${INSTALL_FOLDER}/smb.conf /etc/samba/smb.conf

    sudo service smbd restart

    echo -e "${GREEN}[INSTALLING]${WHITE}\tSamba has been successfully setup, now you should setup your shares in Windows.${NC}"

    update_status 'netplan'
fi

# ZEN WORKSPACE SETUP
if [[ $(cat ${STATUS_FILE}) =~ 'netplan' ]]
then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tSetting netplan configuration for host-only network${NC}"

    sudo cat ${INSTALL_FOLDER}/netplan > /etc/netplan/01-netcfg.yaml
    cat ${INSTALL_FOLDER}/netplan.yaml | sudo tee /etc/netplan/01-netcfg.yaml > /dev/null
    sudo netplay generate
    sudo netplay apply

    echo -e "${PURPLE}[INSTALLING]${WHITE}\tNetplan configuration successfully installed, please restart the server in headless mode and you should be able to connect via ${WORKSPACE_IP} in your SSH client!${NC}"

    update_status 'workspace'
fi

echo 'completed netplan install'
exit 0

# ZEN WORKSPACE SETUP
if [[ $(cat ${STATUS_FILE}) =~ 'workspace' ]]
then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tSetting up Zen Workspace${NC}"
    . ${INSTALL_FOLDER}/setup-workspace.sh

    die_if_workspace_is_not_installed

    echo -e "${GREEN}[INSTALLING]${WHITE}\tCompleted setting up workspace${NC}"
    update_status 'dev-utils'
else
    echo -e "${YELLOW}[INSTALLING]${WHITE}\tSkipping workspace setup...${NC}"
fi

die_if_workspace_is_not_installed

# DEVELOPMENT UTILITIES AND FEATURES
if [[ $(cat ${STATUS_FILE}) =~ 'dev-utils' ]]
then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tSetting up development utilities${NC}"
    . ${INSTALL_FOLDER}/setup-dev-utils.sh
    update_status 'laradock-install'
else
    echo -e "${YELLOW}[INSTALLING]${WHITE}\tSkipping dev utilities...${NC}"
fi

die_if_workspace_is_not_installed

# DOCKER AND LARADOCK SETUP
if [[ $(cat ${STATUS_FILE}) =~ 'docker' || $(cat ${STATUS_FILE}) =~ 'laradock-' ]]
then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tSetting up Docker and Laradock and building core containers${NC}"
    . ${INSTALL_FOLDER}/setup-docker.sh
    echo -e "${GREEN}[INSTALLING]${WHITE}\tCompleted installation and setup of Docker and Laradock${NC}"
    update_status 'cleanup'
else
    echo -e "${YELLOW}[INSTALLING]${WHITE}\tSkipping docker and laradock...${NC}"
fi

die_if_workspace_is_not_installed
die_if_laradock_is_not_installed

# FINISH UP BY CLEANING UP AFTER SETUP
if [[ $(cat ${STATUS_FILE}) =~ 'cleanup' ]]
then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tCleaning up...${NC}"
    update_status 'complete'

    sudo apt autoremove
    sudo rm -rf /tmp/*
    # removing bash/profile backups
    rm -rf ~/~*
else
    echo -e "${YELLOW}[INSTALLING]${WHITE}\tSkipping cleanup...${NC}"
fi

# COMPLETE WITH INSTALLATION, THE FILES SHOULD BE UNINSTALLED
if [[ $(cat ${STATUS_FILE}) =~ 'complete' ]]
then
#    sed -i '\/zen-workspace-installer\/install.sh continue/d' ~/.bash_profile
    echo
    echo -e "${GREEN}[COMPLETE]${WHITE}\t\tYour new workspace has been successfully setup! Congratulations.${NC}"
    echo
fi
