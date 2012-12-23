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

common_print_message "[$script_name] configuring the network for the future system"
network_configure $GLOBAL_CHROOT_DIR_INSTALLER/$GLOBAL_SPLITTED_DIR/network

common_print_message "[$script_name] executing the [pre_install_chroot] section"
$GLOBAL_CHROOT_DIR_INSTALLER/$GLOBAL_SPLITTED_DIR/pre_install_chroot

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


