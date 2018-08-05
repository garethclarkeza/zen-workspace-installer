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

# @todo check requirements (git, vim, repo access, etc)
echo
echo -e "${YELLOW}[PRECHECK]${WHITE}\tChecking for previous installation state...${NC}"
cd ${INSTALL_FOLDER}

if [[ ! -f ${STATUS_FILE} ]]
then
    echo -e "${YELLOW}[PRECHECK]${WHITE}\tNo previous installations were detected, starting new installation${NC}"
    touch ${STATUS_FILE}
    echo 'init' > ${STATUS_FILE}
fi

if [[ $(cat ${STATUS_FILE}) =~ 'init' ]]
then
    # Confirm before proceeding with deployment
    echo
    echo "${GREEN}Would you like to install a new version of Zen Workspace?${NC}"
    echo 'Please make sure that the VBoxLinuxAdditions.iso is loaded as well (see readme).'
    echo
    read -p "${RED}This should only be done once.${WHITE} [Y/n]${NC} " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Nn]$ ]]
    then
        echo
        echo "${RED}Please insert the guest additions iso into the VM as per readme file and then try again!${NC}"
        echo
        exit 0
    fi

    echo 'env' > ${STATUS_FILE}
else
    echo -e "${YELLOW}[PRECHECK]${WHITE}\tPrevious installation has been detected, continuing installation...${NC}"
fi

# MAKE SURE THE ENV FILE IS INITIALIZED
if [[ $(cat ${STATUS_FILE}) =~ 'env' ]]
then
    if [[ ! -f '.env' ]]
    then
        echo -e "${YELLOW}[PRECHECK]${WHITE}\tInstaller .env file not found! Creating one from the default.${NC}"
        cp ${INSTALL_FOLDER}/env-example ${INSTALL_FOLDER}/.env
        read -p  "${CYAN}[CONFIG]${WHITE}\tPress any key to continue and edit your .env file to fit your requirements...${NC}"
        vim ${INSTALL_FOLDER}/.env
        ENV_LOADED=true
    fi

    if [[ ! ${ENV_LOADED} ]]
    then
        echo
        echo -e "${RED}[ERROR]${WHITE}\tInstaller .env file was never loaded, please create an .env file file in the root folder of the installer."
        echo "You can copy from the example file in the installer folder env-example. Exiting installation...${NC}"
        echo
        exit 1
    fi

    echo 'start' > ${STATUS_FILE}
fi

# BEGIN INSTALLATION
echo
echo "${GREEN}Your system is ready to begin installation of your ${WHITE}Zen Workspace${GREEN}!${NC}"
echo

# ALWAYS INCLUDE THE UTILS
echo -e "${CYAN}[CONFIG]${WHITE}\tIncluding installation utilities${NC}"

source ${INSTALL_FOLDER}/utils.sh


# ALWAYS INCLUDE THE UTILS
echo ' -> Including installation utilities'
source ${INSTALL_FOLDER}/utils.sh

