#!/usr/bin/env bash

ENV_LOADED=false
INSTALL_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# @todo check requirements (git, vim, repo access, etc)

cd ${INSTALL_LOCATION}

# Confirm before proceeding with deployment
read -p "Install new workspace? Please make sure that the VBoxLinuxAdditions.iso is loaded as well. This should only be done once. [y/N] " -n 1 -r
echo

if [[ $REPLY =~ ^[Nn]$ ]]
then
    exit 0
fi

if [[ ! -f '.env' ]]
then
    echo '.env file was not found, setting up default env file, please edit as needed and then continue:'
    cp "${INSTALL_FOLDER}/env-example" "${INSTALL_FOLDER}/.env"
    vim .env
    ENV_LOADED=true
fi

if [[ ! ${ENV_LOADED} ]]
then
    echo '.env file was never loaded, and there have been too many attempts, please create a .env file file in the root of the workspace'
    exit 1
fi

# BEGIN INSTALLATION
# This can only be loaded after the .env file is setup
source setup-utils.sh

# quick check to make sure we are on the correct install branch and it is up to date
git checkout ${WORKSPACE_INSTALLER_BRANCH}
git pull origin ${WORKSPACE_INSTALLER_BRANCH}

chmod o+x "${INSTALL_FOLDER}/*.sh"

# GET THE SSH SERVER RUNNING WITH ACCESS
source setup-ssh.sh

# ADD VBOX UBUNTU GUEST ADDITIONS
# The process will need to stop at this point so that you can add the required shared volumes to
# the virtual box container, which can only be done once the server is not running.
source setup-guest-additions.sh

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
