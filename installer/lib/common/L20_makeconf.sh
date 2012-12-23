makeconf_add_makeconf_section(){
    #this function updates the make.conf (it adds the line 
    #of the section make.conf to the existing make.conf)
    tmp=`mktemp`
    cat $GLOBAL_MAKECONF_PATH $GLOBAL_CHROOT_DIR_INSTALLER/$GLOBAL_SPLITTED_DIR/make.conf >$tmp
    mv $tmp $GLOBAL_MAKECONF_PATH
}
