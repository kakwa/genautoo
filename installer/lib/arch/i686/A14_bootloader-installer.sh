arch_bootloader_get_disks_list(){
    #a small function listing the disks
    fdisk -l |grep "^Disk /dev/"| cut -d ' ' -f 2 | cut -b 1-8
}

arch_bootloader_get_grub_boot_disk(){
    #function making the link between /dev/sd* and hd* (the "grub naming")
    #$1 -> boot partition's name (/dev/sd* format)
    local boot_partition=$1

    local disk=`arch_bootloader_get_disk $boot_partition`
    grep "$disk$"  /boot/grub/device.map |sed "s/(//"|sed "s/).*//"
}

arch_bootloader_get_disk(){
    #this function get the disk of a given partition 
    #(arch_bootloader_get_disk sda1 -> sda)
    #$1 -> the partition

    local partition=$1

    for d in `arch_bootloader_get_disks_list`
    do
        #no, sed "s//[0-9]$/" doesn't work 
        #(ex, compaq raid card: /dev/ida/c0d0, partition is /dev/ida/c0d0p1)
        echo $partition | grep -q $d
        ret=$?
        if [ $ret -eq 0 ]
        then
            echo $d
        fi
    done
}

arch_get_grub_number(){
    #function getting the number of a device (1 in /dev/sda1) and return 
    #this number - 1
    #it's used for sda1 -> (hd0,0) conversion for grub
    #I am counting on the fact that linux starts at "1" the numbering of its devices
    #don't know if it's always true...

    local boot_partition=$1
    local number=$((`echo $boot_partition |sed "s/.*\([0-9][0-9]*\)/\1/"` - 1  ))

    echo $number
}

arch_bootloader_install(){
    #function configuring the bootloader
    
    grep -v rootfs /proc/mounts >/etc/mtab

    emerge grub

    local kernel=`bootloader_get_kernel`
    local initrd=`bootloader_get_initrd`

    local root_partition=`bootloader_get_partition "/"`
    local boot_partition=`bootloader_get_partition "/boot/$kernel"`

        
    local grub_disk=`arch_bootloader_get_grub_boot_disk $boot_partition`
    local boot_disk=`arch_bootloader_get_disk `
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
    grub-install --no-floppy $boot_disk
}

