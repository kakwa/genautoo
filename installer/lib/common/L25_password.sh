password_set_password(){
    if [ -z $root_password ]
    then
        root_password="password"
    fi

    printf "$root_password\n$root_password\n"|passwd
}
