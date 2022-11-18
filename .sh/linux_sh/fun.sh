#!/bin/bash
path_check(){
    path_c=`ls $1`

    if [[ $path_c = "" ]]
    then
        return 1
    fi
    return 0
}

install(){
    if [ -f /usr/local/bin/shmake ]
    then 
        rm -f /usr/local/bin/shmake
    fi
    cp ${1} /usr/local/bin
    if [ -d /home/fei-chen/.shmake ] 
    then 
        echo " "
    else 
        mkdir /home/fei-chen/.shmake
    fi
    cp build.sh /home/fei-chen/.shmake
}

run(){
    for file in `ls $1`
    do  
        if [[ -x $1/$file ]] && [[ ${file%.*} = ${file} ]] && [[ ! -d $1/$file ]]
        then
            ./$1/$file
        elif [[ -d $1/$file ]]
        then
            run $1/$file
        fi
    done
}

${1} ${2}
