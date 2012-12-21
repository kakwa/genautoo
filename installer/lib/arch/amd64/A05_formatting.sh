
arch_formatting_get_partitions(){
    #this function gives the partition to format on a given disk
    #this listing is in the same order that the configuration file
    #the device to scan

    local device=$1

    fdisk -l $device|grep "^$device"|grep -v "Extended"|cut -d ' ' -f1
}
