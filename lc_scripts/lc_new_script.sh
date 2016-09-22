#!/bin/bash
# Bash script template, based on http://www.pro-linux.de/artikel/2/111/ein-shellskript-template.html
# bash-resources:
#   http://robertmuth.blogspot.de/2012/08/better-bash-scripting-in-15-minutes.html
# modifications by Ingmar Vierhaus <mail@ingmar-vierhaus.de>
set -o nounset
set -o errexit
# Script: lc_new_script.sh
# Glboal variables
SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
EXIT_BUG=10
# Initialize Variables defined by option switches
VERBOSE=n
BASH=y
PYTHON=n
OPTFILE=""
# function definitions 
function usage {
    echo "Usage: $SCRIPTNAME [-h] [-v] [-o arg] file ..." >&2
    echo "Creates data and plotfiles for every lookup defined in lookup.dat"
    echo "found in working directory. Uses plot executable from working directory"
    echo ""
    echo "Options: "
    echo " -h        show this help"
    echo " -v        verbose mode"
    [[ $# -eq 1 ]] && exit $1 || exit $EXIT_FAILURE
}
# List of Arguments. Option flags followed by a ":" require an option, flags not followed by an ":" are optionless
while getopts ':o:vhbp' OPTION ; do
    case $OPTION in
	v) VERBOSE=y
	    ;;
	b) BASH=y
	    ;;
	p) BASH=n; PYTHON=y
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
if (( $# != 1 )) ; then
    echo "One argument required." >&2
    usage $EXIT_ERROR
fi
# Loop over all arguments
for ARG ; do
    if [[ $VERBOSE = y ]] ; then
	echo -n "Argument: "
	echo $ARG
    fi
done

script_path=$1
script_name=`basename $script_path`

if [[ $BASH = y ]] ; then
    template='scripts/template.sh'
    note='notes/bash.md'
fi
if [[ $PYTHON = y ]] ; then
    echo "Python parameters not set yet"
    exit $EXIT_ERROR
fi

cp $template $script_path
chmod u+x $script_path
sed -i "s/new_script/$script_name/gI" $1
if [[ -e $note ]] ; then 
    $EDITOR $script_path $note
else
    $EDITOR $script_path
fi

exit $EXIT_SUCCESS





