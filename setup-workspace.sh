echo -e "${GREEN}[INSTALLING]${WHITE}\tFetching the latest version of Zen Workspace${NC}"
echo -e "${GREEN}[INSTALLING]${WHITE}\tCloning Zen Workspace from ${WORKSPACE_REPO} into ${WORKSPACE_APP_FOLDER}${NC}"

cd /
git clone -q --progress ${WORKSPACE_REPO} ${WORKSPACE_APP_FOLDER}
cd ${WORKSPACE_APP_FOLDER}

echo -e "${GREEN}[INSTALLING]${WHITE}\tChecking out Zen Workspace branch: ${WORKSPACE_REPO_BRANCH}${NC}"
sleep 1
git checkout ${WORKSPACE_REPO_BRANCH}

if [ ! -d ${WORKSPACE_WWW_FOLDER} ]; then
    sudo mkdir ${WORKSPACE_WWW_FOLDER}
    sudo chown -R ${USER}:${USER} ${WORKSPACE_WWW_FOLDER}
    sudo chmod -R 775 ${WORKSPACE_WWW_FOLDER}
fi

if [[ ! -d ${WORKSPACE_WWW_FOLDER}/repo && -d ${WORKSPACE_APP_FOLDER}/repo ]]; then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tCopying repo folder over to www${NC}"
    cp -r ${WORKSPACE_APP_FOLDER}/repo ${WORKSPACE_WWW_FOLDER}/repo
fi

if [[ ! -d ${WORKSPACE_WWW_FOLDER}/logs && -d ${WORKSPACE_APP_FOLDER}/logs ]]; then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tCopying logs folder over to www${NC}"
    cp -r ${WORKSPACE_APP_FOLDER}/logs ${WORKSPACE_WWW_FOLDER}/logs
fi

if [[ ! -d ${WORKSPACE_WWW_FOLDER}/sandbox && -d ${WORKSPACE_APP_FOLDER}/sandbox ]]; then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tCopying sandbox folder over to www${NC}"
    cp -r ${WORKSPACE_APP_FOLDER}/sandbox ${WORKSPACE_WWW_FOLDER}/sandbox
fi

if [[ ! -d ${WORKSPACE_WWW_FOLDER}/readme.md && -d ${WORKSPACE_APP_FOLDER}/readme.md ]]; then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tCopying readme file over to www${NC}"
    cp -r ${WORKSPACE_APP_FOLDER}/readme.md ${WORKSPACE_WWW_FOLDER}/readme.md
fi

#@todo - see how windows deals with this
if [[ ! -d ${WORKSPACE_WWW_FOLDER}/packages && -d ${WORKSPACE_APP_FOLDER}/packages ]]; then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tLinking packages folder into www${NC}"
    ln -s ${WORKSPACE_APP_FOLDER}/packages ${WORKSPACE_WWW_FOLDER}/packages
fi

if [[ ! -d ${WORKSPACE_WWW_FOLDER}${WORKSPACE_WELCOME_PAGE} && -d ${WORKSPACE_APP_FOLDER}${WORKSPACE_WELCOME_PAGE} ]]; then
    cp -r ${WORKSPACE_APP_FOLDER}/hello ${WORKSPACE_WWW_FOLDER}/hello
fi

die_if_workspace_is_not_installed

echo -e "${GREEN}[INSTALLING]${WHITE}\tInstalling workspace scripts${NC}"
install_workspace_scripts
echo -e "${GREEN}[INSTALLING]${WHITE}\tCompleted installing workspace scripts${NC}"
echo -e "${GREEN}[INSTALLING]${WHITE}\tSetting up default hosts${NC}"

# @todo - check if access is available to windows hosts file
# add windows_host with the clients connected IP address to ubuntu hosts file
manage-hosts updatehost windows.host ${HOST_IP} > /dev/null
manage-hosts updatehost *.zen 0.0.0.0 > /dev/null

# add ubuntu servers IP address to windows under the selected ubuntu hostname
manage-hosts win-updatehost ${HOSTNAME} ${WORKSPACE_IP} > /dev/null
manage-hosts win-updatehost hello.zen ${WORKSPACE_IP} > /dev/null
manage-hosts win-updatehost workspace.zen ${WORKSPACE_IP} > /dev/null

echo -e "${GREEN}[INSTALLING]${WHITE}\tSetting up workspace links to windows volumes${NC}"

# ~/WORKSPACE LINKING
if [ ! -d ~/www ]; then
    echo -e "${GREEN}[INSTALLING]\t - linking workspace to ${WHITE}~/workspace${NC}"
    ln -s ${WORKSPACE_WWW_FOLDER} ~/www
else
    echo -e "${YELLOW}[INSTALLING]\t - ${WHITE}~/workspace has already been created${NC}"
fi

# WIN_HOSTS LINKING
if [ ! -f /etc/win_hosts ]; then
    echo -e "${GREEN}[INSTALLING]\t - linking windows hosts file to ${WHITE}/etc/win_hosts${NC}"
    sudo ln -s ${WORKSPACE_WIN_HOSTS_FOLDER}/hosts /etc/win_hosts
else
    echo -e "${YELLOW}[INSTALLING]\t - ${WHITE}/etc/win_hosts has already been created${NC}"
fi

# LINK WORKSPACE BASH/PROFILE SETTINGS TO USERS HOME FOLDER
echo -e "${GREEN}[INSTALLING]${WHITE}\tCopying over bash and profile configurations${NC}"

for file in $(find ${WORKSPACE_APP_FOLDER}/config/bash/ -type f); do
    if [[ -f ${file} || -d ${file} ]]; then
        echo -e "${GREEN}[INSTALLING]${NC}\t - linking to ~/${file##*/}${NC}"
        sleep 1

        if [[ -f ~/${file##*/} ]]; then
            mv ~/${file##*/} ~/~${file##*/}
        fi

        sleep 1
	    ln -s ${file} ~/${file##*/}
    fi
done

read -p "${PURPLE}[INSTALLING]${WHITE}${TAB_SPACES}Would you to edit your docker stacks file? [y/N]${NC} "

# @todo - don't use this file, use the .zen env file
if [[ $REPLY =~ ^[Yy]$ ]]
then
    vim ~/.docker_stacks
fi

source ~/.bash_profile
echo -e "${GREEN}[INSTALLING]${WHITE}\tNew bash prompt successfully installed${NC}"
