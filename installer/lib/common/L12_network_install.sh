#this lib handles the configuration of the network during the install stage

network_install_handler(){
    #This function does the configuration 
    #$1: a line of the cleaned install_network file 
    local line="$1"

    #we get the argument of the line (space separated)
    local arg_1=`common_get_arg_n 1 "$line"`  
    local arg_2=`common_get_arg_n 2 "$line"`  
    local arg_3=`common_get_arg_n 3 "$line"`  
    local arg_4=`common_get_arg_n 4 "$line"`  
    local arg_5=`common_get_arg_n 5 "$line"`  

    #treatement if we have a route
    if [ "$arg_1" = "route" ]
    then  
        route add -net $arg_3 $arg_4 $arg_5

    #treatment if we have a dns
    elif [ "$arg_1" = "dns" ]
    then 
        echo "nameserver $arg_2" >>/etc/resolv.conf

        #default treatement 
        #(must be an interface, if it's something else, we try anyway)
    else

        #sub-treatement for a dhcp configuration
        if [ "$arg_2" = "dhcp" ]
        then 
            udhcpc $arg_1

        #sub-treatement for a static configuration
        elif [ "$arg_2" = "static" ]
        then
             ip addr add $arg_3 dev $arg_1
             ip link set $arg_1 up
        fi
    fi

}

network_install_configure(){
    #this function configures the network according to the install_network section
    #$1: the input file (file containing the install_network section)

    local input_file=$1
    local cleaned_network_file=`mktemp`

    #we clean the install_network section (no comments, no empty lines)
    common_cleanup_file $input_file $cleaned_network_file

    #we handle line by line the cleaned file
    while read line
    do
        network_install_handler "$line"
    done <$cleaned_network_file
}
