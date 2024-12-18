# Bash version of script to enter data into sqlite database from command line

#!/bin/bash

db="my_database.db"
table="my_table"

echo "Welcome"
echo "Please Enter User Info"

while [ 1 ]
do
echo -n "First Name: "
read fname
if [ "$fname" = "" ]
  then
  echo "Value needed"
  exit 1
  fi

echo -n "Surname: "
read sname
if [ "$sname" = "" ]
  then
  echo "Value needed"
  exit 1
  fi

sqlite "$db" "INSERT INTO $table VALUES ("$fname", "$sname")" || echo "ERROR"

echo "Would you like to enter another user? (y/n): "
read answer

if [ "$answer" = "n" ]
  then
  echo "Bye Bye"
  exit 1
else
  clear
fi
done
