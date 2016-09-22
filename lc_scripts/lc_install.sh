#!/bin/bash

echo "Installing configuration files"

source confs.conf

stamp=$(date +%Y-%m-%d_%H-%M_%s)
backupDir='oldconfs/'$stamp;
mkdir $backupDir
echo $backupDir >> .git/info/exclude
echo 'Created directory for Backups: '$backupDir

for i in $(eval echo {0..$n}); do
    doingfine=0;

    source='confs/'${fileName[$i]}
    sourceName=${fileName[$i]}
    absSource=`readlink -f $source`


    target=${fileDestination[$i]}
    echo -n 'Installing '$target '... '

    #Expand ~
    eval target=$target

    # If source file does not exist do nothing
    if [ ! -f $source ]; then
	    echo " ";
	    echo "Problem with confs.conf: source file $source does not exist, aborting ERROR"
	    doingfine=1
    else

	# If target is symlink just create it again
	if [ -h $target ]; then
	    rm $target
	    ln -s $absSource $target
	    if [ $? -eq 0 ]; then
		echo "Linking successful SUCCESS"
	    else
		echo " ";
		echo 'error during linking, aborting ERROR'
		doingfine=1
	    fi
	else
	    #Make backup if target is a file
	    if [ -f $target ]; then
		mv $target $backupDir'/'$sourceName
		if [ $? -eq 0 ]; then
		    echo -n 'Backup successful ... '
		else
		    echo " ";
		    echo 'error during backup, aborting ERROR'
		    doingfine=1
		fi
	    else
		echo -n "target not found - no backup ..."
	    fi

	    #Check if target directory exists
	    targetdir=`dirname $target`

	    if [ -d $targetdir ]; then
		#Install configuration if backup was successful
		if [ $doingfine -eq 0 ]; then
		    ln -s $absSource $target
		    #cp $source $target
		    if [ $? -eq 0 ]; then
			#echo 'Installation successful SUCCESS'
			echo 'Linking successful SUCCESS'
		    else
			echo 'error installing ERROR'
		    fi
		fi
	    else
		echo 'target dir not found SKIPPING'
	    fi
	fi
    fi

done
