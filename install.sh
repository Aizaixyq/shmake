#!/bin/sh

if [ -d ~/.shmake ] 
then 
    printf ""
else 
    mkdir ~/.shmake
fi
cp  -r ./.sh ~/.shmake

sudo cp -f build/shmake /usr/local/bin && echo "successful"