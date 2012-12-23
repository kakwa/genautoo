common_set_proxy(){
    #export proxy env variables if needed

    #if specified, we set the proxy
    if ! [ -z "$proxy" ]
    then
        export http_proxy=$proxy
        export ftp_proxy=$proxy
        export https_proxy=$proxy
    fi
}

common_set_mirror(){
    #set the mirror where we get the stage3 and the portage tree

    #if empty, we set a default value
    if  [ -z "$mirror" ]
    then
        mirror="$GLOBAL_DEFAULT_MIRROR"
    fi
}

common_set_parallele_emerges(){
    #set the number of emerge to run in parallel 
    #(-jN option of emerge, not the MAKEOPTS in make.conf)
    #if empty, we set a default value
    if  [ -z "$parallele_emerge" ]
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
    #get arg N of a space separated list of arguments in a given line
    #$1 -> the arg number
    #$2 -> the line

    local arg_number=$1
    local line="$2"

    echo "$line" | cut -d ' ' -f$arg_number

}

common_get_line_n(){
    #get the line N of a given file
    local input_file=$1
    local line=$2

    sed -n ${line}p $input_file
}


common_print_message()
{
     #small function that print a centered message (the message must be between quotes or double quotes)
     printf "\n\n#############################################################################\n" 
     echo "$1" | sed -e :a -e 's/^.\{1,77\}$/ & /;ta'
     printf "#############################################################################\n\n\n" 
}

COUNTER_TMP=1112
mktemp(){
    #a dirty reimplementation of mktemp 
    #it only handles creation of a dir or a file in /tmp
    #(I believed it was in the debian install cd, but no)
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
