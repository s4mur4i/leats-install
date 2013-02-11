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
#export INSTALL='rpm --root /target -i '
export INSTALL='rpm --root /target  --nodeps -vhi '

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
    exit 2
fi
echo "Installing packages."
rpm --root /target --rebuilddb
rpm --root /target --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6
$INSTALL  /rpm/setup-2.8.14-16.el6.noarch.rpm \
        /rpm/basesystem-10.0-4.el6.noarch.rpm \
        /rpm/filesystem-2.4.30-3.el6.x86_64.rpm

$INSTALL /rpm/bash-4.1.2-9.el6_2.x86_64.rpm \
        /rpm/glibc-2.12-1.80.el6_3.5.x86_64.rpm \
        /rpm/glibc-common-2.12-1.80.el6_3.5.x86_64.rpm \
        /rpm/libgcc-4.4.6-4.el6.x86_64.rpm \
        /rpm/tzdata-2012c-3.el6.noarch.rpm \
        /rpm/ncurses-libs-5.7-3.20090208.el6.x86_64.rpm \
        /rpm/nss-softokn-freebl-3.12.9-11.el6.x86_64.rpm \
        /rpm/libcap-2.16-5.5.el6.x86_64.rpm \
        /rpm/ncurses-base-5.7-3.20090208.el6.x86_64.rpm \
        /rpm/libattr-2.4.44-7.el6.x86_64.rpm

$INSTALL /rpm/ethtool-2.6.33-0.3.el6.x86_64.rpm \
        /rpm/gawk-3.1.7-9.el6.x86_64.rpm \
        /rpm/grep-2.6.3-3.el6.x86_64.rpm \
        /rpm/libstdc++-4.4.6-4.el6.x86_64.rpm \
        /rpm/ncurses-5.7-3.20090208.el6.x86_64.rpm \
        /rpm/info-4.13a-8.el6.x86_64.rpm \
        /rpm/pcre-7.8-4.el6.x86_64.rpm \
        /rpm/sed-4.2.1-10.el6.x86_64.rpm \
        /rpm/zlib-1.2.3-27.el6.x86_64.rpm \
        /rpm/libselinux-2.0.94-5.3.el6.x86_64.rpm \
        /rpm/libsepol-2.0.41-4.el6.x86_64.rpm

$INSTALL /rpm/coreutils-8.4-19.el6.x86_64.rpm \
		/rpm/coreutils-libs-8.4-19.el6.x86_64.rpm \
		/rpm/policycoreutils-2.0.83-19.24.el6.x86_64.rpm \
		/rpm/libselinux-utils-2.0.94-5.3.el6.x86_64.rpm \
		/rpm/libacl-2.2.49-6.el6.x86_64.rpm \
		/rpm/gnome-keyring-pam-2.28.2-7.el6.x86_64.rpm \
		/rpm/audit-libs-2.2-2.el6.x86_64.rpm \
		/rpm/cracklib-dicts-2.8.16-4.el6.x86_64.rpm \
		/rpm/cracklib-2.8.16-4.el6.x86_64.rpm \
		/rpm/cracklib-dicts-2.8.16-4.el6.x86_64.rpm \
		/rpm/libcap-ng-0.6.4-3.el6_0.1.x86_64.rpm \
		/rpm/chkconfig-1.3.49.3-2.el6.x86_64.rpm \
		/rpm/python-2.6.6-29.el6_3.3.x86_64.rpm \
		/rpm/db4-4.7.25-17.el6.x86_64.rpm \
		/rpm/db4-utils-4.7.25-17.el6.x86_64.rpm \
		/rpm/openssl-1.0.0-25.el6_3.1.x86_64.rpm \
		/rpm/readline-6.0-4.el6.x86_64.rpm \
		/rpm/bzip2-libs-1.0.5-7.el6_0.x86_64.rpm \
		/rpm/gdbm-1.8.0-36.el6.x86_64.rpm \
		/rpm/findutils-4.4.2-6.el6.x86_64.rpm \
		/rpm/krb5-libs-1.9-33.el6_3.3.x86_64.rpm \
		/rpm/util-linux-ng-2.17.2-12.7.el6.x86_64.rpm \
		/rpm/popt-1.13-7.el6.x86_64.rpm \
		/rpm/libudev-147-2.42.el6.x86_64.rpm \
		/rpm/udev-147-2.42.el6.x86_64.rpm \
		/rpm/MAKEDEV-3.24-6.el6.x86_64.rpm \
		/rpm/centos-release-6-3.el6.centos.9.x86_64.rpm \
		/rpm/shadow-utils-4.1.4.2-13.el6.x86_64.rpm \
		/rpm/keyutils-libs-1.4-4.el6.x86_64.rpm \
		/rpm/iproute-2.6.32-20.el6.x86_64.rpm \
		/rpm/net-tools-1.60-110.el6_2.x86_64.rpm \
		/rpm/e2fsprogs-1.41.12-12.el6.x86_64.rpm \
		/rpm/e2fsprogs-libs-1.41.12-12.el6.x86_64.rpm \
		/rpm/glib2-2.22.5-7.el6.x86_64.rpm \
		/rpm/mingetty-1.08-5.el6.x86_64.rpm \
		/rpm/device-mapper-1.02.74-10.el6.x86_64.rpm \
		/rpm/device-mapper-libs-1.02.74-10.el6.x86_64.rpm \
		/rpm/psmisc-22.6-15.el6_0.1.x86_64.rpm \
		/rpm/procps-3.2.8-23.el6.x86_64.rpm \
        /rpm/rsyslog-5.8.10-2.el6.x86_64.rpm \
		/rpm/iputils-20071127-16.el6.x86_64.rpm 

