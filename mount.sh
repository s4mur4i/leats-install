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
    mount --bind /dev /target/dev >$OUT 2>&1
    mount -t proc none /target/proc >$OUT 2>&1
    mount -t sysfs none /target/sys >$OUT 2>&1
}

do_umount() {
    umount /target/dev >$OUT 2>&1
    umount /target/proc >$OUT 2>&1
    umount /target/sys >$OUT 2>&1
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
    -m      Mount
    -u      Umount
EOF
}
###
# Variables
TARGET=/dev/sdb
OUT=/dev/null
MOUNT="unknown"

while getopts "t:hvmu" OPTION
do
    case $OPTION in
    t)
        TARGET=$OPTARG
        ;;
    m)
        MOUNT="m"
        ;;
    u)
        MOUNT="u"
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
case $MOUNT in
    m)
        do_mount
        ;;
    u)
        do_umount
        ;;
    *)
        echo "Unknown Mount order."
        ;;
esac

