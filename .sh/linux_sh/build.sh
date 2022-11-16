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

    pch_=""
    if [[ ${pch_header} = "" ]]
    then
        pch_=" "
    else
        cp ${build_file_path}/${pch_header} Shfile/pch/
        if [[ ${pch_header} =~ ".hpp" ]];then
            name_pch=`ls Shfile/pch/*.hpp`
        else
            name_pch=`ls Shfile/pch/*.h`
        fi
            
        ${compiler} -c -o ${name_pch%.*}.pch $name_pch
        cp Shfile/pch/*.pch ${build_file_path}/${pch_header%/*}
    fi

    build_time=${build##*/}

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

    all_o=""
    if [[ -d ./Shfile ]] && [[ $rebuild = "n" ]] && \
        [[ $(cat ./rec/${build_time}com.txt) = $(cat ./rec/${build_time}.txt) ]]
    then 

        cnt=1

        for src in $src_
        do 
            
            name=${src##*/}

            all_o="${all_o} Shfile/.o/${name}.o"

            if [ -f ./Shfile/.d/${name}.d ]
            then
                ptr=1
                for sc in $(cat ./Shfile/.d/${name}.d)
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
                    echo `stat --format=%y ${scc}` >> ./Shfile/time/${name}com.txt
                done

                if [[ $(cat ./Shfile/time/${name}com.txt) != $(cat ./Shfile/time/${name}.txt) ]]
                then
                    
                    printf "\e[36m[${cnt}]\e[33m${src##*/}"
                    ${compiler}  ${src} -c -o Shfile/.o/${name}.o \
                        -MMD -MF Shfile/.d/${name}.d \
                        $all_include ${pch_} || printf "\n\e[0m"
                    echo -e "\e[32m ✔️\e[0m"
                    let "cnt++"
                fi

                rm ./Shfile/time/${name}.txt 
                mv -f ./Shfile/time/${name}com.txt ./Shfile/time/${name}.txt 
        
            else
                printf "\e[36m[${cnt}]\e[33m${src##*/}"
                ${compiler}  ${src} -c -o Shfile/.o/${name}.o \
                    -MMD -MF Shfile/.d/${name}.d \
                    $all_include ${pch_} || printf "\n\e[0m"
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
                && mkdir Shfile/time && mkdir Shfile/pch
        fi

        cnt=1

        for src in $src_
        do 

            name=${src##*/}
            all_o="${all_o} Shfile/.o/${name}.o"

            printf "\e[36m[${cnt}]\e[33m${src##*/}"
            ${compiler}  ${src} -c -o Shfile/.o/${name}.o \
                -MMD -MF Shfile/.d/${name}.d \
                $all_include ${pch_} || printf "\n\e[0m"
            echo -e "\e[32m ✔️\e[0m"
            let "cnt++"

            ptr=1
            for sc in $(cat ./Shfile/.d/${name}.d)
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
                echo `stat --format=%y ${scc}` >> ./Shfile/time/${name}.txt
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
    ${compiler} ${all_o} -o ${project[0]} \
        ${pkg_tool} ${cflags[*]} ${pch_} \
        && echo -e "\e[32mBuilding completed\e[0m" || exit 1

    rm -rf ${build_file_path}/${pch_header%/*}/*.pch

    rm ./rec/${build_time}.txt
    mv -f ./rec/${build_time}com.txt ./rec/${build_time}.txt


    type after_build &> ./rec/after_build.txt \
        && ( echo "`date` after_build() found." > ./rec/after_build.txt && after_build ) \
        || echo "`date` after_build() not found." > ./rec/after_build.txt
    echo -e "\e[35mRunning time estimate: $SECONDS seconds\e[0m"
done
exit