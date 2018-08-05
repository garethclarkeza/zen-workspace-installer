# INSTALLATION OF SOME DEV UTILS, MYSQL CLIENT, SUPERVISOR, JRE AND PHP
if [[ $(cat ${STATUS_FILE}) = 'dev-utils' ]]
then
    echo
    echo ' -> Installing core development tools and features'
    echo

    UTILS_TO_INSTALL=" \
        mysql-client-core-5.7 \
        supervisor \
        rar \
        unrar \
        zip \
        unzip \
        php${PHP_VERSION} \
        php${PHP_VERSION}-fpm \
        php-pear "

    echo
    echo 'Checking if valid JDK version supplied in .env file...'
    echo
    echo "No valid version found (${WHITE}8 & 9 supported${NC}), if you want to install a JDK, enter a valid version number or"
    echo 'any other key to continue... (JDK is optional)'
    echo
    read -p "${RED}Enter a valid Java JDK version (8 or 9) or press any other key to skip installing Java${NC} [*/8/9]" -n 1 -r
    echo

    if [[ $REPLY =~ ^[89]$ ]]
    then
        UTILS_TO_INSTALL+=" openjdk-${JDK_VERSION}-jre "
    fi

    sudo apt install -y ${UTILS_TO_INSTALL}

    echo 'dev-utils-php-ext' > ${STATUS_FILE}
fi

# INSTALLATION PHP extensions for selected PHP version
if [[ $(cat ${STATUS_FILE}) =~ 'dev-utils-php-ext' ]]
then
    clear
    echo
    echo " -> Installing PHP${PHP_VERSION} extensions"
    echo

    PHP_EXTENSIONS=" \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-sqlite3 \
        php${PHP_VERSION}-soap \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-bz2 \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-intl \
        php-apcu \
        php-geoip \
        php-mongodb \
        php-redis \
        php-ssh2 \
        php-uuid "

    sudo apt install -y ${PHP_EXTENSIONS}

    echo 'dev-utils-composer' > ${STATUS_FILE}
fi

# INSTALL COMPOSER
if [[ $(cat ${STATUS_FILE}) =~ 'dev-utils-composer' ]]
then
    clear
    echo
    echo ' -> Installing Composer PHP package manager'
    echo

    cd /tmp
    curl -o- https://getcomposer.org/installer | php
    sudo mv composer.phar ${BASH_SCRIPTS_ROOT}composer
    sudo chmod ${BASH_SCRIPTS_DEFAULT_PERMISSIONS} /usr/bin/composer

    echo 'dev-utils-node' > ${STATUS_FILE}
fi

# INSTALL NODE/NPM/YARN
if [[ $(cat ${STATUS_FILE}) =~ 'dev-utils-node' ]]
then
    clear
    echo
    echo ' -> Installing NodeJS, NPM and Yarn'
    echo
    cd ${INSTALL_FOLDER}
    source setup-node.sh
    installNodeSetup
    clear
fi

