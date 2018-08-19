# Zen Workspace Installer

*This project (including zen-workspace) is still under early development and documentation may not be up to date! Use at own risk.*

## Setting up the Zen Workspace system on a Windows 10 host

Zen Workspace (geared towards php and node stacks) is an attempt to make developing on Windows as painless as possible. You setup a VirtualBox VM via the guide below and then use an install script to setup your linux image (Ubuntu Server 18.04 currently).

The install script will setup your complete workspace environment. You need to have a workspace sync folder where there workspace folder you on working on in your VM is backed up to, this folder *should* be empty. 

The other main component of the Zen Workspace is the use of Docker and Docker Compose managed via Laradock. You can run multiple projects at the same time via virtual hosts configuration, as well as easily switching in and out services and new versions.

### Requirements

To get going with setting up your own Zen Workspace, please carry on reading on what you need to do before you get going.

1. If you have Docker installed, completely remove it.
1. If you have Hyper-V enabled, this will need to be disabled.
    1. Hit the Windows Key and type “windows features”
    1. Hit the Windows ```Key + W``` combo to bring up the Windows Settings panel of the Start Screen.
    1. Click on Turn Windows features on or off.
    1. When the Turn Windows features on or off dialog appears, look for Hyper-V and deselect it.
    1. Click OK.
    1. Restart your computer when prompted.
1. Make sure you have VirtualBox installed.
1. Download this image: http://archive.ubuntu.com/ubuntu/dists/bionic-updates/main/installer-amd64/current/images/netboot/mini.iso
1. While technically not required, to save you having to use passwords to access the linux server, you should create a SSH key/pair. For help on doing this you can read https://www.ssh.com/ssh/putty/windows/puttygen
1. Have a github.com account. (you will need to add an ssh key to your github account)
1. If you have not already - install PuTTY, PuTTYgen and Pageant. (for an SSH client, I recommend using WinSSHterm - but you can use whatever you prefer)
1. Make sure you have your favourite code editor installed and for way less hair pulling down the line, make sure you code editors save line endings in UNIX/MAC format which is ```\n``` and not the Windows ```\r\n```.
1. Make sure you have created your *EMPTY* workspace sync/backup folder in the location you want it.
1. [OPTIONAL] This may be a little insecure, however, for easy and more automated management of your Windows hosts file, I suggest giving modify access to your ```C:\Windows\System32\drivers\etc\hosts``` which you will later share onto your linux server. To do this, right-click on the hosts file in windows > propreties > security > edit (you need to be an admin)
    1. If your name is already in the list, then click on it and give it modify, read & execute, read and write access
    1. If your name is not there click add
    1. In the bottom box type your Windows username and then click check names, it should match and format it correctly
    1. The as in the first step, go to the user once added and give the correct permissions

The following tools are not required on Windows, but may make your development experience more enjoyable as you can run these from Windows just as you would from Linux.

 - php (the same version you use on your ubuntu server)
 - composer
 - node/npm/yarn
 - git

### Installation
Once you have met the above requirements, please do a fresh restart and then continue below.


#### Virtual Box
The first thing you will need to do is setup a VirtualBox VM. In the VirtualBox Manager, make sure no other VM's are running.


##### Setting up a new VM
 - Create a new VM
 - Click "expert mode"
 - Name it something based on use and os eg. ```WORKSPACE-UBUNTU18-SERVER```
 - Type: Linux
 - Version: Ubuntu (64-bit)
 - Memory Size: > 1024MB (I would suggest giving the server between 2048 - 4096MB depending on what you can spare from your system)
 - Hard disk: Create a virtual disk now
 - Click *Create*

##### Create Virtual Hard Disk
 - File location: use the default or select your own location (whichever drive this is on is where the space required for the VM is going to come from, although I suggest this space be on a SSD drive for better performance)
 - File size: > 25GB (from personal experience 25GB is the absolute minimum that should be attempted - especially when dealing with large databases, if you have the space I would suggest a minimum of around >60GB)
 - Hard disk file type: VDI
 - Storage on physical location: either fixed size or dynamically allocated that only allocates the space to the VM when it is required (although it does not get smaller by itself)
 - Click *Create*