# This can only be loaded after the .env file is setup
if [[ $(cat ${STATUS_FILE}) =~ 'start' ]]
then
    echo -e "${CYAN}[CONFIG]${WHITE}\tMaking installation files executable${NC}"
    chmod 775 ${INSTALL_FOLDER}/*.sh

    echo 'ssh' > ${STATUS_FILE}
else
    echo
    echo -e "${YELLOW}Continuing from previous installation...${NC}"
    echo
fi

# GET THE SSH SERVER RUNNING WITH ACCESS
if [[ $(cat ${STATUS_FILE}) =~ 'ssh' ]]
then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tSetting up SSH access and automation${NC}"
    cd ${INSTALL_FOLDER}
    source setup-ssh.sh
    echo 'guest-additions' > ${STATUS_FILE}
else
    echo
    echo -e "${YELLOW}SSH already setup, skipping...${NC}"
    echo
fi

# ADD VBOX UBUNTU GUEST ADDITIONS
# The process will need to stop at this point so that you can add the required shared volumes to
# the virtual box container, which can only be done once the server is not running.
if [[ $(cat ${STATUS_FILE}) =~ 'guest-additions' ]]
then
    echo -e " ${GREEN}[INSTALLING]${WHITE}\tUpdating APT package manager${NC}"
    sudo apt update -y && sudo apt upgrade -y

    echo -e " ${GREEN}[INSTALLING]${WHITE}\tSetting up Linux Guest Additions"

    cd ${INSTALL_FOLDER}
    source setup-guest-additions.sh

    echo 'workspace' > ${STATUS_FILE}
    echo
    echo -e "${GREEN}VBox Linux Additions has been successfully installed and your user has been added the the vboxsf group.${NC}"
    echo
    echo -e "${WHITE}You need to make SURE that you added the 2 virtualbox shares."
    echo -e "Please refer to the readme file for more details."
    echo
    echo -e "You need to logout now and log in again in order to continue with the installation!${NC}"
    echo
    exit 0
else
    echo -e "${YELLOW}Skipping guest additions installation...${NC}"
    echo
fi

# ZEN WORKSPACE SETUP
if [[ $(cat ${STATUS_FILE}) =~ 'workspace' ]]
then
    echo 'Setting up workspace'
    cd ${INSTALL_FOLDER}
    source setup-workspace.sh
    echo 'Completed setting up workspace'
    echo 'dev-utils' > ${STATUS_FILE}
else
    echo -e "${YELLOW}Skipping workspace setup...${NC}"
    echo
fi

# CHECK TO MAKE SURE WORKSPACE WAS INSTALLED - EVERYTHING PAST THIS POINT NEEDS IT
if [[ ! -f ${WORKSPACE_ROOT_FOLDER}/readme.md ]]
then
    echo "${RED}[ERROR]${WHITE} There was an error fetching the workspace from the github repo. Please check for errors and make sure that your SSH key has been added to github.${NC}"
    echo
    exit 1
fi

# DEVELOPMENT UTILITIES AND FEATURES
if [[ $(cat ${STATUS_FILE}) =~ 'dev-utils' ]]
then
    echo 'Setting up dev utils'
    cd ${INSTALL_FOLDER}
    source setup-dev-utils.sh
    echo 'laradock-install' > ${STATUS_FILE}
else
    echo -e "${YELLOW}Skipping dev utilities...${NC}"
    echo
fi

# DOCKER AND LARADOCK SETUP
if [[ $(cat ${STATUS_FILE}) =~ 'docker' || $(cat ${STATUS_FILE}) =~ 'laradock-' ]]
then
    echo 'Setting up docker and laradock'
    cd ${INSTALL_FOLDER}
    source setup-docker.sh
    echo 'Completed installation and setup of docker and laradock'
    echo 'cleanup' > ${STATUS_FILE}
else
    echo -e "${YELLOW}Skipping docker and laradock...${NC}"
    echo
fi

# FINISH UP BY CLEANING UP AFTER SETUP
if [[ $(cat ${STATUS_FILE}) =~ 'cleanup' ]]
then
    echo 'Cleaning up...'
    echo 'complete' > ${STATUS_FILE}
    sudo apt autoremove
    sudo rm -rf /tmp/*
    # remove backup files like _bash_aliases, _bash_helpers
else
    echo -e "${YELLOW}Skipping cleanup...${NC}"
    echo
fi

# COMPLETE WITH INSTALLATION, THE FILES SHOULD BE UNINSTALLED
if [[ $(cat ${STATUS_FILE}) =~ 'complete' ]]
then
    echo
    echo "${GREEN}Your new workspace has been successfully setup! Congratulations.${NC}"
    echo
    echo 'Would you like to remove the installation files?'
    echo
fi

echo
echo 'Please logout of all active sessions and re-login to take full advantage of your new server'
echo
