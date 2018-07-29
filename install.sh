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

# Confirm before proceeding with deployment
read -p "Install new workspace? Please make sure that the VBoxLinuxAdditions.iso is loaded as well. This should only be done once. [Y/n] " -n 1 -r
echo

if [[ $REPLY =~ ^[Nn]$ ]]
then
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

# BEGIN INSTALLATION
# This can only be loaded after the .env file is setup
if [[ $(cat ${STATUS_FILE}) =~ 'init' ]]
then
    echo 'Making installing files executable'
    chmod o+x ${INSTALL_FOLDER}/*.sh
    chmod 775 ${INSTALL_FOLDER}/*.sh

    echo 'Including installation utilities'
    source utils.sh
    echo 'Installation utilities installed'
    echo 'ssh' > ${STATUS_FILE}
fi

# GET THE SSH SERVER RUNNING WITH ACCESS
if [[ $(cat ${STATUS_FILE}) =~ 'ssh' ]]
then
    echo 'Seting up SSH access and automation'
    source setup-ssh.sh
    echo 'Completed SSH setup'
    echo 'guest-additions' > ${STATUS_FILE}
fi

# ADD VBOX UBUNTU GUEST ADDITIONS
# The process will need to stop at this point so that you can add the required shared volumes to
# the virtual box container, which can only be done once the server is not running.
if [[ $(cat ${STATUS_FILE}) =~ 'guest-additions' ]]
then
    echo 'Setting up Linux Guest Additions'
    source setup-guest-additions.sh
    echo 'Setup of Linux Guest Addtions complete'
    echo 'workspace' > ${STATUS_FILE}
    echo
    echo "${RED}The system will now shutdown in 10 seconds so that you can add the 2 shared volumes in your VM as per readme file.${NC}"
    echo
    echo "${WHITE}Once you have shared the volumes, restart the VM in headless mode (and connect via your SSH details).${NC}"
    echo

    sudo shutdown -h 10
fi

# ZEN WORKSPACE SETUP
if [[ $(cat ${STATUS_FILE}) =~ 'workspace' ]]
then
    echo 'Setting up workspace'
    cd ${INSTALL_FOLDER}
    source setup-workspace.sh
    echo 'Completed setting up workspace'
    echo 'dev-utils' > ${STATUS_FILE}
fi

# DEVELOPMENT UTILITIES AND FEATURES
if [[ $(cat ${STATUS_FILE}) =~ 'dev-utils' ]]
then
    cd ${INSTALL_FOLDER}
    echo 'Setting up dev utils'
    cd ${INSTALL_FOLDER}
    source setup-dev-utils.sh
    echo 'docker' > ${STATUS_FILE}
fi

# DOCKER AND LARADOCK SETUP
if [[ $(cat ${STATUS_FILE}) =~ 'docker' ]]
then
    echo 'Setting up docker'
    cd ${INSTALL_FOLDER}
    source setup-docker.sh
    echo 'cleanup' > ${STATUS_FILE}
fi

# FINISH UP BY CLEANING UP AFTER SETUP
if [[ $(cat ${STATUS_FILE}) =~ 'cleanup' ]]
then
    echo 'Cleaning up...'

    echo 'complete' > ${STATUS_FILE}
    sudo apt autoremove
    nvm cache clear
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
