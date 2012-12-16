kernel_install_kernel(){
    #if we have put a .config
    if [ -f /usr/src/linux/.config ]
    then 
        cd /usr/src/linux/
        make $parallele_emerge && make modules_install $parallele_emerge && make install
    else
        emerge $GLOBAL_PARALLELE_EMERGE genkernel
        cd /usr/src/linux/
        genkernel --makeopts="$parallele_emerge" --no-menuconfig all
    fi
}

