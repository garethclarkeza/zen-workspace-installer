read -p "${PURPLE}[INSTALLING]${WHITE}${TAB_SPACES}Have you set the CDROM in VirtualBox to use the VBoxLinuxAdditions.iso ?${NC} ${WHITE}[y/N]${NC} " -n 1 -r

echo

if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo -e "${GREEN}[INSTALLING]${WHITE}\tUpdating package manager and installing required packages..."

    sudo apt-get update -yqq && sudo apt-get upgrade -yqq
    sudo apt-get install -y dkms build-essential linux-headers-generic apt-transport-https linux-headers-$(uname -r)

    clear
    echo -e "${GREEN}[INSTALLING]${WHITE}\tSetting up mount to load the VBox Linux Additions"

    sudo mkdir /media/cdrom
    sudo mount -r /dev/cdrom --target /media/cdrom

    if [[ ! -d /media/cdrom/ || ! -f /media/cdrom/VBoxLinuxAdditions.run ]]
    then
        echo -e "${RED}[ERROR]${WHITE}\t\t\tFailed to locate VBoxLinuxAdditions on the cdrom mount"
        echo -e "${RED}[ERROR]${WHITE}\t\t\tPlease check that you have loaded the ISO correctly and try again"
        exit 2
    fi

    cd /media/cdrom/

    echo -e "${GREEN}[INSTALLING]${WHITE}\tRunning VBox Linux Additions${NC}"

    sudo groupadd -g 998 vboxsf
    sudo usermod -aG vboxsf ${USER}
    sudo ./VBoxLinuxAdditions.run
else
    echo -e "${RED}[ERROR]${WHITE}\t\t\tPlease insert the guest additions iso into the VM as per readme file and then try again!${NC}"
    echo
    read -p "Press any key to exit"
    exit 5
fi
