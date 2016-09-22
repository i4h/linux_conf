# Linux Conf

This repository holds a collection of helper scripts to synchronize linux configurations across
multiple systems. It also contains a collection of helper scripts, including a script for  managing
notes in the central repository, a quick way to start a bash script from a script templates and more.

## What is this?
The contents of this repository help with the following tasks:
- Managing all your Linux configuration files in a central git repository
- Manage your notes in Github-markdown syntax files in the same repository
- Speeding up common console operations (like adding aliases or creating new bash scripts)

## Who is this for?
These scripts were written to help me work more efficiently on kubuntu and mint distributions where I spend a lot of my time on a bash console. If you have a similar setup, you should be able to use this immediately. If not, the scripts should still work, but have not been tested. There might be portability issues.

## How does it Work?
The files you need on all your machines are kept in one central repository (the hub) and are then pulled from  your terminals. Changes will be pushed to and pulled from the hub to the terminals manually.
To do this, all the configuration files will be stored in the repository on the terminals and then symlinked to the respective paths. This is done automatically by the linux\_conf core scripts. See below for detailed information on the core scripts. 
The configuration files are stored in linux\_conf/confs. For each file, the destination is listed in linux\_conf/confs.conf
Linux_conf is managed from a bash console. The bashrc is divided into several parts:

- .bashrc: The main bashrc file. It contains the basic definitions and then sources the following files:
      - bashrc\_params.sh:    Contains parameters used for lc and otherwise
      - bashrc\_lc.sh:        Contains wrappers for the linux\_conf core scrips and core functions
      - bashrc\_optional.sh:  Contains some useful commands. The corresponding line in bashrc can be removed
      - bashrc\_private.sh:   Your private bashrc code
  
The init script is used to structure your existing .bashrc this way. It will copy your current ~/.bashrc to linux_conf/confs/bashrc_private.sh

## Getting Set Up

In order to get set up, you first need to create a repository on your central hub. Then you can push your configuration files from one of your machines and you're good to go.

### Setting up your Central Hub
You will need a private bare repository (the hub) on a server that is accessible from your terminals. If you want to store the central repository on the current machine under ~/repos/bare/linux_conf, go to your console and run:
````
cd ~/repos/bare
git clone -o GitHub https://github.com/i4h/linux_conf linux\_conf
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
After the init script has run, add more configuration files you want to manage with linux_conf
using `lc_add_conf`
Run `lc_push` or `lc_pp` when you're done to upload your changes to hub.

### Installing linux_conf on more terminals
Now that your configuration files have been imported to your central repository,
you can simply clone and install linux\_conf
````
cd ~/repos/
git clone -o hub you@hub:~/repos/bare/linux\_conf linux\_conf
cd linux_conf
lc_scripts/lc_install.sh
````
This will install all configuration files on your new terminal. Backups of the replaced configuration files
will be stored in linux_conf/oldconfs. These configuration files are by default ignored by git, so you will 
only find them on the machine they were created on.
If you want to merge an existing configuration file into the one existing in linux_conf, run `lc_import` __before__
running lc_install.sh. If you already ran lc_install.sh, copy the old file from the oldconfs folder back to 
the original location.

### Managing your configurations:
After your first installation, a set of lc_* functions will be available 
anywhere on your bash console:
- `lc_add_conf`: This selects existing configuration files to be managed via linux_conf
- `lc_import`: Imports existing configuration files into your repository and lets you merge them with files already in your repository using git difftool.
- `lc_push`: Automatically commit changes on your terminal and push them to the hub
- `lc_install`: Installs the configuration files in managed by linux\_conf on your system. Creates backups of existing files in linux\_conf/backups. Backups will be ignored by git and therefore only remain on the current terminal.
- `lc_pull`: Pull from hub and install.
- `lc_pp`: Pull and push if the pull was successful.
- `lc_notes`: Manage notes in linux\_conf/notes. Run lc_notes -h for details.
- `lc_new_package`: Installs a package via apt-get install and adds it to the end of your note linux\_conf/notes/package.md


