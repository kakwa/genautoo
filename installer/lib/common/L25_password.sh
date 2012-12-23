password_set_password(){
    #this function sets the root password
    #if no root password specified, the default
    #is "password"

    if [ -z $root_password ]
    then
        root_password="password"
    fi

    printf "$root_password\n$root_password\n"|passwd
}
