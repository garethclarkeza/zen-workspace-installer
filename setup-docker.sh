# INSTALLATION AND SETUP OF LARADOCK
if [[ $(cat ${STATUS_FILE}) =~ 'laradock-install' ]]
then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tInstalling Laradock"

    cd ${WORKSPACE_ROOT_FOLDER}/services/
#    git clone ${LARADOCK_REPO} laradock
    cd laradock
#    git checkout ${LARADOCK_BRANCH}
#    git pull origin ${LARADOCK_BRANCH}

    # @todo allow for importing custom backup .env
    echo -e "${GREEN}[INSTALLING]${WHITE}\tSetting up .env file and opening it in VIM for you to edit if required."
#    cp env-example .env

    read -p  "${PURPLE}[INSTALLING]${WHITE}${TAB_SPACES}Would you like to edit your laradock .env file now? [y/N] "

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        vim .env
    fi

    update_status 'docker'
fi

# INSTALLATION AND SETUP OF DOCKER
if [[ $(cat ${STATUS_FILE}) =~ 'docker' ]]
then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tInstalling Docker${NC}"

    cd /tmp
#    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
#    sudo apt install -y docker-ce docker-compose
#    sudo usermod -aG docker ${USER}
#    sudo systemctl restart ssh

    echo -e "${PURPLE}[INSTALLING]${WHITE}\tDocker has been installed. You now need to logged out, please log back in to continue.${NC}"
    update_status 'laradock-build'
    echo
    exit 0
fi

# BUILDING AND SPINNING UP DEFAULT LARADOCK ENVIRONMENT
# NOTE - this may fail if your docker group access has not yet been activated
if [[ $(cat ${STATUS_FILE}) =~ 'laradock-build' ]]
then
    die_if_workspace_is_not_installed
    die_if_laradock_is_not_installed

    echo "${WHITE}Building popular docker containers, this may take a while...${NC}"
    echo '-----------------------------------------------------------------------------'

    # INSTALL THE WELCOME PAGE COMPOSER PACKAGES
    cd ${WORKSPACE_ROOT_FOLDER}${WELCOME_PAGE_PATH}
#    composer install

    cd ${WORKSPACE_ROOT_FOLDER}/services/laradock
#    docker-compose build php-fpm
#    docker-compose build nginx

    clear
    echo
    echo "${WHITE}Initializing default server!${NC}"
    echo '----------------------------------------------------------------------------'

#    docker-compose up -d nginx

    clear
    echo
    echo "${GREEN}Zen Workspace and Docker should now be up and running!"
    echo "Visit your new workspace at ${WHITE}http://workspace.zen/${GREEN} from your Windows Host.${NC}"
    echo

#    docker-compose ps
#    echo
fi

