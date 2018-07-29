#!/usr/bin/env bash

ENV_LOADED=false
INSTALL_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# @todo check requirements (git, vim, repo access, etc)

cd ${INSTALL_FOLDER}

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

echo 'Making installing files executable'
chmod o+x ${INSTALL_FOLDER}/*.sh
chmod 775 ${INSTALL_FOLDER}/*.sh

# BEGIN INSTALLATION
# This can only be loaded after the .env file is setup
echo 'Including installation utilities'
source utils.sh

# quick check to make sure we are on the correct install branch and it is up to date
echo 'Verifying the correct workspace installer branch'
#git checkout ${WORKSPACE_INSTALLER_BRANCH}
#git pull origin ${WORKSPACE_INSTALLER_BRANCH}


# GET THE SSH SERVER RUNNING WITH ACCESS
# source setup-ssh.sh

# ADD VBOX UBUNTU GUEST ADDITIONS
# The process will need to stop at this point so that you can add the required shared volumes to
# the virtual box container, which can only be done once the server is not running.
#source setup-guest-additions.sh

# SETUP DEVELOPMENT TOOLS AND THE WORKSPACE - MAIN STUFF HAPPENS HERE
source setup-workspace.sh
source setup-dev-utils.sh
source setup-setup-docker.sh

echo 'Cleaning up...'
sudo apt autoremove

echo
echo "${GREEN}Your new workspace has been successfully setup! Congratulations.${NC}"
echo
echo 'Would you like to remove the installation files?'
echo
