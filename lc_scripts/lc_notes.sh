#!/bin/bash
# Bash script template, based on http://www.pro-linux.de/artikel/2/111/ein-shellskript-template.html
# bash-resources:
#   http://robertmuth.blogspot.de/2012/08/better-bash-scripting-in-15-minutes.html
# modifications by Ingmar Vierhaus <mail@ingmar-vierhaus.de>
set -o nounset
set -o errexit
# Script: lc_notes.sh
# Glboal variables
SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
EXIT_BUG=10
# Initialize Variables defined by option switches
VERBOSE=n
LIST=n
SHORTLIST=n
CAT=y
EDIT=n
SHOW=n
BUILD=n
OPTFILE=""
# function definitions 
function usage {
    echo "Usage: $SCRIPTNAME [-h] [-v] [-o arg] notename ..." >&2
    echo "Helps you browse, view and edit your linux_conf notes"
    echo "and builds html notes from github markdown files"
    echo "Provides auto-completion of note names"
    echo ""
    echo "Options: "
    echo " -h        show this help"
    echo " -v        verbose mode"
    echo " -l        list notes"
    echo " -k        shortlist notes"
    echo " -c        cat the note (default)"
    echo " -e        edit the note (or create a new one)"
    echo " -s        show the notes html version in a browser"
    echo " -b        build the html files for all markups"


    [[ $# -eq 1 ]] && exit $1 || exit $EXIT_FAILURE
}
# List of Arguments. Option flags followed by a ":" require an option, flags not followed by an ":" are optionless
while getopts 'o:csvhkleb' OPTION ; do
    case $OPTION in
	v) VERBOSE=y
	    ;;
	k) SHORTLIST=y
	    ;;
	l) LIST=y
	    ;;
	c) CAT=y;
	    ;;
	e) CAT=n; EDIT=y
	    ;;
	b) CAT=n; BUILD=y
	    ;;
	s) CAT=n; SHOW=y
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

if [ $LIST = y ] || [ $BUILD = y ] ; then
    if (( $# != 0 )) ; then
	echo "Ignoring arguments when listing." >&2
    fi
else  
    if (( $# > 1 )) ; then
	echo "At most one argument allowed." >&2
	usage $EXIT_ERROR
    fi
fi
# Loop over all arguments
for ARG ; do
    if [[ $VERBOSE = y ]] ; then
	echo -n "Argument: "
	echo $ARG
    fi
done


#Handle no-argument cases first
if [[ $SHORTLIST = y ]] ; then
    cd notes > /dev/null
    notes=`ls *md`
    cd - > /dev/null
    for i in $notes ; do
	base=${i%.md}
	echo $base;
    done
    exit $EXIT_SUCCESS
fi


if [[ $BUILD = y ]] ; then
    echo "Building Markups:"
    echo "---------------"
    type /usr/local/bin/http >/dev/null 2>&1 || { 
	echo >&2 "I require httpie (binary http) but it's not installed.  Aborting."; 
	exit $EXIT_ERROR; 
    }
    cd notes > /dev/null
    notes=`ls *md`
    echo "<h1>Notes - Index </h1>" > index.html
    for i in $notes ; do
	exists=y
	base=${i%.md}
	target=$base".html"
	echo -n "Rendering "$base"... "
	if [ ! -e "$target" ]
	then
	    exists=n
	fi
	cp includes/_head.html $target
	/usr/local/bin/http -p b POST https://api.github.com/markdown text="@"$i >> $target
	cat includes/_bottom.html >> $target
	if [[ $exists = n ]] ; then
	    echo -n "adding html file to git ... "
	    git add $target
	fi
	echo '<a href="'$target'">'$base'</a> <br />' >> index.html
	echo "done"
    done
    exit $EXIT_SUCCESS    
else
    if [[ $# == 0 || $LIST = y ]] ; then
	echo "Listing  Notes:"
	echo "---------------"
	cd notes > /dev/null
	notes=`ls *md`
	cd - > /dev/null
	for i in $notes ; do
	    base=${i%.md}
	    echo $base;
	done
	exit $EXIT_SUCCESS
    fi
fi


target="notes/"$1".md"

if [[ $CAT = y ]] ; then
    cat $target
    exit $EXIT_SUCCESS
fi

if [[ $EDIT = y ]] ; then
    pwd
    echo "editing notes/$1.md"
    if [ ! -e "$target" ]
    then
	exists=n
    else
	exists=y
    fi

    $EDITOR $target

    if [[ $exists = n ]] ; then
	git add $target
    fi
    exit $EXIT_SUCCESS
fi

if [[ $SHOW = y ]] ; then
    if [ -z "$BROWSER" ]; then 
	echo "Variable BROWSER is not set, unable to show"
	exit $EXIT_ERROR
    fi
    pwd
    echo "showing notes/$1.html"
    $BROWSER notes/$1.html &
    exit $EXIT_SUCCESS
fi






