echo -e "${GREEN}[INSTALLING]${WHITE}\tFetching the latest version of Zen Workspace"
echo -e "${GREEN}[INSTALLING]${WHITE}\tCloning Zen Workspace from ${WORKSPACE_REPO} into ${WORKSPACE_ROOT_FOLDER}"

cd /
#git clone -q --progress ${WORKSPACE_REPO} ${WORKSPACE_ROOT_FOLDER}
cd ${WORKSPACE_ROOT_FOLDER}

die_if_workspace_is_not_installed

echo -e "${GREEN}[INSTALLING]${WHITE}\tChecking out Zen Workspace branch: ${WORKSPACE_REPO_BRANCH}${NC}"
#git checkout ${WORKSPACE_REPO_BRANCH}
echo -e "${GREEN}[INSTALLING]${WHITE}\tInstalling workspace scripts${NC}"
install_workspace_scripts
echo -e "${GREEN}[INSTALLING]${WHITE}\tCompleted installing workspace scripts${NC}"
echo -e "${GREEN}[INSTALLING]${WHITE}\tSetting up default hosts${NC}"

# add windows_host with the clients connected IP address to ubuntu hosts file
#manage-hosts updatehost windows.host ${HOST_IP_ADDRESS}

# add ubuntu servers IP address to windows under the selected ubuntu hostname
# manage-hosts win-addhost ${HOSTNAME} ${LOCAL_IP_ADDRESS}
# manage-hosts win-addhost workspace ${LOCAL_IP_ADDRESS}
#manage-hosts win-updatehost workspace.zen ${LOCAL_IP_ADDRESS}

echo -e "${GREEN}[INSTALLING]${WHITE}\tSetting up workspace links to windows volumes${NC}"
echo -e "${GREEN}[INSTALLING]${WHITE}\t - linking workspace to ${WHITE}~/workspace${NC}"
#ln -s ${WORKSPACE_ROOT_FOLDER} ~/workspace
echo -e "${GREEN}[INSTALLING]${WHITE}\t - linking workspace to ${WHITE}/var/www${NC}"
#sudo ln -s ${WORKSPACE_ROOT_FOLDER} /var/www
echo -e "${GREEN}[INSTALLING]${WHITE}\t - linking windows hosts file folder to ${WHITE}/etc/win_hosts${NC}"
#sudo ln -s ${WORKSPACE_WIN_HOSTS_FOLDER}/hosts /etc/win_hosts

# LINK WORKSPACE BASH ALIASES TO USERS HOME FOLDER
#for default_script in ${WORKSPACE_ROOT_FOLDER}/config/bash/*; do
#    rm -f ~/${default_script}
#    ln -s ${WORKSPACE_ROOT_FOLDER}/config/bash/${default_script} ~/${default_script}
#done

#source ~/.bash_profile
echo -e "${GREEN}[INSTALLING]${WHITE}\tNew bash prompt successfully installed${NC}"
read -p "${GREEN}[INSTALLING]${WHITE}${TAB_SPACES}Would you to edit your docker stacks file? [y/N]${NC} "

if [[ $REPLY =~ ^[Yy]$ ]]
then
    vim ~/.docker_stacks
fi
