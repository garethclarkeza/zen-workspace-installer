#!/usr/bin/env bash

echo
echo 'Installing Docker'
echo

cd /tmp
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt install docker-ce docker-compose
sudo usermod -aG docker ${USER}

cd ${WORKSPACE_ROOT_FOLDER}/services/
echo
echo 'Installing Laradock'
echo
git clone ${LARADOCK_REPO}
cd laradock
# @todo allow for importing custom backup .env
echo 'Setting up .env file and opening it in VIM for you to edit if required.'
cp env-example .env

echo ''
echo 'Building docker services, this may take a while...'
echo ''

docker-compose build ${DOCKER_STACK1}

echo ''
echo 'Initializing docker services!'
echo ''

docker-compose up -d ${DOCKER_STACK1}

echo ''
echo 'Docker should now be running!'
echo "Visit your new workspace at http://${HOSTNAME}/ from your Windows Host."
docker ps
echo ''

