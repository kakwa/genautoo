kernel_install_kernel(){
    #this function compile the kernel 
    #it uses genkernel (need to find a better way)

    #if we have put a .config (not working know)
    if [ -f /usr/src/linux/.config ]
    then 
        cd /usr/src/linux/
        make $parallele_emerge && make modules_install $parallele_emerge && make install
    else
        emerge $parallele_emerge genkernel
        cd /usr/src/linux/
        genkernel --makeopts="$parallele_emerge" --no-menuconfig all
    fi
}

