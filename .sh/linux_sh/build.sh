set -o errexit
source ~/.shmake/.sh/linux_sh/config.sh
source ~/.shmake/.sh/linux_sh/deps_tools.sh

if test -d ./rec 
then
    echo "检测脚本记录"
else
    mkdir rec && echo "创建脚本记录"
fi 

type pkg-config &>>./rec/build_rec.txt \
    &&  echo "`date` pkg-config found." >> ./rec/build_rec.txt \
    || ( echo "`date` pkg-config not found." >> ./rec/build_rec.txt && install_pkg )

build_file_path=$1
rebuild=$3
allbuild=$5
jobs=$7
build_file=$9

len=0
que=""
pushque(){
    que="$que $1"
    len=$(($len+1))
}

flashque() {
    lastque=$que
    que="" 
    len=0
    for PID in $lastque
    do
        if [[ -d /proc/$PID ]]
        then
        pushque $PID
        fi
    done
}

checkque() { 
    lastque=$que
    for PID in $lastque
    do
        if [[ ! -d /proc/$PID ]]
        then
            flashque
            break
        fi
    done
}


for build in `ls ${build_file_path}/${build_file}`
do
    source $build

    type $compiler &>>./rec/build_rec.txt \
        &&  echo "`date` $compiler found." >> ./rec/build_rec.txt \
        || ( echo "`date` $compiler not found." >> ./rec/build_rec.txt && install_compiler $compiler )    

    type before_build &>./rec/before_build.txt \
        && ( echo "`date` before_build() found." > ./rec/before_build.txt && before_build ) \
        || echo "`date` before_build() not found." > ./rec/before_build.txt 

    i=${#build}
    ix=0
    while(( $i>=0 ))
    do
        s=${build:${i}:1}
        if [[ $s = "/" ]]
        then
            ix=`expr ${i} + 1`
            break
        fi
        let "i--"
    done
    build_time=${build:${ix}}

    all_include=""
    for src in ${includedir[@]}
    do
        all_include="${all_include} -I ${build_file_path}/${src} "
    done

    src_=""
    for s in ${sources[@]}
    do  
        src_="$src_ `ls ${build_file_path}/$s`"
    done

    if [ -f ./rec/${build_time}.txt ]
    then
        echo `stat --format=%y $build` > ./rec/${build_time}com.txt
    else
        echo `stat --format=%y $build` > ./rec/${build_time}com.txt
        echo "11" >> ./rec/${build_time}com.txt
        echo `stat --format=%y $build` > ./rec/${build_time}.txt
    fi

    if [[ -d ./Shfile ]] && [[ $rebuild = "n" ]] && \
        [[ $(cat ./rec/${build_time}com.txt) = $(cat ./rec/${build_time}.txt) ]]
    then 
        rm ./rec/${build_time}.txt
        mv -f ./rec/${build_time}com.txt ./rec/${build_time}.txt
        all_o=""
        cnt=1

        for src in $src_
        do 
            int=${#src}
            idex=0
            while(( $int>=0 ))
            do
                s=${src:${int}:1}
                if [[ $s = "/" ]]
                then
                    idex=`expr ${int} + 1`
                    break
                fi
                let "int--"
            done

            all_o="${all_o} Shfile/.o/${src:${idex}}${idex}.o"

            if [ -f ./Shfile/.d/${src:${idex}}${idex}.d ]
            then
                ptr=1
                for sc in $(cat ./Shfile/.d/${src:${idex}}${idex}.d)
                do
                    if (( $ptr == 1 ))
                    then 
                        let "ptr++"
                        continue
                    else
                        scc=$sc
                    fi
                    if [[ $scc = "\\" ]]
                    then 
                        continue
                    fi
                    echo `stat --format=%y ${scc}` >> ./Shfile/time/${src:${idex}}${idex}com.txt
                done

                if [[ $(cat ./Shfile/time/${src:${idex}}${idex}com.txt) != $(cat ./Shfile/time/${src:${idex}}${idex}.txt) ]]
                then
                    
                    printf "\e[36m[${cnt}]\e[33m${src:${idex}}"
                    ${compiler}  ${src} -c -o Shfile/.o/${src:${idex}}${idex}.o \
                        -MMD -MF Shfile/.d/${src:${idex}}${idex}.d \
                        $all_include || printf "\n\e[0m"
                    echo -e "\e[32m ✔️\e[0m"
                    let "cnt++"
                fi

                rm ./Shfile/time/${src:${idex}}${idex}.txt 
                mv -f ./Shfile/time/${src:${idex}}${idex}com.txt ./Shfile/time/${src:${idex}}${idex}.txt 
        
            else
                printf "\e[36m[${cnt}]\e[33m${src:${idex}}"
                ${compiler}  ${src} -c -o Shfile/.o/${src:${idex}}${idex}.o \
                    -MMD -MF Shfile/.d/${src:${idex}}${idex}.d \
                    $all_include || printf "\n\e[0m"
                echo -e "\e[32m ✔️\e[0m"
                let "cnt++"
                echo `stat --format=%y ${scc}` >> ./Shfile/time/${src:${idex}}${idex}.txt
            fi
            printf "" & #Multiple thread
            PID=$!
            pushque $PID
            while (( $len>=$jobs ))
            do
                checkque
                sleep 0.08
            done
        done
        wait

        ${compiler} ${all_o} -o ${project[0]} \
            `pkg-config --libs --cflags ${deps[*]}` \
            && echo -e "\e[32mBuilding completed\e[0m" || exit 1
    else
        rm ./rec/${build_time}.txt
        mv -f ./rec/${build_time}com.txt ./rec/${build_time}.txt
        if [[ ! -d ./Shfile ]]
        then
            mkdir Shfile && mkdir Shfile/.d && mkdir Shfile/.o \
                && mkdir Shfile/time 
        fi

        cnt=1

        for src in $src_
        do 

            int=${#src}
            idex=0
            while(( $int>=0 ))
            do
                s=${src:${int}:1}
                if [[ $s = "/" ]]
                then
                    idex=`expr ${int} + 1`
                    break
                fi
                let "int--"
            done

            printf "\e[36m[${cnt}]\e[33m${src:${idex}}"
            ${compiler}  ${src} -c -o Shfile/.o/${src:${idex}}${idex}.o \
                -MMD -MF Shfile/.d/${src:${idex}}${idex}.d \
                $all_include || printf "\n\e[0m"
            echo -e "\e[32m ✔️\e[0m"
            let "cnt++"

            all_o="${all_o} Shfile/.o/${src:${idex}}${idex}.o"

            ptr=1
            for sc in $(cat ./Shfile/.d/${src:${idex}}${idex}.d)
            do
                if (( $ptr == 1 ))
                then 
                    let "ptr++"
                    continue
                else
                    scc=$sc
                fi
                if [[ $scc = "\\" ]]
                then 
                    continue
                fi
                echo `stat --format=%y ${scc}` >> ./Shfile/time/${src:${idex}}${idex}.txt
            done
            printf "" & #Multiple thread
            PID=$!
            pushque $PID
            while (( $len>=$jobs ))
            do
                checkque
                sleep 0.08
            done
        done
        wait

        ${compiler} ${all_o} -o ${project[0]} \
            `pkg-config --libs --cflags ${deps[*]}` \
            && echo -e "\e[32mBuilding completed\e[0m" || exit 1
    fi


    type after_build &> ./rec/after_build.txt \
        && ( echo "`date` after_build() found." > ./rec/after_build.txt && after_build ) \
        || echo "`date` after_build() not found." > ./rec/after_build.txt
    echo -e "\e[35mRunning time estimate: $SECONDS seconds\e[0m"
done
exit