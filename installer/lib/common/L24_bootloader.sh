bootloader_get_partition(){
    local argument=$1
    grep -v rootfs /proc/mounts >/etc/mtab
    df -P $argument | tail -1 | cut -d' ' -f 1
}

bootloader_get_kernel(){
    basename `ls /boot/kernel*|head -n 1`
}

bootloader_get_initrd(){
    basename `ls /boot/initramfs*|head -n 1`
}

bootloader_install_bootloader(){
    arch_bootloader_install
}
