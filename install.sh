#!/bin/sh

g++ ./src/*.cpp -o shmake `pkg-config --libs --cflags fmt`

if [ -d ~/.shmake ] 
then 
    printf ""
else 
    mkdir ~/.shmake
fi
cp  -r ./.sh ~/.shmake

sudo cp -f ./shmake /usr/local/bin && echo "successful"