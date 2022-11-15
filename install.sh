#!/bin/sh

g++ ./src/*.cpp -o shmake

if [ -d ~/.shmake ] 
then 
    printf ""
else 
    mkdir ~/.shmake
fi
cp  -r ./.sh ~/.shmake

sudo cp -f ./shmake /usr/local/bin && echo "successful"