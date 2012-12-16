
arch_formatting_get_partitions(){
    device=$1
    fdisk -l $device|grep "^$device"|grep -v "Extended"|cut -d ' ' -f1
}
