# INSTALLATION OF SOME DEV UTILS, MYSQL CLIENT, SUPERVISOR, JRE AND PHP
if [[ $(cat ${STATUS_FILE}) = 'dev-utils' ]]
then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tInstalling core development tools and features${NC}"

    UTILS_TO_INSTALL=" \
        mysql-client-core-5.7 \
        supervisor \
        rar \
        unrar \
        zip \
        unzip \
        cifs-utils \
        libpng-dev \
        traceroute \
        php${PHP_VERSION} \
        php${PHP_VERSION}-fpm \
        php-pear "

    echo -e "${GREEN}[INSTALLING]${WHITE}\tChecking if valid JDK version supplied in .env file...${NC}"
    echo
    echo -e "\tNo valid version found (${WHITE}8 & 9 supported${NC}), if you want to install a JDK, enter a valid version number or"
    echo -e "\tany other key to continue... (JDK is optional)"
    echo
    read -p "${PURPLE}[INSTALLING]${WHITE}${TAB_SPACES}Enter a valid Java JDK version (8 or 9) or press any other key to skip installing Java${NC} ${WHITE}[*/8/9]${NC} " -n 1 -r

    if [[ $REPLY =~ ^[89]$ ]]
    then
        UTILS_TO_INSTALL+=" openjdk-${JDK_VERSION}-jre "
    fi

    sudo apt install -y ${UTILS_TO_INSTALL}
    clear

    update_status 'dev-utils-mongo'
fi

# SETUP MONGO UTILS IF REQUESTED
if [[ $(cat ${STATUS_FILE}) =~ 'dev-utils-mongo' ]]
then
    if [[ ${MONGO_UTILS} = true || ${MONGO_SHELL} = true ]]
    then
        echo -e "${GREEN}[INSTALLING]${WHITE}\tSetting up MongoDB packages${NC}"
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
        echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
        sudo apt-get update

        MONGO_UTILS_TO_INSTALL=''

        if [ ${MONGO_UTILS} = true ]; then
            MONGO_UTILS_TO_INSTALL+='mongo-org-tools '
        fi

        if [ ${MONGO_SHELL} = true ]; then
            MONGO_UTILS_TO_INSTALL+='mongo-org-shell '
        fi

        sudo apt-get install -y ${MONGO_UTILS_TO_INSTALL}
    fi

    update_status 'dev-utils-php-ext'
fi

# INSTALLATION PHP extensions for selected PHP version
if [[ $(cat ${STATUS_FILE}) =~ 'dev-utils-php-ext' ]]
then
    clear
    echo -e "${GREEN}[INSTALLING]${WHITE}\tInstalling PHP${PHP_VERSION} extensions${NC}"

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
    sleep 2
    clear
    echo -e "${GREEN}[INSTALLING]${WHITE}\tPHP${PHP_VERSION} extensions have been installed?${NC}"
    update_status 'dev-utils-composer'
fi

# INSTALL COMPOSER
if [[ $(cat ${STATUS_FILE}) =~ 'dev-utils-composer' ]]
then
    clear
    echo -e "${GREEN}[INSTALLING]${WHITE}\tInstalling Composer PHP package manager${NC}"

    cd /tmp
    curl -o- https://getcomposer.org/installer | php
    sudo mv composer.phar ${BASH_SCRIPTS_ROOT}/composer
    sudo chmod ${BASH_SCRIPTS_DEFAULT_PERMISSIONS} ${BASH_SCRIPTS_ROOT}/composer

    sleep 2
    clear
    update_status 'dev-utils-node'
fi

# INSTALL NODE/NPM/YARN
if [[ $(cat ${STATUS_FILE}) =~ 'dev-utils-node' ]]
then
    clear
    echo -e "${GREEN}[INSTALLING]${WHITE}\tInstalling NodeJS, NPM and Yarn via NVM${NC}"
    . ${INSTALL_FOLDER}/setup-node.sh
    install_node_setup
    sleep 2
    clear
fi
