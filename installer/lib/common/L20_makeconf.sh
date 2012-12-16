makeconf_add_makeconf_section(){
    tmp=`mktemp`
    cat $GLOBAL_MAKECONF_PATH $GLOBAL_CHROOT_DIR_INSTALLER/$GLOBAL_SPLITTED_DIR/make.conf >$tmp
    mv $tmp $GLOBAL_MAKECONF_PATH
}
