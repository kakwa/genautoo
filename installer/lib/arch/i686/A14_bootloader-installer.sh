
arch_bootloader_get_disks_list(){
    fdisk -l |grep "^Disk /dev/"| cut -d ' ' -f 2 | cut -b 1-8
}

arch_bootloader_get_grub_boot_disk(){
    local boot_partition=$1
    local disk=`arch_bootloader_get_disk $boot_partition`
    grep "$disk$"  /boot/grub/device.map |sed "s/(//"|sed "s/).*//"
}

arch_bootloader_get_disk(){
    local partition=$1
    for d in `arch_bootloader_get_disks_list`
    do
        echo $partition | grep -q $d
        ret=$?
        if [ $ret -eq 0 ]
        then
            echo $d
        fi
    done
}

arch_get_grub_number(){
    local boot_partition=$1
    local number=$((`echo $boot_partition |sed "s/.*\([0-9][0-9]*\)/\1/"` - 1  ))

    echo $number
}

arch_bootloader_install(){
    
    grep -v rootfs /proc/mounts >/etc/mtab

    emerge grub

    local kernel=`bootloader_get_kernel`
    local initrd=`bootloader_get_initrd`

    local root_partition=`bootloader_get_partition "/"`
    local boot_partition=`bootloader_get_partition "/boot/$kernel"`

        
    local grub_disk=`arch_bootloader_get_grub_boot_disk $boot_partition`
    local grub_number=`arch_get_grub_number $boot_partition`


    if  [ "$root_partition" = "$boot_partition" ] 
    then
        kernel="boot/$kernel"
        initrd="boot/$initrd"
    fi

    cat >/boot/grub/grub.conf <<EOF
default 0
timeout 3
#splashimage=($grub_disk,$grub_number)/boot/grub/splash.xpm.gz

title Gentoo Linux $kernel 
root ($grub_disk,$grub_number)
kernel /$kernel root=$root_partition
initrd /$initrd
EOF
    grub-install --no-floppy /dev/sda
}

