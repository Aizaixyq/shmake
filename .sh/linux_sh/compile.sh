compile(){

    printf "$1 $2 $3 $4 $5 $6\n"
    all_o=""
    for src in $3
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
                ${1}  ${src} -c -o Shfile/.o/${src:${idex}}${idex}.o \
                    -MMD -MF Shfile/.d/${src:${idex}}${idex}.d \
                    ${4}
                echo "${src:${idex}}"
            fi

            rm ./Shfile/time/${src:${idex}}${idex}.txt
            mv ./Shfile/time/${src:${idex}}${idex}com.txt ./Shfile/time/${src:${idex}}${idex}.txt 
        
        else
            ${1}  ${src} -c -o Shfile/.o/${src:${idex}}${idex}.o \
                -MMD -MF Shfile/.d/${src:${idex}}${idex}.d \
                ${4}
            echo "${src:${idex}}"
            echo `stat --format=%y ${scc}` >> ./Shfile/time/${src:${idex}}${idex}.txt
        fi
    done

    ${1} ${all_o} -o ${5} \
        `pkg-config --libs --cflags ${6}` \
        && echo "Building completed"
}

first_compile(){

    printf "$1 $2 $3 $4 $5 $6\n"
    mkdir Shfile && mkdir Shfile/.d && mkdir Shfile/.o \
        && mkdir Shfile/time || ( echo "error" && exit 2 )

    for src in $3
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

        ${1}  ${src} -c -o Shfile/.o/${src:${idex}}${idex}.o \
            -MMD -MF Shfile/.d/${src:${idex}}${idex}.d \
            ${4}
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

    ${1} ${all_o} -o ${5} \
        `pkg-config --libs --cflags ${6}` \
        && echo "Building completed"
}
