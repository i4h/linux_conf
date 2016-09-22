# Linux Conf

This repository holds a collection of helper scripts that I though might be useful to somebody else.

## What is this?
The contents of this repository help with the following tasks:
- Managing all your linux configuration files in a central git repository
- Manage your notes in github-markdown syntax files in the same repository
- Help with common tasks on the command line

## Who is this for?
These scripts were written to help me work more efficiently on kubuntu and mint distributions where I spend a lot of my time on a bash console. If you have a smilar setup, you should be able to use this immediately. If not, the scripts should still work, but have probably not been tested. There might be portability issues.

## How does it Work?
The files you need on all your machines are kept in one central repository (the hub), and then pulled from  your terminals. Changes will be pushed to and pulled from the hub to the terminals manually (but easily).
To do this, all the configuration files will be stored in the repository on the terminals and then symlinked to the respective paths. This is done automatically by the linux\_conf core scripts. See below for detailed  information on the core scripts. 
The configuration files are stored in linux_conf/confs. For each file, the destination is listed in linux\_conf/confs.conf
Linu_conf is managed from a bash console. To facilitate this, the bashrc is divided into several parts:

- .bashrc: The main bashrc file:
   - Contains base definitions for linux_conf
   - Includes the other files
   - Contains all your private bash configuration
- .bashrc_lc: Contains the essential bash_rc definitions
- .bashrc_recommended: Contains some useful bash aliases and funcitons
  If you don't want to use the contents of this file, remove its corresponding 
  block from linux_conf/confs.conf
  
The init script is used to structure your existing .bashrc this way.


## Getting Set Up

In order to get set up you first need to create a repository on your central hub. Then you can push your configuration files from one of your machines and your good to go.

### Setting up your Central Hub
You will need a private bare repository on a server that is accessible from your terminals (the hub). If you want to store the central repository on this machine under ~/repos/bare/linux_conf, go to you console and run:
````
cd ~/repos/bare
git clone -o github https://github.com/i4h/linux_conf linux\_conf
````

### Installing linux_conf on your first Terminal
Let's assume you want to store linux\_conf on your terminal in ~/repos/linux\_conf
To install linux\_conf on your __first__ terminal, run:
````
cd ~/repos/
git clone -o hub you@hub:~/repos/bare/linux\_conf linux\_conf
cd linux_conf
lc_scripts/lc_init.sh
````
The init script will take you through your first setup.

### Managing your configurations:
After your first installation, a set of lc_* functions will be available 
anywhere on your bash console:
- `lc_add_conf`: This selects existing configuration files to be managed via linux_conf
- `lc_import`: Imports existing configuration files into your repository and lets you merge them with files already in your repository using git difftool.
- `lc_push`: Automatically commit changes on your terminal and push them to the hub
- `lc_install`: Installs the configuration files in managed by linux\_conf on your system. Creates backups of existing files in linux\_conf/backups. Backups will be ignored by git and therefore only remain on the current terminal.
- `lc_pull`: Pull from hub and install.
- `lc_pp`: Pull and push if pull was successful.
- `lc_notes`: Manage notes in linux\_conf/notes. Run lc_notes -h for details.
- `lc_new_package`: Installs a package via apt-get install and adds it to the enx of your note linux\_conf/notes/package.md


