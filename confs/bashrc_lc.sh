## Base functionalities of linux_conf

### Set default editor if not set before 
if [ ! -n "$EDITOR" ] ; then
    EDITOR="vi"
fi

### Aliases for viewing and editing .bashrc
alias brc=$EDITOR' '$repoDir'/linux_conf/confs/bashrc; cd '$repoDir'/linux_conf/; lc_scripts/lc_install.sh; cd -; source ~/.bashrc'
alias crc='cat ~/.bashrc'
alias src='source ~/.bashrc'

### Linux_conf aliases for running scripts
alias lc_pull='cd '$repoDir'/linux_conf; git add -u; git ci -m "Updated config"; git pull --rebase; if [ $? == "0" ]; then  lc_scripts/lc_install.sh; fi; cd - > /dev/null; source ~/.bashrc'
alias lc_push='cd '$repoDir'/linux_conf; git add -u; git ci -m "Updated config"; git push; cd - > /dev/null'
alias lc_pp='lc_pull && lc_push'
alias lc_install='cd '$repoDir'/linux_conf; lc_scripts/lc_install.sh; cd - > /dev/null; source ~/.bashrc'
alias lc_install_exports='cd '$repoDir'/linux_conf; lc_scripts/lc_install_exports.sh; cd - > /dev/null';

### More linux_conf aliases
alias Dlc='cd '$repoDir'/linux_conf'
alias Dn='cd '$repoDir'/linux_conf/notes'

### Functions making sure lc_scripts are called from linux_conf directory
function lc_add_conf {
    cd $lcDir
    lc_scripts/lc_add_conf.sh  "$@"
    cd - > /dev/null
}

function lc_import {
    cd $lcDir
    lc_scripts/lc_import.sh  "$@"
    cd - > /dev/null
}

function lc_notes {
    cd $lcDir
    lc_scripts/lc_notes.sh "$@"
    cd - > /dev/null
}

function lc_new_package {
    file=$lcDir"/notes/packages.md"
    echo $1 >> $file
    sudo apt-get install $1
}

function lc_add_package {
    file=$lcDir"/notes/packages.md"
    echo $1 >> $file
}

function lc_new_script {
    #Creates a new script using scripts/template.sh and opens in EDITOR together with bash notes
    cp $lcDir/scripts/template.sh $1
    chmod u+x $1
    sed -i "s/new_script.sh/$1/gI" $1
    $EDITOR $1 $lcDir/notes/bash.md
}

function lc_add_alias () {
    echo "moin"
    echo "grep -n "^##linux_conf_mark#1" $targetfile | cut -d ":" -f 1"
    targetFile=$lcDir/confs/bashrc_private.sh
    aliasLineNr=`grep -n "^##linux_conf_mark#1" $targetFile | cut -d ":" -f 1`
    aliasLineNr=$(($aliasLineNr+1))
    insertCmd=$aliasLineNr"i"
    aliasDef="$1=""'""$2""'"
    #Set alias for current console
    alias "$aliasDef"
    echo $aliasDef
    #Insert alias into bashrc
    ed $targetFile <<EOF
$insertCmd
alias $aliasDef
.
w
q
EOF
cd $lcDir; ./lc_scripts/lc_install.sh;  cd - > /dev/null;
source ~/.bashrc
}


function sort_aliases {
    targetFile=$lcDir/confs/bashrc_private.sh
    start=`grep -n "#linux_conf_mark#1" $targetFile | cut -f1 -d:`; realstart=$(($start+1))
    length=`tail -n +$realstart $targetFile | grep -n   '^$' |head -n 1 | cut -f1 -d :`; reallength=$(($length-1))
    end=$(($start+$length))
    head -n $start $targetFile > head.tmp; tail -n +$end $targetFile > footer.tmp; tail -n +$realstart $targetFile | head -n $reallength | sort  > aliases.tmp
    cat head.tmp > $targetFile; cat aliases.tmp >> $targetFile; cat ~/footer.tmp >> $targetFile
    rm head.tmp aliases.tmp footer.tmp
}

# Some working md2Html tool is needed by lc_notes.sh
function md2html {
    if (( $# < 1 )) ; then
	echo "Usage: md2Html input.md [output.html]";
	echo "If second argument is not given, output fiel name will"
	echo "input file name with html extension"
    else
	sourcefile=$1
	if (( $# < 2 )) ; then
	    name=${sourcefile%".md"} 
	    target=$name".html"
	else
	    target=$2
	fi

	pandoc -f markdown_github --include-in-header="$lcDir/notes/css/_github-markdown-css.html" $sourcefile > $target
	echo "Rendered html to $target"
    fi
}



### Source autocomplete scripts
for i in `ls $lcDir/lc_scripts/lc_ac_*sh`; do
    source $i;
done

