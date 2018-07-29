#!/usr/bin/env bash

echo 'Starting workspace installation and setup'
echo
echo 'Fetching the latest version of Zen Workspace'

echo 'repo folder'
echo ${WORKSPACE_REPO}
echo 'repo branch'
echo ${WORKSPACE_REPO_BRANCH}
echo 'repo branch'
echo ${WORKSPACE_REPO_BRANCH}
echo -e "test git clone ${WORKSPACE_REPO} ${WORKSPACE_ROOT_FOLDER}"
#exit 1

echo 'cloning repo:'
cd /
git clone -q --progress ${WORKSPACE_REPO} ${WORKSPACE_ROOT_FOLDER}
cd ${WORKSPACE_ROOT_FOLDER}
echo "checking out branch: ${WORKSPACE_REPO_BRANCH}"
echo 'git checkout ${WORKSPACE_REPO_BRANCH}'
git checkout ${WORKSPACE_REPO_BRANCH}
echo "pulling latest origin branch: ${WORKSPACE_REPO_BRANCH}"
git pull origin ${WORKSPACE_REPO_BRANCH}
echo
echo 'Installing workspace scripts'
install_workspace_scripts
echo
echo 'completed installing workspace scripts'
echo
echo 'Setting up default hosts'

# add windows_host with the clients connected IP address to ubuntu hosts file
manage-hosts addhost windows_host ${HOST_IP_ADDRESS}

# add ubuntu servers IP address to windows under the selected ubuntu hostname
manage-hosts win-addhost ${HOSTNAME} ${LOCAL_IP_ADDRESS}
manage-hosts win-addhost workspace ${LOCAL_IP_ADDRESS}

echo
echo 'Setting up workspace links to windows volumes'
echo
echo " -> linking workspace to ${WHITE}~/workspace${NC}"
ln -s ${WORKSPACE_ROOT_FOLDER} ~/workspace
echo " -> linking workspace to ${WHITE}/var/www${NC}"
sudo ln -s ${WORKSPACE_ROOT_FOLDER} /var/www
echo " -> linking windows hosts file folder to ${WHITE}/etc/win_hosts${NC}"
sudo ln -s ${WORKSPACE_WIN_HOSTS_FOLDER}/hosts /etc/win_hosts

# LINK WORKSPACE BASH ALIASES TO USERS HOME FOLDER
if [[ -f ~/.bash_aliases ]]
then
    mv ~/.bash_aliases ~/_bash_aliases
fi

if [[ -f ~/.bash_helpers ]]
then
    mv ~/.bash_helpers ~/_bash_helpers
fi

ln -s ${WORKSPACE_ROOT_FOLDER}/config/bash/.bash_* ~/

source ~/.bashrc

echo
echo -e "${GREEN}New bash prompt successfully installed"
echo

