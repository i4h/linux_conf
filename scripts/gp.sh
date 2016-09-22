#!/bin/bash
# Bash script template, based on http://www.pro-linux.de/artikel/2/111/ein-shellskript-template.html
# modifications by Ingmar Vierhaus <mail@ingmar-vierhaus.de>
set -o nounset
set -o errexit
# Script: new_script
# Global variables
SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
EXIT_BUG=10
# Initialize Variables defined by option switches
VERBOSE=n
OPTFILE=""
ACMDS=""
BCMDS=""

WITH=""
TEMPFILE=".gp_plotfile.tmp"
# function definitions 
function usage {
 echo "Usage: $SCRIPTNAME [-h] [-v] [-w linetype] datafile x1 y1 x2 y2 ..." >&2
 echo "Plots a datafile with gnuplot"
 echo ""
 echo "Options: "
 echo " -h        show this help"
 echo " -v        verbose mode"
 echo " -w        specify the WITH argument used for all plots (i.e. lines, points, linespoints)"
 echo ' -b "cmd1, cmd" gnuplot commands that will be executed before the plot commands '
 echo ' -a "cmd1, cmd" gnuplot commands that will be executed after the plot commands '


 [[ $# -eq 1 ]] && exit $1 || exit $EXIT_FAILURE
}
# List of Arguments. Option flags followed by a ":" require an option, flags not followed by an ":" are optionless
while getopts ':o:w:a:b:vh' OPTION ; do
 case $OPTION in
 v) VERBOSE=y
 ;;
 o) OPTFILE="$OPTARG"
 ;;
 a) ACMDS="$OPTARG"
 ;;
 b) BCMDS="$OPTARG"
 ;;
 w) WITH="$OPTARG"
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
if (( $# < 3 )) ; then
 echo "At least three arguments required." >&2
 usage $EXIT_ERROR
fi
if (( $# < 3 )) ; then
 echo "At least three arguments required." >&2
 usage $EXIT_ERROR
fi

if [ $(($#%2)) -eq 0 ] ; then
 echo "Uneven number of arguments required." >&2
 usage $EXIT_ERROR
fi

# Loop over all arguments
for ARG ; do
 if [[ $VERBOSE = y ]] ; then
     echo -n "Argument: "
     echo $ARG
 fi
done

datafile=$1

# Make x/y pairs
x=()
y=()

argcounter=0;
paircounter=1;
for ARG ; do
    if [ $argcounter -gt 0 ] ; then
	echo argcounter is $argcounter
	if [ $((argcounter%2)) -eq 0 ] ; then
	    y[$paircounter]=$ARG
	    ((paircounter++)) || true
	else
	    x[$paircounter]=$ARG
	fi
    fi
    ((argcounter++)) || true
done

cat /dev/null > $TEMPFILE


# Before commands
if [[ $BCMDS != "" ]] ; then
    OLDIFS=$IFS
    IFS=$','       # make newlines the only separator
    for i in $BCMDS; do
      echo $i
      echo $i >> $TEMPFILE
    done
    IFS=$OLDIFS
fi


# Make plot command
s=""
for (( i=1; i<$paircounter; i++ )); do
    echo "(" ${x[$i]}", "${y[$i]} " )";
    if [ $i = 1 ] ; then
	s=$s'plot '
    else
	s=$s', '
    fi
    s=$s'"'$datafile'" using '
    s=$s${x[$i]}":"${y[$i]}
    if [[ $WITH != "" ]] ; then
	s=$s"with $WITH"
    fi


    
done

echo $s >> $TEMPFILE

# After commands

if [[ $ACMDS != "" ]] ; then
    OLDIFS=$IFS
    IFS=$','       # make newlines the only separator
    for i in $ACMDS; do
      echo $i
      echo $i >> $TEMPFILE
    done
    IFS=$OLDIFS
fi


echo "pause -1 \"hit return to exit\"" >> $TEMPFILE


if [[ $VERBOSE = y ]] ; then
    echo  "Cat of Created plotfile: "
    cat $TEMPFILE
fi

gnuplot $TEMPFILE
#echo "$s" | gnuplot -persists


rm $TEMPFILE

exit $EXIT_SUCCESS
