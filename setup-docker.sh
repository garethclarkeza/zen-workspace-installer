# INSTALLATION AND SETUP OF LARADOCK
if [[ $(cat ${STATUS_FILE}) =~ 'laradock-install' ]]
then
    echo
    echo 'Installing Laradock'
    echo

    if [[ ! -f ${WORKSPACE_ROOT_FOLDER}/readme.md ]]
    then
        echo "${RED}[ERROR]${WHITE} Zen Workspace services folder does not exist... was the workspace installed properly?${NC}"
        exit 1
    fi

    cd ${WORKSPACE_ROOT_FOLDER}/services/
    git clone ${LARADOCK_REPO} laradock
    cd laradock
    git checkout ${LARADOCK_BRANCH}
    git pull origin ${LARADOCK_BRANCH}

    # @todo allow for importing custom backup .env
    echo 'Setting up .env file and opening it in VIM for you to edit if required.'
    cp env-example .env

    echo
    read -p  'Press any key to continue to editing your laradock .env file...'
    echo

    vim .env

    echo 'docker' > ${STATUS_FILE}
fi

# INSTALLATION AND SETUP OF DOCKER
if [[ $(cat ${STATUS_FILE}) =~ 'docker' ]]
then
    echo
    echo 'Installing Docker'
    echo

    cd /tmp
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
    sudo apt install -y docker-ce docker-compose
    sudo usermod -aG docker ${USER}
    sudo systemctl restart ssh

    echo
    echo "${RED}Docker installed. You now need to logged out, please log back in to continue.${NC}"
    echo
    echo 'laradock-build' > ${STATUS_FILE}
    exit 1
fi

# BUILDING AND SPINNING UP DEFAULT LARADOCK ENVIRONMENT
# NOTE - this may fail if your docker group access has not yet been activated
if [[ $(cat ${STATUS_FILE}) =~ 'laradock-build' ]]
then
    if [[ ! -f ${WORKSPACE_ROOT_FOLDER}/readme.md ]]
    then
        echo "${RED}[ERROR]${WHITE} Zen Workspace services folder does not exist... was the workspace installed properly? Did you setup your SSH key in github.com?${NC}"
        exit 1
    fi

    echo
    echo "${WHITE}Building popular docker containers, this may take a while...${NC}"
    echo '------------'

    # INSTALL THE WELCOME PAGE COMPOSER PACKAGES
    cd ${WORKSPACE_ROOT_FOLDER}/www/sandbox/hello
    composer install

    cd ${WORKSPACE_ROOT_FOLDER}/services/laradock
    docker-compose build workspace php-fpm nginx apache2 mongo mysql

    clear
    echo
    echo "${WHITE}Initializing default server!${NC}"
    echo '------------'


    docker-compose up -d nginx

    clear
    echo
    echo "${GREEN}Zen Workspace and Docker should now be up and running!"
    echo "Visit your new workspace at ${WHITE}http://workspace.zen/${GREEN} from your Windows Host.${NC}"
    echo

    docker-compose ps
    echo
fi

