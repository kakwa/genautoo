#!/bin/sh


SUPPORTED_ARCH="amd64 i686" #list of the supported architecture
INSTALLER_DIR="./installer/" #default value, can be override

help(){
echo "`basename $0`: a small tool to build automatic gentoo installer"
echo 
echo "usage: `basename $0` -a <arch> -c <genautoo config file> -o <output iso>"
echo "    \\ [-p <dir with some .deb>] [-D] [ -I <installer dir>]"
echo "    \\ [-i <input debian iso>] [-b <build dir>]"
echo ""
echo "mandatory arguments:"
echo "  -a <arch>: the architecture (currently: $SUPPORTED_ARCH)"
echo "  -c <config file>: the genautoo configuration file"
echo "  -o <output iso>: the name of the generated iso"
echo ""
echo "optional arguments:"
echo "  -p <dir with some .deb>: a directory with .deb to add to the iso"
echo "       could be usefull if you have trouble with some hardware (non-free firmware)"
echo "  -d <dir to include in the iso>: a directory with some content to add to the iso"
echo "       the content of the dir will be included at the / of the new iso"
echo "       could be used to put some files (ex: config) via [*_nochroot] sections"
echo "  -D: adds the generation date"
echo "  -I <installer dir>: path to the installer directory"
echo "  -i <input debian iso>: path to the basic debian install iso"
echo "  -b <build dir>: directory used for the build" 
echo ""
exit 1
}

common_print_message()
{
    # function for displaying a centered message between line of # 
    local message="$1"

    printf "\n\n#############################################################################\n"
    echo "$message" | sed -e :a -e 's/^.\{1,77\}$/ & /;ta'
    printf "#############################################################################\n\n\n"
}

test_present_in_path(){
    #function testing the presence of a binary in $PATH 
    local binary=$1

    which $binary 2>&1 >/dev/null
}

test_present_tool(){
    #function checking if your system have a requiered tool 
    #it exits displaying the packages if tool not present

    local tool=$1
    local gentoo_package=$2
    local debian_package=$3

    if ! test_present_in_path "$tool"
    then
        echo "You need $tool"
        echo "Package:"
        echo "   -gentoo: $gentoo_package"
        echo "   -debian: $debian_package"
        echo
        exit 1
    fi
}

test_needed_tools(){
    #function testing the main needed tools for the generation

    common_print_message "Testing if you have the needed tools"

    test_present_tool "xorriso" "dev-libs/libisoburn" "xorriso"
    test_present_tool "curl" "net-misc/curl" "curl"
    test_present_tool "rsync" "net-misc/rsync" "rsync"
    test_present_tool "cpio" "app-arch/cpio" "cpio"

    common_print_message "You have the tools"
}

die(){
    #a small exit error handler, that exits displaying a given message
    local message="$1"

    echo
    echo "$message"
    echo
    exit 1
}




init_tmp_dir(){
    #tmp build directories initialisation
    if [ -z "$BUILD_DIR" ]
    then
        export TMPDIR="/tmp/"
    else
        export TMPDIR="$BUILD_DIR"
    fi
        
    tmp_mount_dir=`mktemp -d`      || die "could not create tmpdir (mount)"
    tmp_new_iso_dir=`mktemp -d`    || die "could not create tmpdir (new iso)"
    tmp_new_initrd_dir=`mktemp -d` || die "could not create tmpdir (new initrd)"
    tmp_garbage_dir=`mktemp -d`    || die "could not create tmpdir (garbage)"
}

clean(){
    #clean the tmp build directories
    rm -rf $tmp_mount_dir
    rm -rf $tmp_new_iso_dir
    rm -rf $tmp_new_initrd_dir
    rm -rf $tmp_garbage_dir
}

get_base_iso(){
    #function getting the latest stable version of the debian install cd (if not already on the system)

    BASE_URL="http://cdimage.debian.org/debian-cd/current/$ARCH/iso-cd/"

    if [ -z $INPUT_ISO ]
    then
        ISO_NAME=`curl $BASE_URL |grep businesscard.iso|sed "s/.*<a\ href=\"//"|sed "s/\".*//"`

        if ! [ -f $ISO_NAME ]
        then
            common_print_message "getting the lattest (lol) businesscard debian iso"
            wget $BASE_URL/$ISO_NAME || die "could not get the iso (check your connexion)"
        else
            common_print_message "your already have the lattest debian iso"
        fi
    else
        ISO_NAME=$INPUT_ISO
    fi
}


