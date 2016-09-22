#!/bin/bash
# Bash script template, based on http://www.pro-linux.de/artikel/2/111/ein-shellskript-template.html
# bash-resources:
#   http://robertmuth.blogspot.de/2012/08/better-bash-scripting-in-15-minutes.html
# modifications by Ingmar Vierhaus <mail@ingmar-vierhaus.de>
set -o nounset
set -o errexit
# Script: lc_import
# Glboal variables
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
    echo "Usage: $SCRIPTNAME [-h] [-v] [-o arg] config_file [target_name] ..." >&2
    echo "Adds a configuration file to versioning. This means"
    echo "The file is added to the end of the linux_conf/confs.conf file"
    echo "The local version of the file is copied into the linux_confs/confs directory"
    echo "The copy is added to git tracking"
    echo "The original file is replaced by a symlink to linux_confs/confs"
    echo "You can reference your home directory by using ~ and putting the first argument in '' "
    echo ""
    echo "Options: "
    echo " -h        show this help"
    echo " -v        verbose mode"
    echo ""
    echo "Example calls"
    echo "$ lc_add_conf '~/.bashrc'"
    echo "Will start versioning .bashrc under linux_conf/confs/.bashrc"
    echo "$ lc_add_conf '~/.bashrc' bash"
    echo "Will start versioning .bashrc under linux_conf/confs/bash"

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
# Test for valid number of arguments
if (( $# < 1 )) ; then
    echo "At least one argument expected." >&2
    usage $EXIT_ERROR
fi
# Loop over all arguments
for ARG ; do
    if [[ $VERBOSE = y ]] ; then
	echo -n "Argument: "
	echo $ARG
    fi
done

source=$1

#Check if this is a get repo
if [ ! -d .git ]; then
    echo "ERROR: Working directory is not a git repository"  >&2
    echo "- Did you use lc_import alias to run this script?"  >&2
    echo "- Is repoDir variable set in bashrc?"  >&2
    exit $EXIT_ERROR
fi;

#Verify confs.conf exists
if [ ! -f confs.conf ]; then
    echo "ERROR: Confs.conf not found in working directory"  >&2
    echo "- Did you use lc_import alias to run this script?"  >&2
    echo " -Is repoDir variable set in bashrc?"  >&2
    exit $EXIT_ERROR
fi;

#Verify source exists by evaluating ~
eval realsource=$source
if [ ! -f $realsource ]; then
    echo "ERROR: Source configuration file not found"  >&2
    exit $EXIT_ERROR
fi;

#Get target name
if [[ $# = 2 ]] ; then
    target=$2
else
    target=`basename $source`
    fulltarget="confs/"$target
fi

#Verify target does not exist
if [ -f $fulltarget ]; then
    echo "ERROR: Target configuration file linux_conf/$target already exists"  >&2
    echo "Use lc_import to merge configuration files on this system with the ones in linux_conf"  >&2
    exit $EXIT_ERROR
fi;

conf="confs.conf"
#Append confs.conf
echo '' >> $conf
echo 'n=$(($n+1))' >> $conf
echo 'fileName[$n]='"'"$target"'" >> $conf
echo 'fileDestination[$n]="'$source'"'  >> $conf


cp $realsource $fulltarget

git add $fulltarget
git add confs.conf


echo "Done. Call lc_push to commit and push your changes."

exit $EXIT_SUCCESS
