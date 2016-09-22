#!/bin/bash
# Skript: my_notify.sh
# Author: Ingmar vierhaus <vierhaus@zib.de>
# Global variables
SCRIPTNAME=$(basename $0 .sh)
TEMPFILE=".msg.temp"
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
EXIT_BUG=10
# Variablen für Optionsschalter hier mit Default-Werten vorbelegen
VERBOSE=n
PID=""
MSGFILE=""
MESSAGE=""
NOTIFY_SUBJECT="Notification from my_notify.sh"
INTERVAL="30"
NOTIFY_RECIPIENT="vierhaus@zib.de"
# Source config file if exists (can overwrite global variables)
if [ -f ~/.myrc ]; then
        . ~/.myrc
fi

# Funktionen
function usage {
 echo "Usage: $SCRIPTNAME [OPTIONS] message" >&2
 echo "Simply sends the specified notification if no pid is given." >&2
 echo "If -p is set, watches the pid and sends specified notification when pid vanishes from ps." >&2;
 echo "This can be used in two ways: " >&2
 echo "1) Chain with the command to be notified when it finishes: " >&2
 echo  "   (cmd; my_notify.sh \"Command finished\" ) & " >&2
 echo  "   (cmd && my_notify.sh \"Command finished successfully\" ) & " >&2
 echo  "   ((cmd && my_notify.sh \"Command finished successfully\") || my_notify.sh \"Command failed\" ) & " >&2
 echo "" >&2
 echo "2) Run the process and then give the pid to my_notify: " >&2
 echo  "  $> cmd &" >&2
  echo "  $> my_notify.sh -p \$! \"Command finished\" & " >&2


 echo "" >&2
 echo "OPTIONS:" >&2
 echo "  -f             Path of a file used as message" >&2
 echo "  -s             Message Subject" >&2
 echo "  -r             Recepient, default: $NOTIFY_RECIPIENT" >&2
 echo "                 The default recepient can be hardcoded or set by defining "
 echo "                 NOTIFY_RECIPIENT in ~/.myrc"
 echo "  -p             PID to monitor" >&2
 echo "  -n             Interval between  pid checks in seconds, default: $INTERVAL" >&2
 [[ $# -eq 1 ]] && exit $1 || exit $EXIT_FAILURE
}
# Die Option -h für Hilfe sollte immer vorhanden sein, die Optionen
# -v und -o sind als Beispiele gedacht. -o hat ein Optionsargument;
# man beachte das auf "o" folgende ":".
while getopts ':s:n:f:r:p:vh' OPTION ; do
 case $OPTION in
 v) VERBOSE=y
 ;;
 h) usage $EXIT_SUCCESS
 ;;
 f) MSGFILE="$OPTARG"
 ;;
 s) NOTIFY_SUBJECT="$OPTARG"
 ;;
 r) NOTIFY_RECIPIENT="$OPTARG"
 ;;
 p) PID="$OPTARG"
 echo "Notification for disapperance of process:" > $TEMPFILE 
 if ! ps -p $PID >> $TEMPFILE
 then
     echo "PID does not exist \"-$OPTARG\"." >&2
     exit $EXIT_ERROR
 fi
 echo "" >> $TEMPFILE 
 echo "Message:" >> $TEMPFILE 
 ;;
 n) INTERVAL="$OPTARG"
 ;;
 \?) echo "Unrecognized Option \"-$OPTARG\"." >&2
 usage $EXIT_ERROR
 ;;
 :) echo "Option \"-$OPTARG\" requires an argument." >&2
 usage $EXIT_ERROR
 ;;
 *) echo "Take cover! Something impossible happend."
>&2
 usage $EXIT_BUG
 ;;
 esac
done
# Skip used arguments
shift $(( OPTIND - 1 ))

#Check number of arguments
if (( $# > 1 )) ; then
 echo "Too many arguments, don't know what to do." >&2
 usage $EXIT_ERROR
fi

if [ $# -eq 0 ] ; then
 echo "Exactly one input argument needed. Please specify the message." >&2
 usage $EXIT_ERROR
fi


# Set Message if given
if (( $# > 0 )) ; then
    MESSAGE=$1
    if [[ $VERBOSE = y ]] ; then
	echo -n "Argument 1 (Message):  "$MESSAGE
	echo ""
    fi
fi

# Wait for process to disappear
if [[ $PID != "" ]] ; then
     while ps -p $PID > /dev/null
     do
	 sleep $INTERVAL
     done
fi

#Send notification

if [[ $MSGFILE = "" ]] ; then
    echo "$MESSAGE" >> $TEMPFILE
else
    cat $MSGFILE >> $TEMPFILE
fi

if [[ $VERBOSE = y ]] ; then
    echo  "Sending Message: to "$NOTIFY_RECIPIENT
    echo  "Subject: "$NOTIFY_SUBJECT
    echo  "Body: ";
    cat $TEMPFILE;
fi

mail -s "$NOTIFY_SUBJECT" $NOTIFY_RECIPIENT < $TEMPFILE

rm $TEMPFILE

exit $EXIT_SUCCESS
