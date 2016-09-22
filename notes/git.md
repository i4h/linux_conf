# Git 

## Pretty log output
    git log --graph branch1 branch2  (aliased to lg/lgo for oneline)
	
## Checkout and track remote branch
    git branch test origin/test
or ''do what i mean''
    git checkout test

## Revert fast forward or merge
Show what happend in working copy:
    git reflog show master
Revert	
    git reset --keep master@{1}

## Diverging branches
Show commis not in origin:
    git rev-list origin..HEAD
Show shared commits between head and branch
    git merge-base HEAD branch

## Tagging
Annotated Tag: 
    git tag -a tagname -m 'msg'
List Tags: 
    git tag -l
Show Tag
     git show tagname


# Redate commits

- Define first and last commit to redate
- Find earliest allowed date
- Find timestamp of earliest allowed date:
````
ts=`date --date="2016-04-23 19:05:36" +%s`
newdate=`date --date=@$ts`; echo $newdate
````

- git rebase -i [hash_first_commit]
- Set commits to redate to edit
- For each commit:

````
newdate=`date --date=@$ts`; echo $newdate
GIT_COMMITER_DATE=$newdate
git commit --amend --date="$newdate"
incr=`awk 'BEGIN{srand(); printf("%i\n",120 + rand() * 360);}'`
ts=$(($ts + $incr))
git rebase --continue
````

## Shared repositories

http://serverfault.com/questions/26954/how-do-i-share-a-git-repository-with-multiple-users-on-a-machine

Directory gitrepo, shared group gitgroup

Init bare repo gitrepo

````
git init --bare --shared=group
````

and then

````
chgrp -R gitgroup gitrepo
chmod -R g+swX gitrepo
````

# Pushing to a Remote Branch with a Different Name
https://penandpants.com/2013/02/07/git-pushing-to-a-remote-branch-with-a-different-name/
````
git push origin local-name:remote-name
````
## Set upstream for current branch
git branch -u orign/master


## Bisect using a script
````
git bisect start HEAD $lastgoodhash
git run ../bisect_script.sh
````

### Bisect script:

````
#!/bin/bash
# Save number of run in file
basepath="/home/me/path" #should be outside of repo 
bisectfile=$basepath"/bisectvars.sh"
nrun=0
source $bisectfile
((nrun++)) || true
echo "nrun="$nrun > $bisectfile
logfile=$basepath"/test_"$nrun".log"

echo "Running script $nrun"

# something happend and we dont know if revision is good
if [ $? != "0" ] ; then
    echo "Unable to clean scip" && exit 130
fi

# if revision is bad
if [ $retcode != "0" ] ; then
    exit 1
fi
# if revision is good
if [ $optimal = "1" ] ; then
    exit 0
fi
````

# Show commits in one branch but not in the other
git log oldbranch ^newbranch --no-merges
