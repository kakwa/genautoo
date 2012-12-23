bootloader_get_partition(){
    #this function gets the partition of a given file
    #or a given dir
    #$1 the given file or dir

    local argument=$1
    grep -v rootfs /proc/mounts >/etc/mtab
    df -P $argument | tail -1 | cut -d' ' -f 1
}

bootloader_get_kernel(){
    #find a kernel
    basename `ls /boot/kernel*|head -n 1`
}

bootloader_get_initrd(){
    #find an initrd
    basename `ls /boot/initramfs*|head -n 1`
}

bootloader_install_bootloader(){
    #install the bootloader
    arch_bootloader_install
}
