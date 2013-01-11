# Genautoo: an automated installer for gentoo

The goal of Genautoo is to install automatically Gentoo/Linux by customizing a single file.

## License

genautoo is released under the MIT Public License

## Why Genautoo?

I'm not a big fan of redhat/fedora/centos but there is one thing I like in this environnement: the kickstart files.
One simple file permitting you to easily install and reinstall and rereinstall your system as you want.

Installing Gentoo is fun, but once you've done it several times, it doesn't learn you anything.
It's just a time consuming process, but for those who like the distro, it remains a necessary step. 

In some cases, you may want to reinstall from scratch regularly. For example if you maintain some packages,
it's a crude way to check that your ebuilds still work (since gentoo is a rolling release, your ebuilds could easily break).

In other cases, you may want to install identical Gentoos on several computers.

Genautoo is a solution for these situations.

## Description

Genautoo is two things:

- A script generating a custom install iso for gentoo: genautoo.sh

- An installer: installer/install.sh (and its libs)

## How do I use it?

Just follow the steps:

- create your config file 
    
- run (as root, sorry):

    ./genautoo.sh -a amd64 -c <path to your config file> -o my_custom_install.iso

- burn the iso/dd it on a usb stick

- boot the shit

- take a (long) coffee (several in fact)

- restart your computer (don't forget to remove the install media) and VOILA!

## Okay, but how do I create the config file?

Just use vim :) 

Humm, that's not helping? Okay. Creating the config file is simple, here is a simple example:

```shell
    [global]
    #some global parameters

    #mirror="http://mirror.ovh.net/gentoo-distfiles/"
    #proxy="http://myproxy.example.net:8080"
    parallele_emerge="-j4"
    root_password="changeme"

    [network_install]
    #network configuration during the installation
    eth0 dhcp
    #eth1 static 192.168.42.100/24
    #route eth1 default gw 192.168.42.254
    #dns 8.8.8.8

    [network]
    #network configuration of the installed system

    #eth1 static 192.168.69.51/24
    #route eth1 default gw 192.168.69.1
    #dns 8.8.8.8


    [partitionning]
    #partitions description

    #DISK     SIZE     FS          MOUNT_POINT
    /dev/sda   120M     ext4        /boot
    /dev/sda   1G       reiserfs    /
    /dev/sda   5G       ext4        /home
    /dev/sda   5G       ext4        /usr
    /dev/sda   1G       swap
    /dev/sda   ALL      ext4        /var

    [make.conf]
    #lines ADDED to the make.conf

    MAKEOPTS="-j8"
    ACCEPT_LICENSE="*"
    LINGUAS="en fr"

    [packages]
    #list of the packages to install

    net-misc/dhcpcd
    app-editors/vim
    sys-process/htop
    sys-kernel/gentoo-sources

    [pre_setup]
    #script executed before anything has started

    echo "hello"

    [pre_install_nochroot]
    #shell script executed just before the chrooting

    echo "I"

    [pre_install_chroot]
    #shell script executed just after the chrooting

    echo "am"

    [post_install_chroot]
    #shell script executed after the installation inside the chroot

    echo "genautoo"

    [post_install_nochroot]
    #shell script executed after the installation outside the chroot

    echo "installer"
```
The order of the section doesn't matter, and you can split a section, for example:

    [global]
    #some global parameters

    [partitionning]
    #partitions description

    #DISK     SIZE     FS          MOUNT_POINT
    /dev/sda   120M     ext4        /boot
    /dev/sda   1G       reiserfs    /

    [global]
    #rest of the global parameters

Any way, there are some examples in the examples directory.

## How does the installer work?

It's simply a bunch of bourne shell scripts that use the config file to do what they have to do.

More explanations coming soon...

## How does genautoo.sh work?

Just take a look at the help:

    ./genautoo.sh -h

Without optional arguments, it takes the installer, the config file, it downloads the latest debian (hehehe) businesscard iso of the specified arch, and it builds a custom iso

More explanations coming soon...

