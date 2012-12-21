#this script splits the install script according to predefine section

#List of sections which are configuration
SPLITTER_CONFIG_SECTIONS="network_install network partitionning packages \
make.conf"

#List of section which are scripts
SPLITTER_SCRIPT_SECTIONS="pre_setup pre_install_nochroot \
pre_install_chroot post_install_chroot \
post_install_nochroot global"

splitter_cfg_splliter(){

    #external function splitting the configuration file
    #input $1 -> the config file
    #input $2 -> the out directory where to put the result
    #error 11 if $1 or $2 is empty
    #error 12 if $1 doesn't exist
    #error 13 if $2 cannot be created
    #error 14 if $2 is not writtable for you


    local input_file=$1
    local output_dir=$2

    ! [ -z "$input_file" ] || exit 11
    ! [ -z $output_dir ] || exit 11

    [ -f $input_file ] || exit 12
    
    splitter_init $output_dir 
    
    while read -r line
    do
        if splitter_setflag $line && ! [ -z $SPLITTER_CURRENT_OUTFILE ]
        then echo "$line" >>$output_dir/$SPLITTER_CURRENT_OUTFILE
        fi
        
    done < $input_file 
}

splitter_init(){

    #function initiating the different files 
    #input $1 -> the out directory where to put the result

    local output_dir=$1

    mkdir -p "$output_dir" || exit 13

    for script in `echo $SPLITTER_SCRIPT_SECTIONS`
    do  
        echo "#!/bin/sh" >$output_dir/$script ||exit 14
        chmod 755 $output_dir/$script ||exit 14
    done

    for config in $SPLITTER_CONFIG_SECTIONS
    do  
        echo -n "" > $output_dir/$config ||exit 14
    done
}

splitter_setflag(){
    #this function sets the flag (the current section we are dealing with)
    #it sets the global variable $flag to the section's name
    #if it's a section delimiter and return 1.
    #it return 0 if it's a standard line.
    flag=$1
    for section in `echo $SPLITTER_SCRIPT_SECTIONS $SPLITTER_CONFIG_SECTIONS`
    do
        if echo $flag | grep -q "\[$section\]"
        then 
            SPLITTER_CURRENT_OUTFILE=$section
            return 1
        fi
    done
    return  0
}


##splitter_cfg_splliter $1 $2
