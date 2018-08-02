#!/usr/bin/env bash

echo
echo 'Installing core development tools and features'
echo
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install -y mysql-client-core-5.7 supervisor php${PHP_VERSION} php${PHP_VERSION}-fpm php-pear

echo
echo "Installing PHP${PHP_VERSION} and extensions"
echo

PHP_EXTENSIONS="php${PHP_VERSION}-zip php${PHP_VERSION}-xml php${PHP_VERSION}-sqlite3 php${PHP_VERSION}-soap php${PHP_VERSION}-mysql php${PHP_VERSION}-mbstring php${PHP_VERSION}-bcmath php${PHP_VERSION}-bz2 php${PHP_VERSION}-curl php${PHP_VERSION}-gd php${PHP_VERSION}-intl php-apcu php-geoip php-mongodb php-redis php-ssh2 php-uuid"

sudo apt-get install -y ${PHP_EXTENSIONS}

# INSTALL COMPOSER
echo
echo 'Installing Composer Package Manager'
echo

cd /tmp
curl -o- https://getcomposer.org/installer | php
sudo mv composer.phar ${BASH_SCRIPTS_ROOT}composer
sudo chmod ${BASH_SCRIPTS_DEFAULT_PERMISSIONS} /usr/bin/composer

echo 'completed installing composer'

# INSTALL NODE/NPM/YARN
echo ''
echo 'Installing NodeJS, NPM and Yarn'
echo


cd ${INSTALL_FOLDER}
source setup-node.sh
installNodeSetup
echo 'NPM has been successfully setup'
echo
