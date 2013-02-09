#!/bin/bash

###########
# Install Desktop system
#
#
####
# Functions
do_mount() {
    mkdir /target >$OUT 2>&1
    mount $TARGET"2" /target >$OUT 2>&1
    mkdir -p /target/boot >$OUT 2>&1
    mount $TARGET"1" /target/boot >$OUT 2>&1
}

do_umount() {
    umount /target/boot >$OUT 2>&1
    umount /target >$OUT 2>&1
}

check_mount() {
    grep -q "/target" /proc/mounts
    ret=$?
    if [ $ret -eq 0 ]; then
        grep -q "/target/boot" /proc/mounts
        ret=$?
        if [ $ret -eq 0 ]; then
            echo 0
        else
            echo 1
        fi
    else
        echo 1
    fi
}

usage() {
    cat <<EOF
    usage:$0 options
    
    OPTIONS:
    -t      Target disk  
    -h      This menu
    -v      Verbose
EOF
}
###
# Variables
TARGET=/dev/sdb
OUT=/dev/null

while getopts "t:hv" OPTION
do
    case $OPTION in
    t)
        TARGET=$OPTARG
        ;;
    h)
        usage
        exit 0
        ;;
    v)
        OUT=/dev/stdout
        ;;
    *)
        usage
        exit 0
        ;;
    esac
done
###
#  Main
if [[ ! -b $TARGET ]]; then
    echo "Target is not a block device."
    exit 1
fi
echo "Zeroing Disk first"
dd if=/dev/zero of=$TARGET bs=1M >$OUT 2>&1
echo "Done, Now creating partitions."
fdisk $TARGET >$OUT 2>&1 <<EOF
n
p
1
1
26
n
p
2
27
1950
w
EOF
echo "Created, Doing Filesystem."
mkfs $TARGET"1" >$OUT 2>&1
mkfs $TARGET"2" >$OUT 2>&1
echo "Created Filesystems."
echo "Creating target and mounting filesystem"
do_mount
ret=$(check_mount)
if [ $ret -eq 0 ]; then
    echo "Created target and mounted."
else
    echo "Mount failded for some reason."
fi

###### 
# Breaking down Environment
echo "Umounting filesystems"
do_umount
ret=$(check_mount)
if [ $ret -eq 1 ];then
    echo "Done umounting"
else
    echo "Umount unsuccesful."
fi