# libattr libsepol mcstrans   sysfsutils   sysklogd libsysfs  missing
#         /rpm/initscripts-9.03.31-2.el6.centos.1.x86_64.rpm \
#		/rpm/pam-1.1.1-10.el6_2.1.x86_64.rpm \
#        /rpm/sysvinit-tools-2.87-4.dsf.el6.x86_64.rpm \
#$INSTALL /rpm/coreutils-8.4-19.el6.x86_64.rpm \
#		/rpm/coreutils-libs-8.4-19.el6.x86_64.rpm \
#		/rpm/policycoreutils-2.0.83-19.24.el6.x86_64.rpm \
#		/rpm/policycoreutils-python-2.0.83-19.24.el6.x86_64.rpm \
#		/rpm/libselinux-2.0.94-5.3.el6.x86_64.rpm \
#		/rpm/libselinux-python-2.0.94-5.3.el6.x86_64.rpm \
#		/rpm/libselinux-utils-2.0.94-5.3.el6.x86_64.rpm \
#		/rpm/libacl-2.2.49-6.el6.x86_64.rpm \
#		/rpm/libattr-2.4.44-7.el6.x86_64.rpm \
#		/rpm/gnome-keyring-pam-2.28.2-7.el6.x86_64.rpm \
#		/rpm/pam-1.1.1-10.el6_2.1.x86_64.rpm \
#		/rpm/audit-libs-2.2-2.el6.x86_64.rpm \
#		/rpm/audit-libs-python-2.2-2.el6.x86_64.rpm \
#		/rpm/cracklib-dicts-2.8.16-4.el6.x86_64.rpm \
#		/rpm/cracklib-2.8.16-4.el6.x86_64.rpm \
#		/rpm/cracklib-dicts-2.8.16-4.el6.x86_64.rpm \
#		/rpm/libsepol-2.0.41-4.el6.x86_64.rpm \
#		/rpm/libcap-2.16-5.5.el6.x86_64.rpm \
#		/rpm/libcap-ng-0.6.4-3.el6_0.1.x86_64.rpm \
#		/rpm/chkconfig-1.3.49.3-2.el6.x86_64.rpm \
#		/rpm/audit-libs-python-2.2-2.el6.x86_64.rpm \
#		/rpm/dbus-python-0.83.0-6.1.el6.x86_64.rpm \
#		/rpm/gnome-python2-2.28.0-3.el6.x86_64.rpm \
#		/rpm/gnome-python2-applet-2.28.0-4.el6.x86_64.rpm \
#		/rpm/gnome-python2-bonobo-2.28.0-3.el6.x86_64.rpm \
#		/rpm/gnome-python2-canvas-2.28.0-3.el6.x86_64.rpm \
#		/rpm/gnome-python2-desktop-2.28.0-4.el6.x86_64.rpm \
#		/rpm/gnome-python2-extras-2.25.3-20.el6.x86_64.rpm \
#		/rpm/gnome-python2-gconf-2.28.0-3.el6.x86_64.rpm \
#		/rpm/gnome-python2-gnome-2.28.0-3.el6.x86_64.rpm \
#		/rpm/gnome-python2-gnomekeyring-2.28.0-4.el6.x86_64.rpm \
#		/rpm/gnome-python2-gnomevfs-2.28.0-3.el6.x86_64.rpm \
#		/rpm/gnome-python2-libegg-2.25.3-20.el6.x86_64.rpm \
#		/rpm/gtk-vnc-python-0.3.10-3.el6.x86_64.rpm \
#		/rpm/libproxy-python-0.3.0-2.el6.x86_64.rpm \
#		/rpm/libselinux-python-2.0.94-5.3.el6.x86_64.rpm \
#		/rpm/libsemanage-python-2.0.43-4.1.el6.x86_64.rpm \
#		/rpm/libvirt-python-0.9.10-21.el6_3.4.x86_64.rpm \
#		/rpm/libxml2-python-2.7.6-8.el6_3.3.x86_64.rpm \
#		/rpm/newt-python-0.52.11-3.el6.x86_64.rpm \
#		/rpm/policycoreutils-python-2.0.83-19.24.el6.x86_64.rpm \
#		/rpm/python-2.6.6-29.el6_3.3.x86_64.rpm \
#		/rpm/python-deltarpm-3.5-0.5.20090913git.el6.x86_64.rpm \
#		/rpm/python-iniparse-0.3.1-2.1.el6.noarch.rpm \
#		/rpm/python-libs-2.6.6-29.el6_3.3.x86_64.rpm \
#		/rpm/python-pycurl-7.19.0-8.el6.x86_64.rpm \
#		/rpm/python-urlgrabber-3.9.1-8.el6.noarch.rpm \
#		/rpm/python-virtinst-0.600.0-8.el6.noarch.rpm \
#		/rpm/rpm-python-4.8.0-27.el6.x86_64.rpm \
#		/rpm/setools-libs-python-3.3.7-4.el6.x86_64.rpm \
#		/rpm/spice-gtk-python-0.11-11.el6_3.1.x86_64.rpm \
#		/rpm/db4-4.7.25-17.el6.x86_64.rpm \
#		/rpm/db4-utils-4.7.25-17.el6.x86_64.rpm \
#		/rpm/openssl-1.0.0-25.el6_3.1.x86_64.rpm \
#		/rpm/readline-6.0-4.el6.x86_64.rpm \
#		/rpm/bzip2-libs-1.0.5-7.el6_0.x86_64.rpm \
#		/rpm/gdbm-1.8.0-36.el6.x86_64.rpm \
#		/rpm/findutils-4.4.2-6.el6.x86_64.rpm \
#		/rpm/krb5-libs-1.9-33.el6_3.3.x86_64.rpm \
#		/rpm/initscripts-9.03.31-2.el6.centos.1.x86_64.rpm \
#		/rpm/util-linux-ng-2.17.2-12.7.el6.x86_64.rpm \
#		/rpm/popt-1.13-7.el6.x86_64.rpm \
#		/rpm/libgudev1-147-2.42.el6.x86_64.rpm \
#		/rpm/libudev-147-2.42.el6.x86_64.rpm \
#		/rpm/udev-147-2.42.el6.x86_64.rpm \
#		/rpm/MAKEDEV-3.24-6.el6.x86_64.rpm \
#		/rpm/centos-release-6-3.el6.centos.9.x86_64.rpm \
#		/rpm/shadow-utils-4.1.4.2-13.el6.x86_64.rpm \
#		/rpm/keyutils-libs-1.4-4.el6.x86_64.rpm \
#		/rpm/iproute-2.6.32-20.el6.x86_64.rpm \
#		/rpm/net-tools-1.60-110.el6_2.x86_64.rpm \
#		/rpm/module-init-tools-3.9-20.el6.x86_64.rpm \
#		/rpm/e2fsprogs-1.41.12-12.el6.x86_64.rpm \
#		/rpm/e2fsprogs-libs-1.41.12-12.el6.x86_64.rpm \
#		/rpm/e2fsprogs-libs-1.41.12-12.el6.x86_64.rpm \
#		/rpm/glib2-2.22.5-7.el6.x86_64.rpm \
#		/rpm/pulseaudio-libs-glib2-0.9.21-14.el6_3.x86_64.rpm \
#		/rpm/mingetty-1.08-5.el6.x86_64.rpm \
#		/rpm/device-mapper-1.02.74-10.el6.x86_64.rpm \
#		/rpm/device-mapper-event-1.02.74-10.el6.x86_64.rpm \
#		/rpm/device-mapper-event-libs-1.02.74-10.el6.x86_64.rpm \
#		/rpm/device-mapper-libs-1.02.74-10.el6.x86_64.rpm \
#		/rpm/device-mapper-multipath-0.4.9-56.el6_3.1.x86_64.rpm \
#		/rpm/device-mapper-multipath-libs-0.4.9-56.el6_3.1.x86_64.rpm \
#		/rpm/psmisc-22.6-15.el6_0.1.x86_64.rpm \
#		/rpm/procps-3.2.8-23.el6.x86_64.rpm \
#		/rpm/iputils-20071127-16.el6.x86_64.rpm 

######
# Note to self.
# echo "what" | sed 's/ /\
# /g' | xargs -n 1 grep desktop_rpm -e
###### 
# Breaking down Environment
echo "Umounting filesystems"
do_umount
ret=$(check_mount)
if [ $ret -eq 1 ];then
    echo "Done umounting"
else
    echo "Umount unsuccesful."
    exit 2
fi


