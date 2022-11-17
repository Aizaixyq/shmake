source ~/.shmake/.sh/linux_sh/config.sh
source ~/.shmake/.sh/linux_sh/deps_tools.sh

if test -d ./rec 
then
    echo "Reloading..."
else
    mkdir rec && echo "Loading..."
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
    set -o errexit
    type $compiler &>>./rec/build_rec.txt \
        &&  echo "`date` $compiler found." >> ./rec/build_rec.txt \
        || ( echo "`date` $compiler not found." >> ./rec/build_rec.txt && install_compiler $compiler )    

    type before_build &>./rec/before_build.txt \
        && ( echo "`date` before_build() found." > ./rec/before_build.txt && before_build ) \
        || echo "`date` before_build() not found." > ./rec/before_build.txt 

    pkg_tool=""
    if [[ ${deps} = "" ]]
    then
        pkg_tool=" "
    else
        pkg_tool="`pkg-config --libs --cflags ${deps[*]}`"
    fi

    all_include=""
    for src in ${includedir[@]}
    do
        all_include="${all_include} -I ${build_file_path}/${src} "
    done

    cnt=1

    pch=""
    if [[ ${pch_header} = "" ]]
    then
        pch=" "
    else
        if [[ ! -d ./pch ]];then
            mkdir pch
        fi
        cp ${build_file_path}/${pch_header} pch/
        if [[ ${pch_header} =~ ".hpp" ]];then
            name_pch=`ls pch/*.hpp`
        else
            name_pch=`ls pch/*.h`
        fi
            
        printf "\e[36m[${cnt}]\e[33m${pch_header##*/}"
        if [[ ${compiler} = "gcc" ]] || [[ ${compiler} = "g++" ]]
        then
            ${compiler} -o ${name_pch}.gch -c $name_pch ${all_include}
            cp pch/*.gch ${build_file_path}/${pch_header%/*}
            pch_=" -include ${build_file_path}/${pch_header} "
        elif [[ ${compiler} = "clang" ]] || [[ ${compiler} = "clang++" ]]
        then
            ${compiler} -o ${name_pch}.pch -c $name_pch ${all_include}
            pch_=" -include-pch ${name_pch}.pch "
        fi
        echo -e "\e[32m ✔️\e[0m"
        let "cnt++"
    fi

    build_time=${build##*/}


    src_=""
    for s in ${sources[@]}
    do  
        src_="$src_ `ls ${build_file_path}/$s`"
    done

    if [[ ! -d ./${mode} ]];then
        mkdir ./$mode
    fi

    if [ -f ./rec/${build_time}.txt ]
    then
        echo `stat --format=%y $build` > ./rec/${build_time}com.txt
    else
        echo `stat --format=%y $build` > ./rec/${build_time}com.txt
        echo "11" >> ./rec/${build_time}com.txt
        echo `stat --format=%y $build` > ./rec/${build_time}.txt
    fi

    all_o=""
    if [[ -d ./Shfile ]] && [[ $rebuild = "n" ]] && \
        [[ $(cat ./rec/${build_time}com.txt) = $(cat ./rec/${build_time}.txt) ]]
    then 

        for src in $src_
        do 
            
            name=${src##*/}

            all_o="${all_o} Shfile/.o/${name}.o"

            if [ -f ./Shfile/.d/${name}.d ]
            then
                ptr=1
                for sc in $(cat ./Shfile/.d/${name}.d)
                do
                    if (( $ptr == 1 )) || [[ $sc = "\\" ]] || [[ ${sc#${build_file_path}} = $sc ]]
                    then 
                        let "ptr++"
                        continue
                    fi  
                    echo `stat --format=%y ${sc}` >> ./Shfile/time/${name}com.txt
                done

                if [[ $(cat ./Shfile/time/${name}com.txt) != $(cat ./Shfile/time/${name}.txt) ]]
                then
                    
                    printf "\e[36m[${cnt}]\e[33m${src##*/}"
                    ${compiler}  ${src} -c -o Shfile/.o/${name}.o \
                        -MMD -MF Shfile/.d/${name}.d \
                        $all_include ${pch_} ${cflags[*]} || printf "\n\e[0m"
                    echo -e "\e[32m ✔️\e[0m"
                    let "cnt++"
                fi

                rm ./Shfile/time/${name}.txt 
                mv -f ./Shfile/time/${name}com.txt ./Shfile/time/${name}.txt 
        
            else
                printf "\e[36m[${cnt}]\e[33m${src##*/}"
                ${compiler}  ${src} -c -o Shfile/.o/${name}.o \
                    -MMD -MF Shfile/.d/${name}.d \
                    $all_include ${pch_} ${cflags[*]} || printf "\n\e[0m"
                echo -e "\e[32m ✔️\e[0m"
                let "cnt++"
                echo `stat --format=%y ${scc}` >> ./Shfile/time/${name}.txt
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

    else
        
        if [[ ! -d ./Shfile ]]
        then
            mkdir Shfile && mkdir Shfile/.d && mkdir Shfile/.o \
                && mkdir Shfile/time
        fi

        for src in $src_
        do 

            name=${src##*/}
            all_o="${all_o} Shfile/.o/${name}.o"

            printf "\e[36m[${cnt}]\e[33m${src##*/}"
            ${compiler}  ${src} -c -o Shfile/.o/${name}.o \
                -MMD -MF Shfile/.d/${name}.d \
                $all_include ${pch_} ${cflags[*]} || printf "\n\e[0m"
            echo -e "\e[32m ✔️\e[0m"
            let "cnt++"


            rm -rf ./Shfile/time/${name}.txt
            ptr=1
            for sc in $(cat ./Shfile/.d/${name}.d)
            do
                if (( $ptr == 1 )) || [[ $sc = "\\" ]] || [[ ${sc#${build_file_path}} = $sc ]]
                then 
                    let "ptr++"
                    continue
                fi  
                echo `stat --format=%y ${sc}` >> ./Shfile/time/${name}.txt   
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

    fi
    ${compiler} ${all_o} -o ${mode}/${project[0]} \
        ${pkg_tool} ${cflags[*]} \
        && echo -e "\e[32mBuilding completed\e[0m" || exit 1

    rm -rf ${build_file_path}/${pch_header%/*}/*.pch ${build_file_path}/${pch_header%/*}/*.gch

    rm ./rec/${build_time}.txt
    mv -f ./rec/${build_time}com.txt ./rec/${build_time}.txt


    type after_build &> ./rec/after_build.txt \
        && ( echo "`date` after_build() found." > ./rec/after_build.txt && after_build ) \
        || echo "`date` after_build() not found." > ./rec/after_build.txt
    echo -e "\e[35mRunning time estimate: $SECONDS seconds\e[0m"
done
exit