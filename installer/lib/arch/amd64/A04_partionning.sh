#this lib handles the partitionning

arch_partitionning_create_script(){
    #this script generate the partitionning script
    #$1 -> the partionning file
    #$2 -> the dir where the partionning scripts are put 

    input_file=$1
    partitionning_dir_script=$2
    partitionning_cleanup $input_file
    partitionning_get_disks_list $CLEANED_PARTIONS_FILE

    for d in $DEVICE_LIST
    do
        partition_of_current_disk=`mktemp`
        cat $CLEANED_PARTIONS_FILE |grep "^$d" >$partition_of_current_disk
        script=$partitionning_dir_script/`basename $d`
        echo "fdisk $d <<EOF" >>$script
#        echo "o" >>$script #doesn't work with fdisk from the busybox
        # We delete all the primary partitions (even if they don't exist)
        echo "d" >>$script
        echo "1" >>$script
        echo "d" >>$script
        echo "2" >>$script
        echo "d" >>$script
        echo "3" >>$script
        echo "d" >>$script
        echo "4" >>$script
        # we create an extended partition
        echo "n" >>$script
        echo "e" >>$script
        echo "1" >>$script
        echo "" >>$script
        echo "" >>$script

        #for each declared partition we add "n\nl\n\n<SIZE>"
        #adding a new partition
        #logical one
        #starting where the last one stop
        #ending at +<SIZE> (if ALL, it takes the rest of the disk)
        while read line
        do
            size=`echo $line |cut -d ' ' -f2`
            if [ $size = "ALL" ]
            then
                size=""
            else
                size="+$size"
            fi
            echo "n" >>$script
            echo "l" >>$script
            echo "" >>$script
            echo "$size" >>$script
     
        done < $partition_of_current_disk
     
        echo "w" >>$script
        echo "EOF" >>$script
    done
        
}    
