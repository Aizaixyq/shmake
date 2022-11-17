system_idebtify(){
    a=`uname  -a`

    b="Arch"
    c="Centos"
    d="Ubuntu"
    e="Debian"
    ret=0

    if [[ $a =~ $b ]];then
        ret=1
    elif [[ $a =~ $c ]];then
        ret=2
    elif [[ $a =~ $d ]] || [[ $a =~ $e ]]
    then
        ret=3
    else
        echo $a
        echo "未识别的系统，请移至github提交issue, 或自己安装编译器"
        echo "For unrecognized systems, please go to github to submit an issue, or install the complier yourself"
        echo "https://github.com/Aizaixyq/shmake"
    fi
    return $ret
}


install_compiler(){
    _compiler=$1
    echo "Try to install the compiler: $1"
    system_idebtify
    p=$?
    sudo apt update
    if (( $p==1 ));then
        pacman -S $_compiler || echo "install failure"
    elif (( $p==2 ));then
        yum -y install $_compiler || echo "install failure"
    elif (( $p==3 ));then 
        sudo apt install gcc -y || echo "install failure"
    fi
    type $_compiler && echo "install successfully"
}

install_pkg(){
    pkg="pkg-config"
    echo "Try to install the $pkg"
    system_idebtify
    p=$?
    sudo apt update
    if (( $p==1 ));then
        pacman -S $pkg || echo "install failure"
    elif (( $p==2 ));then
        yum -y install $pkg || echo "install failure"
    elif (( $p==3 ));then 
        sudo apt install $pkg -y || echo "install failure"
    fi
    type $pkg && echo "install successfully"
}