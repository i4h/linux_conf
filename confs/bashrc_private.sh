## Temporary functions
function pp {
    gnuplot $1".plt";
    ps2dpf $1".ps";
    okular $1".pdf";
}

## Parameter settings for some tools
export HISTFILE="$HOME/bash_history"
export HISTSIZE=30000
export HISTFILESIZE=30000
shopt -s histappend
### Share history across consoles
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"



### Remove temporary files for all tex files in directory
function clean_latex {
    for i in `ls *.tex`; do 
	base=${i%.tex}
	echo "Removing files for $i"
	for e in log out bbl blg aux synctex.gz upa upb; do
	    file=$base"."$e 
	    if [[ -e "$file" ]] ; then
		echo "Removing  $file"
		rm $file
	    fi
	done
    done

}

function grepx {
	 grep -ri --include="*tex" "$1"
}


function append() {
    if (( $# < 2 )) ; then
	echo 'Usage: append filename "sting to be appended"';
    else
	echo "$2" > $1
    fi
}

function em {
	 emacs $1 &
}



## Unsorted aliases
alias emacsnw='emacs -nw'
alias findyoung='find -mmin -5'
alias ll='ls -lah'
alias tail='tail -n 50'
alias head='head -n 40'
alias du='du -h'
alias bc='bc -l'
alias make='make -j '
alias rename='rename -v'
alias h='history'
alias lss='ls *.sh'
alias lsx='ls *{.txt,.md}'
alias lsxr='find | egrep ".txt|.md"'
alias cpuinfo='cat /proc/cpuinfo'
alias grepi='grep -i'
alias o='popd'
alias p='pushd'
alias dirs='dirs -v'
alias Dm='cd /media'
alias clean_em="rm *~"
alias clean_emrn="find -type f \( -name '*~' -o -name '#*#' \) "
alias clean_emr="echo 'Deleting:'; find -type f \( -name '*~' -o -name '#*#' \) -delete -print; echo 'Done'"
alias rsyncp='rsync -avh --progress'
alias allps2pdf='find . -name \*.ps -exec ps2pdf {} \;'
alias unTarGZ='tar -zxvf'
alias greph='history | grep '
alias grepc='grep -C 5'
alias cut_first='cut -f 1 -d'
alias histnn='history | cut -c 8-'

## Subversion aliases
alias svnign='svn propedit svn:ignore .'
alias svnglign='svn propedit svn:global-ignores .'
alias svnst='svn st --ignore-externals'
alias svnstu='svn st -q'
alias svnstc='svn st | grep "C "'
alias svnl="svn log -l 20 | perl -l40pe 's/^-+/\n/'"
alias svnlh="svn log . -l 20 | perl -l40pe 's/^-+/\n/'"


## Git aliases
alias gitlol='git log --oneline --color=always | head -n 20'
function gitid {
    echo "adding this directory to git, ignoring all files inside"
    echo '*' >> .gitignore
    echo '!.gitignore' >> .gitignore
    git add .gitignore
}

##linux_conf_mark#1  - unsorted aliases
alias test='echo test'

alias mk='./makeIt.sh'
alias mt='make test TEST=simulate SETTINGS=simulate  OPT=dbg LPS=cpx IPOPT=true'
alias gitsth='echo -n "Repository: "; basename `pwd`; git status | head -n 2'
alias gitignore_latex='cat /home/optimi/bzfvierh/repos/linux_conf/exports/git/latex_gitignore >> .gitignore'
alias dirs_here='find . -maxdepth 1 -type d   ! -path .'
alias x='exit'
alias unlock_php='rm ~/workspace_php/.metadata/.lock'
alias unlock_latex='rm ~/workspace_latex/.metadata/.lock'
alias g='git'
alias hy='sudo pm-hibernate'
alias svnl="svn log -l 20 | perl -l40pe 's/^-+/\n/'"
alias google='firefox --search'
alias Dsdr='cd ~/SFB1026/Papers/SDR2015'
alias vpn_hsu="sudo openvpn --config $lcDir/exports/openvpn/hsu-vpn.ovpn"

