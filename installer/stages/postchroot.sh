#!/bin/sh

cd `dirname $0`

. ./loader

script_name=`basename $0`

common_print_message "[$script_name] executing the [post_install_nochroot] section"
$GLOBAL_SPLITTED_DIR/post_install_nochroot

common_print_message "[$script_name] configuring the dns for the target system"
final_new_resolv_conf
