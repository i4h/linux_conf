#bash-resources:
- http://robertmuth.blogspot.de/2012/08/better-bash-scripting-in-15-minutes.html

# Code Fragments

## Check for success
````
    #!/bin/bash
    set -o errexit ; set -o nounset
````
````    
    bad_command || do_err_handle
    good_command
````

## Test for var value
````
 if [[ $VERBOSE = y ]] ; then
     echo -n "Argument: "
     echo $ARG
 fi

 if [[ $VERBOSE != y ]] ; then
     echo -n "Argument: "
     echo $ARG
 fi
```` 


### More operators
````
-eq: equal to
-gt, -gt, -lt, -le: greater/lesser(then)
-z: string is null
-n: string ist not null
````

## Get result
````
    ls *
    echo $?
````

## Check if file exists
````
if [ -e "$file" ]
then
  echo "Given path $1 exists. "
fi
````

## Disable block
````
if false; then
    echo "bruce lee defeats chuck norris"
fi
````

## Write arrays
````
n='0'
fileName=()
fileType=()
````

### Add one of these blocks for every file problem file and lookback level
````
fileName[$n]='file1'
fileType[$n]='txt'
((n++)) || true #The or true is necessary because ((n++)) returns zero if n=0, which looks like an error
````

## Read arrays
````
for (( i=0; i<$n; i++ )); do
    echo ${fileName[$i]}", type: "${fileType[$i]};
done
````

## Checking if keys exist:
Thanks to doubleDown on http://stackoverflow.com/questions/13219634/easiest-way-to-check-for-an-index-or-a-key-in-an-array
````
function exists(){
  if [ "$2" != in ]; then
    echo "Incorrect usage."
    echo "Correct usage: exists {key} in {array}"
    return
  fi   
  eval '[ ${'$3'[$1]+muahaha} ]'  
}
if ! exists key in array; then echo "No such array element"; else echo "exist" ; fi 
````

## Read csv file
````
#!/bin/bash
INPUT=data.cvs
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read flname dob ssn tel status
do
	echo "Name : $flname"
	echo "DOB : $dob"
	echo "SSN : $ssn"
	echo "Telephone : $tel"
	echo "Status : $status"
done < $INPUT
IFS=$OLDIFS
````

## C-Style loop
````
for ((i = 0 ; i <= 100 ; i++)); do
  echo "Counter: $i"
done
````

## Ask for user input
````
while true; do
    read -p "Do you wish to install this program?" yn
    case $yn in
        [Yy]* ) make install; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
````

## Ignore return code when errexit is set
````
command || true
````

## Or
````
if [ "$SHELL" == "/bin/bash" ] && [ "$USER" == "sim4000" ]; then
   echo "User und Shell sind richtig";
fi
````
 
## And
````
if [ "$SHELL" == "/bin/bash" ] || [ "$USER" == "sim4000" ]; then
   echo "User oder Shell sind richtig";
fi
````

## Remove string form end of other string
````
var=${var%string}              # Remove the string at the end of var
````

## Piping
### Send stderr to stdout
````
2>&1
````

### Send everything to file
````
bin/executable &> logfile.log
````


### Show all functions 
typeset -f 
