#!/usr/bin/env bash

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
    echo 'Docker installed. You are now going to be logged out, please log back in to continue.'
    echo

    echo 'laradock-install' > ${STATUS_FILE}
fi

# INSTALLATION AND SETUP OF LARADOCK
if [[ $(cat ${STATUS_FILE}) =~ 'laradock-install' ]]
then
    echo
    echo 'Installing Laradock'
    echo

    cd ${WORKSPACE_ROOT_FOLDER}/services/
    git clone ${LARADOCK_REPO} laradock
    cd laradock
    git checkout ${LARADOCK_BRANCH}
    git pull origin ${LARADOCK_BRANCH}

    # @todo allow for importing custom backup .env
    echo 'Setting up .env file and opening it in VIM for you to edit if required.'
    cp env-example .env

    vim .env

    echo
    echo 'Laradock installed'
    echo

    echo 'laradock-build' > ${STATUS_FILE}
fi

# BUILDING AND SPINNING UP DEFAULT LARADOCK ENVIRONMENT
# NOTE - this may fail if your docker group access has not yet been activated
if [[ $(cat ${STATUS_FILE}) =~ 'laradock-build' ]]
then
    echo
    echo 'Building docker services, this may take a while...'
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
    sg docker -c "docker ps"
    echo
fi
