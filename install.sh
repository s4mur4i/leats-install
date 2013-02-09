#!/bin/bash

###########
# Install Desktop system
#
#
####
# Functions

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
echo "Checking target"
mkdir -p /target/boot