extrac_iso_content(){
    #function mounting a the debian iso, and copying its content inside $tmp_new_iso_dir
    common_print_message "copying the the content of the iso in $tmp_new_iso_dir"
    mount -o ro,loop $ISO_NAME $tmp_mount_dir || die "could not mount the iso"
    rsync -a -H --exclude=TRANS.TBL $tmp_mount_dir/ $tmp_new_iso_dir/
    umount $tmp_mount_dir
}

extract_initrd(){
    #function extracting the content of the iso initrd for later modification
    #it also put the pool directory (containing the packages) in the extract directory
    common_print_message "extracting the content of the initrd"
    tmp_new_initrd_dir_PATH=`find $tmp_new_iso_dir -name "initrd.gz"|grep -v gtk`
    mv $tmp_new_initrd_dir_PATH $tmp_garbage_dir
    cd $tmp_garbage_dir 
    gunzip initrd.gz
    cd -
    cd $tmp_new_initrd_dir
    cpio -id < $tmp_garbage_dir/initrd
    cd -
    mv $tmp_new_iso_dir/pool $tmp_new_initrd_dir/
}

installing_udeb(){
    #function installing some udebs from the pool directory of the iso
common_print_message "installing some udeb, and throwing the rest away"

cat >$tmp_new_initrd_dir/install_udeb.sh <<EOF
#!/bin/sh
/usr/bin/udpkg -i /pool/main/e/eglibc/*
/usr/bin/udpkg -i /pool/main/u/util-linux/*
/usr/bin/udpkg -i /pool/main/r/reiserfsprogs/*
/usr/bin/udpkg -i /pool/main/e/e2fsprogs/*
/usr/bin/udpkg -i /pool/main/l/linux-kernel-di-*/*
/usr/bin/udpkg -i /pool/main//u/util-linux/*
#/usr/bin/udpkg -i /pool/main/o/openssh/*
/usr/bin/udpkg -i /pool/main/m/mountmedia/*
EOF

    chmod 755 $tmp_new_initrd_dir/install_udeb.sh
    chroot $tmp_new_initrd_dir /install_udeb.sh
    rm -rf $tmp_new_initrd_dir/install_udeb.sh
    rm -rf $tmp_new_initrd_dir/pool/
}

editing_debian_installer(){
    #this way, we trick the debian installer to poweroff at the end of the install
    echo "#!/bin/sh" > $tmp_new_initrd_dir/lib/debian-installer/exit-command
    echo "return 22" >> $tmp_new_initrd_dir/lib/debian-installer/exit-command
}

adding_install_scritps(){
    #function adding the genautoo installer, bunzip2 and the config file
    #and adding a small script inside /lib/debian-installer.d/ (we insert our installer inside 
    #the debian installer workflow)
    common_print_message "adding our shit inside this install cd..."
    cp $INSTALLER_DIR/bunzip2/bunzip2.$GENTOO_ARCH $tmp_new_initrd_dir/bin/bunzip2
    cp -r $INSTALLER_DIR $tmp_new_initrd_dir/
    mkdir -p $tmp_new_initrd_dir/config/
    cp -r $CONFIGURATION_FILE $tmp_new_initrd_dir/config/install.cfg
    mv $tmp_new_initrd_dir/installer/lib/arch/$GENTOO_ARCH/*.sh $tmp_new_initrd_dir/installer/lib/arch/

    cd $tmp_new_initrd_dir/lib/debian-installer.d
   #ln -s ../../installer/install.sh S69gentoo_install
    echo "#!/bin/sh" >S69gentoo_install
    echo "/installer/install.sh" >>S69gentoo_install
    chmod 755 S69gentoo_install
    rm -f S70menu
    cd -
}

copy(){
    #function adding the optional custom content
    if ! [ -z "$ADDITIONNAL_CONTENT" ]
    then rsync -a $ADDITIONNAL_CONTENT/ $tmp_new_initrd_dir/
    fi
}

create_new_initrd(){
    #function creating the new initrd and putting it inside the iso directory
    cd $tmp_new_initrd_dir
    find . | cpio --create --format='newc' >$tmp_garbage_dir/initrd
    gzip $tmp_garbage_dir/initrd
    cd -
    mv $tmp_garbage_dir/initrd.gz $tmp_new_initrd_dir_PATH
}


build_new_iso(){
    #funtion building the new iso
    common_print_message "making the new iso"
    sed -i "s/timeout.*/timeout 1/" $tmp_new_iso_dir/isolinux/isolinux.cfg
#    mkisofs -r -T -J -V "Custom Debian Build" -b isolinux/isolinux.bin \
#    -c isolinux/boot.cat -no-emul-boot -boot-load-size 4  -boot-info-table \
#    -o debian_custom_install_`date +%F-%H%M%S`.iso  $tmp_new_iso_dir
     #ISO_NAME="genautoo_install_`date +%F-%H%M%S`.iso"

     xorriso -as mkisofs \
         -iso-level 3 \
         -full-iso9660-filenames \
         -volid "Genautoo" \
         -preparer "prepared by genautoo" \
         -eltorito-boot isolinux/isolinux.bin \
         -eltorito-catalog isolinux/boot.cat \
         -no-emul-boot -boot-load-size 4 -boot-info-table \
         -isohybrid-mbr $tmp_new_iso_dir/g2ldr.mbr \
         -output "$OUT_ISO" \
         "$tmp_new_iso_dir/"
}

