dirs=`find . -maxdepth 1 -type d   ! -path .`

for i in `find . -type d -name ".git"  `; do
    dir=${i%.git}
    cd $dir > /dev/null;
    echo ""
    #Aliased to gitsth/gsth in linux_conf
    echo  "Repository: "$dir; git status | head -n 2
    git status -s
    cd - > /dev/null; 

done
