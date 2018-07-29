#!/usr/bin/env bash

ENV_LOADED=false
INSTALL_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
STATUS_FILE=${INSTALL_FOLDER}/status

# @todo check requirements (git, vim, repo access, etc)

cd ${INSTALL_FOLDER}

if [[ ! -f ${STATUS_FILE} ]]
then
    touch ${STATUS_FILE}
    echo 'init' > ${STATUS_FILE}
fi

if [[ $(cat ${STATUS_FILE}) =~ 'init' ]]
then
    # Confirm before proceeding with deployment
    read -p "Install new workspace to '${INSTALL_FOLDER}'? Please make sure that the VBoxLinuxAdditions.iso is loaded as well. This should only be done once. [Y/n] " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Nn]$ ]]
    then
        echo
        echo -e "Please insert the guest additions iso into the VM as per readme file and then try again!"
        echo
        exit 0
    fi

    if [[ ! -f '.env' ]]
    then
        echo '.env file was not found, setting up default env file, please edit as needed and then continue:'
        cp ${INSTALL_FOLDER}/env-example ${INSTALL_FOLDER}/.env
        vim ${INSTALL_FOLDER}/.env
        ENV_LOADED=true
    fi

    if [[ ! ${ENV_LOADED} ]]
    then
        echo '.env file was never loaded, and there have been too many attempts, please create a .env file file in the root of the workspace'
        exit 1
    fi

    echo 'start' > ${STATUS_FILE}
fi

# BEGIN INSTALLATION
cd ${INSTALL_FOLDER}

# This can only be loaded after the .env file is setup
if [[ $(cat ${STATUS_FILE}) =~ 'start' ]]
then
    echo 'Making installing files executable'
    chmod o+x ${INSTALL_FOLDER}/*.sh
    chmod 775 ${INSTALL_FOLDER}/*.sh
    echo 'guest-additions' > ${STATUS_FILE}
fi

# ALWAYS INCLUDE THE UTILS
echo 'Including installation utilities'
source utils.sh
echo 'Installation utilities installed'

# ADD VBOX UBUNTU GUEST ADDITIONS
# The process will need to stop at this point so that you can add the required shared volumes to
# the virtual box container, which can only be done once the server is not running.
if [[ $(cat ${STATUS_FILE}) =~ 'guest-additions' ]]
then
    echo 'Setting up Linux Guest Additions'
    cd ${INSTALL_FOLDER}
    source setup-guest-additions.sh

    echo 'ssh' > ${STATUS_FILE}
    echo
    echo -e "${GREEN}VBox Linux Additions has been successfully installed and your user has been added the the vboxsf group.${NC}"
    echo
    echo -e "${WHITE}You need to shutdown this server and add the 2 shared volumes to the image in Virtual Box."
    echo -e "Please refer to the readme file for more details.${NC}"
    echo
    read -p "${RED}Shutdown the server to add your shared folders?${WHITE} [y/N]${NC}" -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo
        echo "${RED}Shutting down in 10 seconds, refer to the readme file for instructions on adding the VirtualBox VM volumes.${NC}"
        echo
        sudo shutdown -h 10
    fi
    echo
    echo "${RED}Refer to the readme file for instructions on adding the VirtualBox VM volumes.${NC}"
    echo "${RED}Please make sure to restart the server.{$NC}"
    echo
    exit 1
else
    echo -e "${YELLOW}Skipping guest additions installation...${NC}"
    echo
fi

# GET THE SSH SERVER RUNNING WITH ACCESS
if [[ $(cat ${STATUS_FILE}) =~ 'ssh' ]]
then
    echo 'Seting up SSH access and automation'
    cd ${INSTALL_FOLDER}
    source setup-ssh.sh
    echo 'Completed SSH setup'
    echo 'workspace' > ${STATUS_FILE}
else
    echo -e "${YELLOW}Skipping SSH setup...${NC}"
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

# DEVELOPMENT UTILITIES AND FEATURES
if [[ $(cat ${STATUS_FILE}) =~ 'dev-utils' ]]
then
    echo 'Setting up dev utils'
    cd ${INSTALL_FOLDER}
    source setup-dev-utils.sh
    echo 'docker' > ${STATUS_FILE}
else
    echo -e "${YELLOW}Skipping dev utilities...${NC}"
    echo
fi

# DOCKER AND LARADOCK SETUP
if [[ $(cat ${STATUS_FILE}) =~ 'docker' || $(cat ${STATUS_FILE}) =~ 'laradock' ]]
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
    nvm cache clear
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
