#!/usr/bin/env bash

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

    echo
    echo 'Laradock installed'
    echo

    echo 'laradock-build' > ${STATUS_FILE}
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
    exit 0
fi

# BUILDING AND SPINNING UP DEFAULT LARADOCK ENVIRONMENT
# NOTE - this may fail if your docker group access has not yet been activated
if [[ $(cat ${STATUS_FILE}) =~ 'laradock-build' ]]
then
    echo
    echo 'Building popular docker containers, this may take a while...'
    echo

    cd ${WORKSPACE_ROOT_FOLDER}/services/laradock
    sg docker -c "docker-compose build nginx apache2 php-fpm redis mongo mysql workspace"

    echo
    echo 'Initializing docker services!'
    echo

    sg docker -c "docker-compose up -d ${DOCKER_STACK1}"

    echo
    echo 'Docker should now be running!'
    echo "Visit your new workspace at http://${HOSTNAME}/ from your Windows Host."
    sg docker -c "docker-compose ps"
    echo
fi
