#!/bin/bash
# Script: count_files2.sh
# Author: Ingmar Vierhaus <vierhaus@zib.de>
# Global variables
echo $0;
SCRIPTNAME=$(basename $0 .sh)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
EXIT_BUG=10
# Initialize Variables defined by option switches
VERBOSE=n
DEPTH=1
MANY=0
MIN_FILES=0
STARTDIR="."
# function definitions 
function usage {
 echo "Usage: $SCRIPTNAME [Options] [path].." >&2
 echo "Counts files in the given path recursively and displays results"
 echo "in a tree-like structure" 
 echo "Counts files with the trusted \"find | wc -l\""
 echo "If no path is given, starts at the current directory"
 echo ""
 echo "Options: "
 echo " -h             show this help"
 echo " -v             verbose mode"
 echo " -d depth       depth to stop recursion (default: 1)"
 echo " -m nfiles      Directories with more then nfiles files will be marked in the output"
 echo " -i nfiles      Ignore directories with less then nfiles files"
 echo " -a             List hidden directories as well"

 [[ $# -eq 1 ]] && exit $1 || exit $EXIT_FAILURE
}

function countFiles {

# echo "dirname: $1"
# echo "depth: $2"
# local REAL_DIRNAME=$(basename `realpath $1`)
 REAL_DIRNAME=$1;
 local DEPTH_LEFT=$((DEPTH-$2))
 ls $1/*/ >/dev/null 2>&1 ; 
 if [ $? != 0 ]; then 
     local N_DIRS=0
 else
     local N_DIRS=$(find "$1"/* -type d -print | wc -l)
 fi
 local NEXT_DEPTH=$(($2-1))
 local PADDING=$((3*DEPTH_LEFT))
# printf  "%*s | dirname :$1, depth: $2\n" "$PADDING"
# printf  "%*s |  \n" "$DEPTH_LEFT"

 local N_FILES=$(find "$1" -type f -print | wc -l)

 if [ $N_FILES -ge $MIN_FILES ] ; then

     if [[ $MANY != 0 ]] && [[ $N_FILES -gt $MANY ]] ; then 
	 printf  "%*s |- $REAL_DIRNAME: total $N_FILES files, $N_DIRS directories - <<<< THAT IS A LOT!!!!! < ---------------\n" "$PADDING"
     else
	 printf  "%*s |- $REAL_DIRNAME: total $N_FILES files, $N_DIRS directories\n" "$PADDING"
     fi



     if [ $2 != 0 ] ; then
	 
	 local dir
#     printf  "%*s |find  $1/* -maxdepth 0 -type d\n" "$PADDING"
	 ls $DIR/*/ >/dev/null 2>&1 ; 
	 if [ $N_DIRS != 0 ]; then 
	     local CMD=
	     SAVEIFS=$IFS
	     IFS=$(echo -en "\n\b")
	     for  dir in $(find $1/* -maxdepth 0 -type d )
	     do 
		 if [ $dir != "." ] ; then
	     #printf  "%*s | found dir is $dir\n" "$PADDING"


	     #NEXT_DIR=$1"/"$dir
		     countFiles "$dir" $NEXT_DEPTH
		 fi
	     done  
	     IFS=$SAVEIFS
	 fi
     fi
 fi


} 
# List of Arguments. Option arguments after the first ':', optionless
# arguments after the second ':'
while getopts ':d:m:i:vha' OPTION ; do
 case $OPTION in
 v) VERBOSE=y
 ;;
 d) DEPTH="$OPTARG"
 ;;
 m) MANY="$OPTARG"
 ;;
 i) MIN_FILES="$OPTARG"
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
if (( $# > 1 )) ; then
 echo "Too many arguments, give one or no arguments." >&2
 usage $EXIT_ERROR
fi

if [ $# -eq 1 ] ; then
    STARTDIR="$1"
fi
# Loop over all arguments

for ARG ; do
 if [[ $VERBOSE = y ]] ; then
 echo -n "Argument: "
 fi
 echo $ARG
done

shopt -s dotglob

countFiles "$STARTDIR" $DEPTH "|"



exit $EXIT_SUCCESS
