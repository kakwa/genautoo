#!/bin/sh

cd `dirname $0`

script_name=`basename $0`

#loading of the libs
. ./loader

#$1 is the configuration file
config_file=$1

common_print_message "[$script_name] splitting the configuration for easier use"
splitter_cfg_splliter $config_file $GLOBAL_SPLITTED_DIR

common_print_message "[$script_name] loading the global variables"
. $GLOBAL_SPLITTED_DIR/global

common_print_message "[$script_name] setting the proxys variable"
common_set_proxy

common_print_message "[$script_name] setting the mirror for stage3 and portage-latest"
common_set_mirror

common_print_message "[$script_name] network configuration"
network_install_configure $GLOBAL_SPLITTED_DIR/network_install

common_print_message "[$script_name] executing the pre_setup section"
$GLOBAL_SPLITTED_DIR/pre_setup

common_print_message "[$script_name] partitionning the disks"
partitionning_partitionning $GLOBAL_SPLITTED_DIR/partitionning

common_print_message "[$script_name] formatting and mounting"
formatting_format_and_mount $GLOBAL_SPLITTED_DIR/partitionning

common_print_message "[$script_name] installing basesysteme (stage3 & distfiles)"
stage3_deploy_new_env

common_print_message "[$script_name] preparing the chroot"
prepare_chroot_prepare $config_file

common_print_message "[$script_name] executing the [pre_install_nochroot] section"
$GLOBAL_SPLITTED_DIR/pre_install_nochroot
