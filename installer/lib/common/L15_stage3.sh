stage3_install_stage3(){
    cd $GLOBAL_INSTALL_DIR
    current_stage3=`wget -qO- $mirror/releases/$STAGE3_ARCH_MIRROR/autobuilds/current-stage3-${STAGE3_ARCH_MIRROR}/ |grep "href=\"stage3-$STAGE3_ARCH_MIRROR.*.tar.bz2\""|sed "s/.*href=\"//"|sed "s/\".*//"`
    wget $mirror/releases/$STAGE3_ARCH_MIRROR/autobuilds/current-stage3-${STAGE3_ARCH_MIRROR}/$current_stage3
    bunzip2 $current_stage3
    tar -xvpf `ls stage3-*`
    rm -f  `ls stage3-*`
    cd -

}

stage3_install_distfiles(){
    cd  $GLOBAL_INSTALL_DIR/usr
    wget $mirror/snapshots/portage-latest.tar.bz2 
    bunzip2 portage-latest.tar.bz2
    tar -xvpf portage-latest.tar
    rm -f portage-latest.tar
    cd -
}

stage3_deploy_new_env(){
    stage3_install_stage3
    stage3_install_distfiles
}
