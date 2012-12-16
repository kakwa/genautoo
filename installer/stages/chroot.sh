#!/bin/sh

cd `dirname $0`

. ./loader

script_name=`basename $0`

common_print_message "[$script_name] updating the environment" 
source /etc/profile
env-update

common_print_message "[$script_name] loading of the global variables" 
. $GLOBAL_CHROOT_DIR_INSTALLER/$GLOBAL_SPLITTED_DIR/global

common_print_message "[$script_name] setting the proxys variables" 
common_set_proxy
 
common_print_message "[$script_name] adding lines to make.conf"
makeconf_add_makeconf_section

common_print_message "[$script_name] executing the [pre_install_chroot] section"
$GLOBAL_CHROOT_DIR_INSTALLER/$GLOBAL_SPLITTED_DIR/pre_install_chroot


#common_print_message "[$script_name] updating the stage3 in accordance of the new useflags"
#update_base_update

common_print_message "[$script_name] updating and installing the packages"
package_update_and_install_list $GLOBAL_CHROOT_DIR_INSTALLER/$GLOBAL_SPLITTED_DIR/packages

common_print_message "[$script_name] installaling the kernel"
kernel_install_kernel

common_print_message "[$script_name] installaling bootloader"
bootloader_install_bootloader

common_print_message "[$script_name] executing the [post_install_chroot] section"
$GLOBAL_CHROOT_DIR_INSTALLER/$GLOBAL_SPLITTED_DIR/post_install_chroot

common_print_message "[$script_name] setting the root password"
password_set_password

#deploy_env(){
#mv   ../env.d/* /
#}

#update_stage3(){
#emerge -j3  gentoolkit
#emerge-webrsync
#emerge -uvDN -j3 world
#revdep-rebuild
#echo "truc"
#}


#install_kernel(){
#emerge gentoo-sources genkernel
#cd /usr/src/linux/
#genkernel --makeopts=-j8 --no-menuconfig all
#}

#install_grub(){
#emerge grub
#kernel=`ls /boot/kernel*|head -n 1`
#initrd=`ls /boot/initramfs*|head -n 1`
#cat >/boot/grub/grub.conf <<EOF
#default 0
#timeout 3
#splashimage=(hd0,0)/boot/grub/splash.xpm.gz

#title Gentoo Linux $kernel 
#root (hd0,1)
#kernel /boot/$kernel root=/dev/sda2
#initrd /boot/$initrd
#EOF
#grep -v rootfs /proc/mounts >/etc/mtab
#grub-install --no-floppy /dev/sda
#}

#set_root_password(){
#printf "password\npassword\n"|passwd
#}

#deploy_env
#update_stage3
#install_kernel
#install_grub
#set_root_password
