
#load sh.sh
if test -e ${build_file_path}/${build_file}
then
    source ${build_file_path}/${build_file}
else
    echo "sh.sh no found"
    exit 1
fi

if test -d ./rec 
then
    echo "检测脚本记录"
else
    mkdir rec && echo "创建脚本记录"
fi


type before_build &>./rec/before_build.txt \
    && ( echo "before_build() found." > ./rec/before_build.txt && before_build ) \
    || echo "before_build() not found." > ./rec/before_build.txt 



all_include=""
all_o=""


if [ -d ./Shfile ]
then
    echo "file already"

    for src in ${includedir}
    do
        all_include="${all_include} -I ${includedir}"
    done

    for src in ${sources[@]}
    do 
        int=0
        len=${#src}
        idex=0
        while(( $int<=$len ))
        do
            s=${src:${int}:1}
            if [[ $s = "/" ]]
            then
                idex=`expr ${int} + 1`
            fi
            let "int++"
        done

        if [ -f ./Shfile/.d/${src:${idex}}${idex}.d ]
        then
            ptr=1
            for str in $(cat ./Shfile/.d/${src:${idex}}${idex}.d)
            do
                if (( $ptr == 1 ))
                then 
                    let "ptr++"
                    continue
                else
                    scc=$str
                fi
                if [[ $scc = "\\" ]]
                then 
                    continue
                fi
                echo `stat --format=%y ${scc}` >> ./Shfile/time/${src:${idex}}${idex}com.txt
            done
            if [[ $(cat ./Shfile/time/${src:${idex}}${idex}com.txt) != $(cat ./Shfile/time/${src:${idex}}${idex}.txt) ]]
            then
                ${compiler} ${build_file_path}/${src} -c -o Shfile/.o/${src:${idex}}${idex}.o \
                    -MMD -MF Shfile/.d/${src:${idex}}${idex}.d \
                    ${all_include}
                echo "${src:${idex}}"

            fi
            mv ./Shfile/time/${src:${idex}}${idex}com.txt ./Shfile/time/${src:${idex}}${idex}.txt 
        
        else
            ${compiler} ${build_file_path}/${src} -c -o Shfile/.o/${src:${idex}}${idex}.o \
                -MMD -MF Shfile/.d/${src:${idex}}${idex}.d \
                ${all_include}
            echo "${src:${idex}}"
            echo `stat --format=%y ${scc}` >> ./Shfile/time/${src:${idex}}${idex}.txt
        fi
        all_o="${all_o} Shfile/.o/${src:${idex}}${idex}.o"
    done

    ${compiler} ${all_o} -o ${project[0]} \
        `pkg-config --libs --cflags ${deps[@]}` \
        && echo "Building completed"


else
    mkdir Shfile && mkdir Shfile/.d && mkdir Shfile/.o \
        && mkdir Shfile/time || ( echo "error" && exit 2 )

    for src in ${includedir}
    do
        all_include="${all_include} -I ${includedir}"
    done

    for src in ${sources[@]}
    do 
        int=0
        len=${#src}
        idex=0
        while(( $int<=$len ))
        do
            s=${src:${int}:1}
            if [[ $s = "/" ]]
            then
                idex=`expr ${int} + 1`
            fi
            let "int++"
        done

        ${compiler} ${build_file_path}/${src} -c -o Shfile/.o/${src:${idex}}${idex}.o \
            -MMD -MF Shfile/.d/${src:${idex}}${idex}.d \
            ${all_include}
        echo "${src:${idex}}"

        all_o="${all_o} Shfile/.o/${src:${idex}}${idex}.o"

        ptr=1
        for str in $(cat ./Shfile/.d/${src:${idex}}${idex}.d)
        do
            if (( $ptr == 1 ))
            then 
                let "ptr++"
                continue
            else
                scc=$str
            fi
            if [[ $scc = "\\" ]]
            then 
                continue
            fi
            echo `stat --format=%y ${scc}` >> ./Shfile/time/${src:${idex}}${idex}.txt
        done
    done

    ${compiler} ${all_o} -o ${project[0]} \
        `pkg-config --libs --cflags ${deps[@]}` \
        && echo "Building completed"
fi



type after_build &> ./rec/after_build.txt \
    && ( echo "after_build() found." > ./rec/after_build.txt && after_build ) \
    || echo "after_build() not found." > ./rec/after_build.txt

echo -e "time-consuming: $SECONDS seconds"