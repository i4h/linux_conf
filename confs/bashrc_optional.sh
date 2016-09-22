# Source git completion
source ~/.git-completion.bash
__git_complete g __git_main


## Use $EDITOR for other stuff
export SVN_EDITOR=$EDITOR
export VISUAL=$EDITOR

## Use Emacs to display man pages 
if [ $EDITOR = "emacs" ] ; then 
    function man () {
	emacs -nw -eval "(woman \"$1\")"
    }
fi

## Make an ~/.emacs_saves dir if necessary
if [ ! -e ~/.emacs_backups ] ; then
    mkdir ~/.emacs_backups
fi


## Helper functions 
function tarGZdir {
    tar -zcvf $1'.tar.gz' $1
}

function stripspace {
    git stripspace < $1 > ~/temp/stripspace;
    cp ~/temp/stripspace $1
}



function add_group {
    if (( $# < 2 )) ; then
	echo "Usage: add_group user group";
    else
	sudo usermod -a -G $2 $1
    fi
}



function add_to_path_local() {
    PATH=$PATH":""$1"
    export PATH
}

