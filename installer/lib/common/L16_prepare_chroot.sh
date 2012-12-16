prepare_chroot_prepare(){
    config_file=$1

    mount -t proc none $GLOBAL_INSTALL_DIR/proc 
    mount -o bind /dev $GLOBAL_INSTALL_DIR/dev
    cp /etc/resolv.conf $GLOBAL_INSTALL_DIR/etc/
    cp /etc/fstab $GLOBAL_INSTALL_DIR/etc/
    cp -r $GLOBAL_BASE_DIR_INSTALLER $GLOBAL_INSTALL_DIR/$GLOBAL_CHROOT_DIR_INSTALLER
    cp $config_file $GLOBAL_INSTALL_DIR/root
}
