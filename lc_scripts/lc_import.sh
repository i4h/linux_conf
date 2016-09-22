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
    echo "Usage: $SCRIPTNAME [-h] [-v] [-o arg] file ..." >&2
    echo "Imports existing configuration files into repository from traget paths"
    echo "and lets you merge with files currently in directory using git difftool"
    echo "Should be called via lc_import alias or from linux_conf directory"
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
# Test for valid number of arguments
if (( $# != 0 )) ; then
    echo "No arguments expected." >&2
    usage $EXIT_ERROR
fi
# Loop over all arguments
for ARG ; do
    if [[ $VERBOSE = y ]] ; then
	echo -n "Argument: "
	echo $ARG
    fi
done

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

#Make sure linux_conf repository is clean
if [[ `test -n "$(git status --porcelain)"` = 0 ]]; then
    echo "ERROR: The linux_conf repository is not clean. "  >&2
    echo "Please commit your changes before running lc_import." >&2
    exit $EXIT_ERROR
fi


source confs.conf

diffs=0

for i in $(eval echo {0..$n}); do
    doingfine=0;

    source='confs/'${fileName[$i]}
    sourceName=${fileName[$i]}
    target=${fileDestination[$i]}
    echo -n 'Importing '$target '... '

    #Expand ~
    eval target=$target


    #Check for diffs
    difflines=`diff $source $target | wc -l`
    
    if [[ $difflines = 0 ]] ; then
	echo "no diff exists"
    else
	diffs=$(($diffs+1))
	cp $target $source
	if [ $? -eq 0 ]; then
	    echo 'import successful '
	    echo 'Running difftool. Merge your local configuration with the'
	    echo 'one in the repository now'
	    git difftool HEAD^ $source
	else
	    echo 'ERROR importing configuration file'
	fi
    fi

done

if [[ $diffs = 0 ]] ; then
    echo "Done. No diffs found."
else
    echo "Done. If you are satisfied with your merge, call lc_push to commit and push your changes."
fi

exit $EXIT_SUCCESS
