network_set_hostname(){
    if ! [ -z "$hostname" ]
    then
	    sed -i "s/hostname.*=.*/hostname="$hostname"/" /etc/conf.d/hostname
        hostname $hostname
    fi
}

#network_configure_interface(){
#local input=$1
#}
