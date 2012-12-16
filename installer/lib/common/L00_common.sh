common_set_proxy(){
    #if specified, we set the proxy
    if ! [ -z $proxy ]
    then
        export http_proxy=$proxy
        export ftp_proxy=$proxy
        export https_proxy=$proxy
    fi
}

common_set_mirror(){
    #if empty, we set a default value
    if  [ -z $mirror ]
    then
        mirror="$GLOBAL_DEFAULT_MIRROR"
    fi
}

common_set_parallele_emerges(){
    #if empty, we set a default value
    if  [ -z $parallele_emerge ]
    then
        parallele_emerge="$GLOBAL_DEFAULT_PARALLE_ERMERGE"
    fi
}

common_cleanup_file(){
    #this function cleans a file
    #it supress comments and empty lines
    local input_file=$1
    local output_file=$2

    mkdir -p `dirname $output_file`
    sed "s/#.*//" $input_file |grep -v '^$' >$output_file
}

common_get_arg_n(){
    local arg_number=$1
    local line="$2"

    echo "$line" | cut -d ' ' -f$arg_number

}

common_get_line_n(){
    local input_file=$1
    local line=$2

    sed -n ${line}p $input_file
}


common_print_message()
{
     printf "\n\n#############################################################################\n" 
     echo "$1" | sed -e :a -e 's/^.\{1,77\}$/ & /;ta'
     printf "#############################################################################\n\n\n" 
}

COUNTER_TMP=1112
mktemp(){
    while [ -e /tmp/tmp.$COUNTER_TMP ]
    do
        COUNTER_TMP=$(( $COUNTER_TMP + 1 ))
    done

    if [ "$1" = "-d" ]
    then
        mkdir -p /tmp/tmp.$COUNTER_TMP
    else
        touch /tmp/tmp.$COUNTER_TMP
    fi
    echo "/tmp/tmp.$COUNTER_TMP"
    COUNTER_TMP=$(( $COUNTER_TMP + 1 ))
}
