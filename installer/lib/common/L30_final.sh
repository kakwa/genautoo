#this lib handles the final steps of the installation

final_new_resolv_conf(){
    #this function adds the new resolv.conf to the build system
    mv $GLOBAL_INSTALL_DIR/tmp/resolv.conf $GLOBAL_INSTALL_DIR/etc/
}
