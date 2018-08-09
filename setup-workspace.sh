echo -e "${GREEN}[INSTALLING]${WHITE}\tFetching the latest version of Zen Workspace${NC}"
echo -e "${GREEN}[INSTALLING]${WHITE}\tCloning Zen Workspace from ${WORKSPACE_REPO} into ${WORKSPACE_ROOT_FOLDER}${NC}"

cd /
git clone -q --progress ${WORKSPACE_REPO} ${WORKSPACE_ROOT_FOLDER}
cd ${WORKSPACE_ROOT_FOLDER}

die_if_workspace_is_not_installed

echo -e "${GREEN}[INSTALLING]${WHITE}\tChecking out Zen Workspace branch: ${WORKSPACE_REPO_BRANCH}${NC}"
sleep 1
git checkout ${WORKSPACE_REPO_BRANCH}
echo -e "${GREEN}[INSTALLING]${WHITE}\tInstalling workspace scripts${NC}"
install_workspace_scripts
echo -e "${GREEN}[INSTALLING]${WHITE}\tCompleted installing workspace scripts${NC}"
echo -e "${GREEN}[INSTALLING]${WHITE}\tSetting up default hosts${NC}"

# @todo - check if access is available to windows hosts file
# add windows_host with the clients connected IP address to ubuntu hosts file
manage-hosts updatehost windows.host ${HOST_IP_ADDRESS} > /dev/null

# add ubuntu servers IP address to windows under the selected ubuntu hostname
manage-hosts win-updatehost ${HOSTNAME} ${LOCAL_IP_ADDRESS} > /dev/null
manage-hosts win-updatehost workspace.zen ${LOCAL_IP_ADDRESS} > /dev/null

echo -e "${GREEN}[INSTALLING]${WHITE}\tSetting up workspace links to windows volumes${NC}"

# ~/WORKSPACE LINKING
if [ -d ~/workspace ]; then
    echo -e "${GREEN}[INSTALLING]\t - linking workspace to ${WHITE}~/workspace${NC}"
    ln -s ${WORKSPACE_ROOT_FOLDER} ~/workspace
else
    echo -e "${YELLOW}[INSTALLING]\t - ${WHITE}~/workspace has already been created${NC}"
fi

# /VAR/WWW LINKING
if [ -d /var/www ]; then
    echo -e "${GREEN}[INSTALLING]\t - linking workspace to ${WHITE}/var/www${NC}"
    sudo ln -s ${WORKSPACE_ROOT_FOLDER} /var/www
else
    echo -e "${YELLOW}[INSTALLING]\t - ${WHITE}/var/www has already been created${NC}"
fi

# WIN_HOSTS LINKING
if [ -f /etc/win_hosts ]; then
    echo -e "${GREEN}[INSTALLING]\t - linking windows hosts file to ${WHITE}/etc/win_hosts${NC}"
    sudo ln -s ${WORKSPACE_WIN_HOSTS_FOLDER}/hosts /etc/win_hosts
else
    echo -e "${YELLOW}[INSTALLING]\t - ${WHITE}/etc/win_hosts has already been created${NC}"
fi

# LINK WORKSPACE BASH/PROFILE SETTINGS TO USERS HOME FOLDER
echo -e "${GREEN}[INSTALLING]${WHITE}\tCopying over bash and profile configurations${NC}"

for file in $(find ${WORKSPACE_ROOT_FOLDER}/config/bash/ -type f); do
    if [[ -f $file || -d $file ]]; then
        echo -e "${GREEN}[INSTALLING]${NC}\t - copying over to ~/${file##*/}${NC}"
        sleep 1
	    cp --backup=nil -rf ${file} ~/${file##*/}
    fi
done

read -p "${PURPLE}[INSTALLING]${WHITE}${TAB_SPACES}Would you to edit your docker stacks file? [y/N]${NC} "

if [[ $REPLY =~ ^[Yy]$ ]]
then
    vim ~/.docker_stacks
fi

source ~/.bash_profile
echo -e "${GREEN}[INSTALLING]${WHITE}\tNew bash prompt successfully installed${NC}"

