#!/bin/sh


cd `dirname $0`

. ./conf/global.cfg

#detect the hardware (debian stuff)
/bin/hw-detect

#probe the necessary modules
depmod -a


#if we specify another file in the first argument
if ! [ -z "$1" ]
then
    CONFIG_FILE=$1
else
    CONFIG_FILE=$GLOBAL_CONFIG_FILE
fi


#pre chroot setup (partitionning, stage3 etc)
./stages/prechroot.sh $CONFIG_FILE

#some preparation before the chroot
cp $CONFIG_FILE $GLOBAL_INSTALL_DIR/root/

#the chroot script (install and compile packages)
chroot $GLOBAL_INSTALL_DIR $GLOBAL_CHROOT_DIR_INSTALLER/$GLOBAL_BASE_DIR_INSTALLER/stages/chroot.sh

#the post chroot script
./stages/postchroot.sh

#we end the installation
exec /lib/debian-installer/exit

#init 0
