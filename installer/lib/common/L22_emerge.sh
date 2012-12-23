#this lib handles emerge and its shits...

package_cleanup_package_list(){
    #this function filters the list of package 
    #it only keeps the existing packages
    local input_packages_list=$1
    local output_packages_list=$2
    local error_packages_list=$3

    . $GLOBAL_MAKECONF_PATH

    local cleaned_packages_list=`mktemp`
    common_cleanup_file $input_packages_list  $cleaned_packages_list

    for package in `cat $cleaned_packages_list`
    do
        package_package_exists $package
        ret=$?
        if [ $ret -eq 0 ]
        then 
            echo "$package" >>$output_packages_list
        else
            echo "$package" >>$error_packages_list
        fi
    done
}

package_package_exists(){
    #this function test if a given pakage exists
    local package=$1

    PORTAGE_DIR="/usr/portage/ $PORTDIR_OVERLAY"

    local ret=1
    for portage_dir in $PORTAGE_DIR
    do
        if [ -d $portage_dir/$package ]
        then
            ret=0
        fi
    done
    return $ret
}

package_number_of_installed_packages(){
    emerge -evp world 2>/dev/null |grep "Total:\ [0-9]*\ package"|sed "s/Total: //"|sed "s/package.*//"
}

package_update_and_install_list(){
    local input_packages_list=$1

    #we clean the mess you've done
    input_packages_list_cleaned=`mktemp`
    error_packages="/root/error_packages"
    package_cleanup_package_list $input_packages_list $input_packages_list_cleaned $error_packages

    #we update
    rm /usr/portage/metadata/timestamp.x
    emerge-webrsync
    emerge -v $parallele_emerge gentoolkit

    ret=1
    
    #just putting the packages to install in a variable
    local new_packages=`cat $input_packages_list_cleaned`


    #first attempt to install our packages, if it fails, maybe it only because
    #of  ~ packages (or worst), so we unmask then
    emerge -uvDN world $parallele_emerge `echo $new_packages` --autounmask-write
    ret=$?
    etc-update --automode "-5" 

    #while we have some troubles, we revdep-rebuuild etc... and retry
    #could easily end up in an infinite loop!
    while [ $ret -ne 0 ] 
    do
        perl-cleaner --reallyall
        python-updater
        revdep-rebuild
        emerge -uvDN world $parallele_emerge `echo $new_packages`
        ret=$?
        
    done

    #we clean one last time
    perl-cleaner --reallyall
    python-updater
    revdep-rebuild
}
