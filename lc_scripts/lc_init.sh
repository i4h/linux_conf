#!/bin/bash
# File: lc_init.sh
# This file helps you set up linux_conf on your first terminal
# See https://github.com/i4h/linux_conf for a detailed readme
#
# Author: Ingmar Vierhaus <mail@ingmar-vierhaus.de>
#

set -o nounset
set -o errexit
# Global variables
SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
EXIT_BUG=10
# Initialize Variables defined by option switches
VERBOSE=n
OPTFILE=""
# function definitions 
function usage {
 echo "Usage: $SCRIPTNAME [-h] [-v] [-o arg] file ..." >&2
 echo "Initializes linux_conf on your first terminal"
 echo ""
 echo "Options: "
 echo " -h        show this help"
 echo " -v        verbose mode"
 [[ $# -eq 1 ]] && exit $1 || exit $EXIT_FAILURE
}
# List of Arguments. Option flags followed by a ":" require an option, flags not followed by an ":" are optionless
while getopts ':o:vh' OPTION ; do
 case $OPTION in
 v) VERBOSE=y
 ;;
 o) OPTFILE="$OPTARG"
 ;;
 h) usage $EXIT_SUCCESS
 ;;
 \?) echo "Option \"-$OPTARG\" not recognized." >&2
 usage $EXIT_ERROR
 ;;
 :) echo "Option \"-$OPTARG\" requires an argument." >&2
 usage $EXIT_ERROR
 ;;
 *) echo "Something impossible happened, stand by for implosion of space time continuum."
>&2
 usage $EXIT_BUG
 ;;
 esac
done
# Shift over used up arguments
shift $(( OPTIND - 1 ))

# Loop over all arguments
for ARG ; do
 if [[ $VERBOSE = y ]] ; then
     echo -n "Argument: "
     echo $ARG
 fi
done

echo ""
echo "This script will initialize linux_conf by"
echo " - Setting the correct directory containing linux_conf in linux_conf/confs/bashrc"
echo " - Copying your current ~/.bashrc to linux_conf/confs/bashrc_private.sh"
echo " - Installing linux_conf, which will replace your old bashrc by a symlink to linux_conf/confs/bashrc"
echo "   This file in turn includes bashrc_private, so that all definitions from your old ~/.bashrc will be available"
echo ""
echo "If this is successful, linux_conf will be set up. To get started"
echo 'you need to open a new  console, or run "source  .bashrc"'
echo "After this, you will be able to import more configuration files to be managed by linux_conf"

while false; do
    read -p "Do you wish to proceed? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "Aborting"; exit;;
        * ) echo "Please enter y or n.";;
    esac
done


dir=`dirs | cut -d " " -f 4`
repoDir=${dir%/linux_conf}


while true; do
    read -p "The directory containing linux_conf was identified as "'"'$repoDir'"'". Is this correct? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) 
	    echo 
	    read -p 'Please enter the correct directory without trailing "/". Use ~ as the starting point: ' repoDir
	    break
	    ;;
	
        * ) echo "Please enter y or n.";;
    esac
done

echo -n "Updating confs/bashrc... "
sed -i "s@repoDir=.*@repoDir=$repoDir@" confs/bashrc
echo "done"

echo -n "Copying ~/.bashrc to confs/bashrc_private.sh... "
cp ~/.bashrc confs/bashrc_private.sh
echo "done"

lc_scripts/lc_install.sh

echo ""
echo "======== Setup Complete ========"

echo "Linux_conf is now set up. If you open a new console, all lc_* commands will be available."
echo "To get started in this console, run"
echo " $ source ~/.bashrc"
echo ""
echo "You can add more configuration files to the tracking"
echo "by calling lc_add_conf, for example:"
echo " $ lc_add_conf '~/.emacs'"
echo ""
echo "Run lc_add_conf -h for more information"


exit $EXIT_SUCCESS
