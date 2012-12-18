#this lib handles the configuration of the network during the install stage

network_install_handler(){
    local line="$1"

    local arg_1=`common_get_arg_n 1 "$line"`  
    local arg_2=`common_get_arg_n 2 "$line"`  
    local arg_3=`common_get_arg_n 3 "$line"`  
    local arg_4=`common_get_arg_n 4 "$line"`  
    echo $arg_1 $arg_2 $arg_3 $arg_4

    if [ "$arg_1" = "route" ]
    then  
        route add -net $arg_2 $arg_3 $arg_4
    elif [ "$arg_1" = "dns" ]
    then 
        echo "nameserver $arg_2" >>/etc/resolv.conf
    else
        if [ "$arg_2" = "dhcp" ]
        then 
            udhcpc $arg_1
        elif [ "$arg_2" = "static" ]
        then
             ip addr add $arg_3 dev $arg_1
             ip link set $arg_1 up
        fi
    fi

}

network_install_configure(){
    local input_file=$1
    local cleaned_network_file=`mktemp`
    common_cleanup_file $input_file $cleaned_network_file
    while read line
    do
        network_install_handler "$line"
    done <$cleaned_network_file
}