##### Finalize Setup of VM
 - Your new VM should be created now
 - Firstly, inside VirtualBox file menu > "Host network manager"
 - Create a new adapter, no dhcp, ip 192.168.100.101, netmask 255.255.255.0
 - Then right-click on your new VM and edit the settings
 - Under: General > Advanced - just set both the shared clipboard and drag'ndrop to bidirectional
 - Under: System > Motherboard
    - make sure you are happy with the amount of memory you shared
    - in the boot order options, uncheck floppy, and move hard disk to the very top and optical in second position and must be checked
 - Under: System > Processor
    - This is really gonna depend on your CPU and how many threads it has. If you can spare it I would suggest 2 processors (you can always change this later)
    - Enable PAE/NX (important!)
 - Under: Display > Screen
    - Since there is not much need for it (unless you use X-Server or something), I just share 64mb video memory
    - Don't change any of these settings unless you know what you doing and want to
 - Under: Storage
    - You will see a CD icon saying *Empty* under the IDE controller
    - Click on it and under attributes that come up on the right, click the CD icon and click 'Choose Virtualbox Optical Disk File'
    - Select the ISO image that you downloaded above, the ubuntu server mini.iso
 - Under: Audio
    - Disable (unless for some reason you want it)
 - Under: Network > Adapter 1
    - Enable network adapter
    - Change the attached to Host-only Adapter and select the new adapter you created
 - Under: Network > Adapter 2
    - Enable network adapter (it should already be enabled)
    - Change the attached to NAT
 - Under: Shared Folders
    - Add a new share (this will be your workspace backup/sync)
    - Folder path: find your *EMPTY* workspace sync folder that you will be using
    - Folder name: workspace_sync
    - Read-only: disabled
    - Auto-mount: enabled
    - Click OK
    - Add another new share (this will be a link to your windows hosts folder - very important that the access to this folder was setup as instructed above)
    - Folder path: C:\Windows\System32\drivers\etc
    - Folder name: win_hosts
    - Read-only: disabled
    - Auto-mount: enabled
    - Click OK
- Under: User Interface
    - I just uncheck all the boxes, unless you really need any of these options you can disable them all, especially since we will be running in headless mode.
- and that is it for configuring your VM! Click the OK button at the bottom to save changes


#### Ubuntu Server 18.04 Setup
 - Start the VM in normal mode
 - A menu with will up on the screen, follow along below...
 - install
 - select language, country and keyboard layout (dont autodetect keyboard)
 - when the configure the network window comes up, select enp0s8
 - enter a hostname
 - select mirror location, package and proxy

```..................................installing :<```

 - enter your full name
 - username (something short and lower case "eg. ubuntu, your-name")
 - select a password
 - select timezone
 - partition: guided - use entire disk and select the disk to partition (there should only be one) and then write changes to disk when it asks

```..................................installing :<```

 - how to manage system upgrades? upto u, but i suggest install security update automatically
 - additional software selection, here was my selection:
    - samba file server
    - large selection of fonts (may be required for certain graphics libraries)
    - openssh server (important)
    - basic ubuntu server (important unless you install the stuff you need from this package manually)

```..................................installing :<```

 - Install GRUB boot loader = yes
 - set clock to UTC
 - when "installation complete" -> continue
 - the server will reboot and you will be given a login prompt

#### Final Pre-installation tasks (after installing your VM)
 - When the VM has finished rebooting, a login prompt will appear, login with your username and password
 - Type the following command: ```hostname  -I | cut -f1 -d' '``` this will output the VMs IP address, copy this
 - Now shutdown your VM and stop it completely
 - Once your VM is no longer running, go back into its settings
 - Under: Storage
    - Select the CD drive again (it should show the name of the ubuntu iso)
    - In the attributes, click the CD icon and choose VBoxGuestAdditions.iso from the options
 - Save your settings and restart your VM in headless mode

#### Server, Zen Workspace and Docker
 - Once your server boots back up (may take a minute), then you should be able to login with your SSH client
 - Use your SSH client and login to your linux server VM with the IP address you got and your username and password on port 22. You may also want to add your PPK private key to your connection (it will fail at first until we get SSH setup correctly, but you just use your password as fallback)
 - Run ```git config --global user.email "your@email.address" && git config --global user.name "Your Name" && git config --global core.editor "vim"``` (i set my default editor to vim, but you can use whatever u want)
 - Zen Workspace is installed via an install script, to get start, on your Linux Server, go to your home folder ```cd ~``` and then ```git clone https://github.com/garethclarkeza/zen-workspace-installer.git``` and enter your github username/password
 - ```cd ~/zen-workspace-installer```
 - ```chmod 775 ./*.sh```
 - ```./install.sh```
 - Follow the prompts, the process will stop occasionally to allow you to exit and re-login (this is for certain group access refreshing)
 - This will then allow the process to continue where you left off on your installation.
 - Follow the output and prompts.
 - Well done! :P Your Linux Server with docker support and development environment server is now running.
 - Open your browser, the welcome page should be visible at http://workspace.zen/.
 
##### Want your VM to boot into headless mode automatically on Windows startup?
 - go to ```C:\Users\<username>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup```
 - create a new text file called ```whatever-you-want.bat```
 - edit in notepad and add ```"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" startvm "NameOfYourVM" --type "headless"```, replacing NameOfYourVM.
 - next time you restart your VM should automatically boot in headless mode


### What Now?

Better documentation and installation workflow. Coming soon, readme will soon be updated in the zen-workspace readme file.
