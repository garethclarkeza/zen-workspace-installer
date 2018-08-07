echo -e "${GREEN}[INSTALLING]${WHITE}\tSetting up SSH key${NC}"
cd ~
# @todo allow for importing custom backup ssh files

if [[ ! -d ~/.ssh ]]
then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tCreating SSH folder${NC}"
#    mkdir ~/.ssh > /dev/null
fi

#chmod -R 700 ~/.ssh > /dev/null

if [[ ! -f ~/.ssh/id_rsa ]]
then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tGenerating your private and public keys${NC}"
#    ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -P ""
fi

# COPY OVER FREQUENTLY USED TRUSTED HOSTS
if [[ ! -f ~/.ssh/known_hosts ]]
then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tAdding trusted known hosts${NC}"
#    cat ${INSTALL_FOLDER}/known_hosts >> ~/.ssh/known_hosts
fi

# THIS WILL FORCE A PASSWORD REQUEST FOR SUDO, AFTER THIS THE SUDOERS FILE CAN BE UPDATED SO PASSWORD IS NO LONGER REQUIRED WHEN USING SUDO
#sudo apt-get -y install xclip > /dev/null

# CHECK TO SEE IF A NO PASSWORD RECORD EXISTS FOR THE CURRENT USER BEFORE ADDING IT
HAS_SUDOERS_NOPASSWD=false

echo -e "${GREEN}[INSTALLING]${WHITE}\tChecking your sudoers permissions${NC}"
sudo cat /etc/sudoers | while read line
do
    if [[ "${line}" =~ "ALL=(ALL) NOPASSWD: ALL" && "${line}" =~ "${USER}" ]]
    then
        HAS_SUDOERS_NOPASSWD=true
    fi
done

if [[ ${HAS_SUDOERS_NOPASSWD} = true ]]
then
    echo -e "${YELLOW}[SKIPPING]${WHITE}\tA record for your user already exists in the sudoers files.${NC}"
else
    echo -e "${GREEN}[INSTALLING]${WHITE}\tAdding your user to sudoers file so you no longer have to type your password when you sudo :)${NC}"
#    echo -e "${USER}\tALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers > /dev/null
fi

#cat ~/.ssh/id_rsa.pub | xclip

echo
echo "${YELLOW}x--------------------------------------------------------------------------------------------------------------------------------------x"
echo
echo -e "\t${GREEN}Your public key has been copied to your clipboard!${WHITE}"
echo
cat ~/.ssh/id_rsa.pub
echo
echo -e "\t${BLUE}In order to setup the system more easily, please add your ssh public key to github.com, bitbucket.org, gitlab or any services/repositories you use:${WHITE}"
echo
echo -e "\tMake sure you have loaded your private key into pageant and that it is running, copy the OpenSSH public key that you got when generating your"
echo -e "\tkey and paste it into the editor that opens."
echo
echo "${YELLOW}x--------------------------------------------------------------------------------------------------------------------------------------x${NC}"
echo

# @todo copy public key over to any approved hosts (tbd)

read -p "${GREEN}[INSTALLING]${WHITE}${TAB_SPACES}Would you like to edit the authorized hosts file to add your SSH key? [y/N] ${NC}"

if [[ $REPLY =~ ^[Yy]$ ]]
then
    vim ~/.ssh/authorized_keys
fi

echo
echo "${YELLOW}x--------------------------------------------------------------------------------------------------------------------------------------x${NC}"
echo
echo -e "\t${GREEN}SSH has been successfully setup, here are you credentials to add to your Windows SSH client to connect to this server, you should"
echo -e "\tstart your VM in headless mode and only connect via your SSH client.${YELLOW}"
echo
echo -e "\tIP Address:\t${WHITE}$(hostname  -I | cut -f1 -d' ')${YELLOW}"
echo -e "\tUsername:\t${WHITE}${USER}${YELLOW}"
echo -e "\tPassword:\t${WHITE}***** (use your putty private key that you previously used above or your password if you really want)${YELLOW}"
echo -e "\tPort:\t\t${WHITE}22${YELLOW}"
echo
echo "${YELLOW}x--------------------------------------------------------------------------------------------------------------------------------------x${NC}"
echo "${NC}"
read -p  'Press any key to continue...'

#sudo systemctl restart ssh > /dev/null