test_mandatory_args(){
if [ -z "$GENTOO_ARCH" ] || [ -z "$CONFIGURATION_FILE" ] || [ -z "$OUT_ISO" ]
then
    common_print_message "missing arguments: -a -c and -o are mandatory"
    help
fi

local ret=0
for a in `echo $SUPPORTED_ARCH`
do
    if [ "$a" = "$GENTOO_ARCH" ]
    then
        ret=1
    fi
done

if [ $ret -eq 0 ]
then 
    common_print_message "-a: $GENTOO_ARCH not in [$SUPPORTED_ARCH]"
    help
fi

if ! [ -f $CONFIGURATION_FILE ]
then
    common_print_message "-c: $CONFIGURATION_FILE doesn't exist"
    help
fi

if  [ -f $OUT_ISO ]
then
    common_print_message "-o: $OUT_ISO already exists"
    help
fi
}

test_optionnal_args(){
    if  ! [ -z "$ADDITIONNAL_CONTENT" ] && ! [ -d "$ADDITIONNAL_CONTENT" ]
    then
        common_print_message "-d: $ADDITIONNAL_CONTENT doesn't exist"
        help
    fi

    if  ! [ -z "$PACKAGES_DIR" ] && ! [ -d "$PACKAGES_DIR" ]
    then
        common_print_message "-p: $PACKAGES_DIR doesn't exist"
        help
    fi

    if  ! [ -d $INSTALLER_DIR ]
    then
        common_print_message "-I: $INSTALLER_DIR doesn't exist"
        help
    fi

    if  ! [ -z "$INPUT_ISO" ] && ! [ -f $INPUT_ISO ]
    then
        common_print_message "-i: $INPUT_ISO doesn't exist"
        help
    fi

}

complete_iso_name(){
    if ! [ -z "$TIMESTAMP" ]
    then
        echo $OUT_ISO | grep -q ".iso$"
        ret=$?
        if [ $ret -ne 0 ]
        then 
            OUT_ISO="$OUT_ISO-$GENTOO_ARCH-$TIMESTAMP"
        else
            OUT_ISO=`echo $OUT_ISO |sed "s%\.iso$%-$GENTOO_ARCH-$TIMESTAMP.iso%"`
        fi
    fi
}



set_debian_arch(){
if [ "$GENTOO_ARCH" = "i686" ]
then
    ARCH="i386"
else 
    ARCH="$GENTOO_ARCH"
fi
}

###############################################################################

while getopts ":ha:c:o:Dp:d:i:I:b:" opt; do
  case $opt in

    h) 
        help
        ;;
    a)
        #architecture
        GENTOO_ARCH="$OPTARG"
        ;;
    c)
        #genautoo configuration file
        CONFIGURATION_FILE=`readlink -m $OPTARG`
        ;;

    o)
        #output iso
        OUT_ISO=`readlink -m $OPTARG`
        ;;
    D)
        #generation the timestamp
        TIMESTAMP="`date +%F-%H%M%S`"
    ;;
    d)
        # additionnal content to put on the cd
        ADDITIONNAL_CONTENT=`readlink -m $OPTARG`
    ;;
    p)
        # .deb directory (.deb to install on the cd)
        PACKAGES_DIR=`readlink -m $OPTARG`
    ;;

    I)
        # installer base directory
        INSTALLER_DIR=`readlink -m $OPTARG`
    ;;

    i)
        # input iso used to generate the gentoo iso
        INPUT_ISO=`readlink -m $OPTARG`
    ;;

    b)
        # build directory
        BUILD_DIR=`readlink -m $OPTARG`
    ;;

    \?)
        echo "Invalid option: -$OPTARG" >&2
        help
        exit 1
        ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
        help
        exit 1
        ;;
  esac
done

cd `dirname $0`

test_needed_tools

if [ `id -u` -ne 0 ]
then
    common_print_message "you must be root to execute this script"
    exit 1
fi

test_mandatory_args
complete_iso_name
test_optionnal_args
set_debian_arch
get_base_iso
init_tmp_dir
extrac_iso_content
extract_initrd
installing_udeb
editing_debian_installer
adding_install_scritps
create_new_initrd
build_new_iso
clean

