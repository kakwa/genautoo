update_base_update(){
    rm /usr/portage/metadata/timestamp.x
    emerge $parallele_emerge  gentoolkit
    emerge-webrsync
    emerge -uvDN $parallele_emerge world
    revdep-rebuild
    python-updater
    perl-cleaner --reallyall
}

