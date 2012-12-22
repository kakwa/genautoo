#this lib handle the partitionning of the disks

partitionning_get_disks_list(){
    #this function just give the list of the devices
    #$1 the cleaned list of partition
    local input_file=$1

    tmp=`mktemp`
    while read -r line
    do
       device=`echo $line |cut -d ' ' -f 1` 
       if ! grep -q "^$device$" $tmp
       then
           echo $device >>$tmp
       fi
    done < $input_file
    DEVICE_LIST=`cat $tmp|uniq`
    rm $tmp
}

partitionning_partitionning(){
    #this script create the partition
    #$1 -> the partionning file
    local input_file=$1
    local CLEANED_PARTIONS_FILE=`mktemp`
    common_cleanup_file $input_file  $CLEANED_PARTIONS_FILE

    local partitionning_dir_script=`mktemp -d`
    arch_partitionning_create_script $CLEANED_PARTIONS_FILE $partitionning_dir_script
    chmod -R 755 $partitionning_dir_script
    cd $partitionning_dir_script
    for s in `ls`
    do
        ./$s
    done
    cd -
}


#. ../arch/i686/A04_partionning.sh

#partitionning_partitionning $1
