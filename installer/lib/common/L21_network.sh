network_handler(){
    local line="$1"

    local arg_1=`common_get_arg_n 1 "$line"`  
    local arg_2=`common_get_arg_n 2 "$line"`  
    local arg_3=`common_get_arg_n 3 "$line"`  
    local arg_4=`common_get_arg_n 4 "$line"`  
    local arg_5=`common_get_arg_n 5 "$line"`  

    if [ "$arg_1" = "route" ]
    then  
        echo "route_$arg_2=\"$arg_3 via $arg_5\"" >>/etc/conf.d/net

    elif [ "$arg_1" = "hostname" ]
    then  
	    sed -i "s/hostname.*=.*/hostname=\"$arg_2\"/" /etc/conf.d/hostname
        hostname $arg_2

    elif [ "$arg_1" = "dns" ]
    then 
        echo "nameserver $arg_2" >>/tmp/resolv.conf
    else
        if [ "$arg_2" = "dhcp" ]
        then 
             echo "config_$arg_1=\"dhcp\"" >>/etc/conf.d/net
             ln -s /etc/init.d/net.lo /etc/init.d/net.$arg_1
             rc-update add net.$arg_1 default
        elif [ "$arg_2" = "static" ]
        then
             echo "modules_$arg_1=\"ifconfig\"" >>/etc/conf.d/net
             echo "config_$arg_1=\"$arg_3\"" >>/etc/conf.d/net
             ln -s /etc/init.d/net.lo /etc/init.d/net.$arg_1
             rc-update add net.$arg_1 default
        fi
    fi

}

network_set_hostname_install(){
    local input_file=$1

    local cleaned_network_file=`mktemp`
    common_cleanup_file $input_file $cleaned_network_file
    local line_hostname=`grep "^hostname" $cleaned_network_file`
    local hostname=`common_get_arg_n 2 "$line_hostname"`
    hostname $hostname
}

network_configure(){
    local input_file=$1

    local cleaned_network_file=`mktemp`
    common_cleanup_file $input_file $cleaned_network_file
    echo 
    while read line
    do
        network_handler "$line"
    done <$cleaned_network_file
}
