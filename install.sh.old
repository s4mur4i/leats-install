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
EOF
}
###
# Variables
TARGET=/dev/sdb
OUT=/dev/null
export INSTALL='rpm --root /target -vhi '
#export INSTALL='rpm --root /target  --nodeps -vhi '

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
echo "Pretest if target mounted"
ret=$(check_mount)
if [ $ret -eq 1 ]; then
    echo "Not mounted continue."
else
    echo "Target mounted, umounting."
    do_umount
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

### /var/lib/random-seed needed  for initscripts
mkdir -p /target/var/lib
cp /var/lib/random-seed /target/var/lib/random-seed
$INSTALL /rpm/coreutils-8.4-19.el6.x86_64.rpm \
		/rpm/coreutils-libs-8.4-19.el6.x86_64.rpm \
		/rpm/policycoreutils-2.0.83-19.24.el6.x86_64.rpm \
		/rpm/libselinux-utils-2.0.94-5.3.el6.x86_64.rpm \
		/rpm/libacl-2.2.49-6.el6.x86_64.rpm \
		/rpm/audit-libs-2.2-2.el6.x86_64.rpm \
        /rpm/python-libs-2.6.6-29.el6_3.3.x86_64.rpm \
        /rpm/ca-certificates-2010.63-3.el6_1.5.noarch.rpm \
        /rpm/sysvinit-tools-2.87-4.dsf.el6.x86_64.rpm \
		/rpm/cracklib-dicts-2.8.16-4.el6.x86_64.rpm \
        /rpm/nss-softokn-3.12.9-11.el6.x86_64.rpm \
        /rpm/lua-5.1.4-4.1.el6.x86_64.rpm \
        /rpm/less-436-10.el6.x86_64.rpm \
        /rpm/gamin-0.1.10-9.el6.x86_64.rpm \
        /rpm/hwdata-0.233-7.8.el6.noarch.rpm \
        /rpm/nss-sysinit-3.13.5-1.el6_3.x86_64.rpm \
        /rpm/nss-tools-3.13.5-1.el6_3.x86_64.rpm \
        /rpm/nss-util-3.13.5-1.el6_3.x86_64.rpm \
		/rpm/cracklib-2.8.16-4.el6.x86_64.rpm \
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
        /rpm/gmp-4.3.1-7.el6_2.2.x86_64.rpm \
        /rpm/pam-1.1.1-10.el6_2.1.x86_64.rpm \
        /rpm/initscripts-9.03.31-2.el6.centos.1.x86_64.rpm \
        /rpm/diffutils-2.8.1-28.el6.x86_64.rpm \
        /rpm/checkpolicy-2.0.22-1.el6.x86_64.rpm \
        /rpm/expat-2.0.1-11.el6_2.x86_64.rpm \
		/rpm/iputils-20071127-16.el6.x86_64.rpm \
        /rpm/rpm-4.8.0-27.el6.x86_64.rpm \
        /rpm/elfutils-libelf-0.152-1.el6.x86_64.rpm \
        /rpm/rpm-libs-4.8.0-27.el6.x86_64.rpm \
        /rpm/gzip-1.3.12-18.el6.x86_64.rpm \
        /rpm/libutempter-1.1.5-4.1.el6.x86_64.rpm \
        /rpm/libblkid-2.17.2-12.7.el6.x86_64.rpm \
        /rpm/libcom_err-1.41.12-12.el6.x86_64.rpm \
        /rpm/nss-3.13.5-1.el6_3.x86_64.rpm \
        /rpm/libuuid-2.17.2-12.7.el6.x86_64.rpm \
        /rpm/libsemanage-2.0.43-4.1.el6.x86_64.rpm \
        /rpm/dbus-glib-0.86-5.el6.x86_64.rpm \
        /rpm/libffi-3.0.5-3.2.el6.x86_64.rpm \
        /rpm/curl-7.19.7-26.el6_2.4.x86_64.rpm \
        /rpm/libcurl-7.19.7-26.el6_2.4.x86_64.rpm \
        /rpm/dbus-libs-1.2.24-7.el6_3.x86_64.rpm \
        /rpm/nspr-4.9.1-2.el6_3.x86_64.rpm \
        /rpm/groff-1.18.1.4-21.el6.x86_64.rpm \
        /rpm/module-init-tools-3.9-20.el6.x86_64.rpm \
        /rpm/libusb-0.1.12-23.el6.x86_64.rpm \
        /rpm/iptables-1.4.7-5.1.el6_2.x86_64.rpm \
        /rpm/libss-1.41.12-12.el6.x86_64.rpm \
        /rpm/libssh2-1.2.2-11.el6_3.x86_64.rpm \
        /rpm/ustr-1.0.4-9.1.el6.x86_64.rpm \
        /rpm/libidn-1.18-2.el6.x86_64.rpm \
        /rpm/logrotate-3.7.8-15.el6.x86_64.rpm \
        /rpm/cpio-2.10-10.el6.x86_64.rpm \
        /rpm/libnih-1.0.1-7.el6.x86_64.rpm \
        /rpm/cyrus-sasl-lib-2.1.23-13.el6.x86_64.rpm \
        /rpm/upstart-0.6.5-12.el6.x86_64.rpm \
        /rpm/xz-libs-4.999.9-0.3.beta.20091007git.el6.x86_64.rpm \
        /rpm/file-libs-5.04-13.el6.x86_64.rpm \
        /rpm/openldap-2.4.23-26.el6_3.2.x86_64.rpm \
        /rpm/binutils-2.20.51.0.2-5.34.el6.x86_64.rpm \
        /rpm/sqlite-3.6.20-1.el6.x86_64.rpm

$INSTALL /rpm/yum-3.2.29-30.el6.centos.noarch.rpm \
		/rpm/yum-metadata-parser-1.1.2-16.el6.x86_64.rpm \
		/rpm/yum-plugin-fastestmirror-1.1.30-14.el6.noarch.rpm \
		/rpm/yum-presto-0.6.2-1.el6.noarch.rpm \
		/rpm/rpm-python-4.8.0-27.el6.x86_64.rpm \
		/rpm/libxml2-2.7.6-8.el6_3.3.x86_64.rpm \
		/rpm/libxml2-python-2.7.6-8.el6_3.3.x86_64.rpm \
		/rpm/python-urlgrabber-3.9.1-8.el6.noarch.rpm \
        /rpm/pygpgme-0.1-18.20090824bzr68.el6.x86_64.rpm \
        /rpm/gpgme-1.1.8-3.el6.x86_64.rpm \
        /rpm/gnupg2-2.0.14-4.el6.x86_64.rpm \
        /rpm/libgpg-error-1.7-4.el6.x86_64.rpm \
        /rpm/pth-2.0.7-9.3.el6.x86_64.rpm \
        /rpm/deltarpm-3.5-0.5.20090913git.el6.x86_64.rpm \
        /rpm/python-pycurl-7.19.0-8.el6.x86_64.rpm \
        /rpm/libgcrypt-1.4.5-9.el6_2.2.x86_64.rpm \
        /rpm/pinentry-0.7.6-6.el6.x86_64.rpm \
		/rpm/python-iniparse-0.3.1-2.1.el6.noarch.rpm
		
$INSTALL /rpm/rootfiles-8.1-6.1.el6.noarch.rpm \
        /rpm/file-libs-5.04-13.el6.x86_64.rpm
echo "Done installing base rpm-s."
chroot /target pwconv
echo "Installing further packages."
$INSTALL /rpm/device-mapper-event-1.02.74-10.el6.x86_64.rpm \
		/rpm/device-mapper-event-libs-1.02.74-10.el6.x86_64.rpm \
		/rpm/device-mapper-multipath-0.4.9-56.el6_3.1.x86_64.rpm \
		/rpm/device-mapper-multipath-libs-0.4.9-56.el6_3.1.x86_64.rpm \
		/rpm/dracut-kernel-004-284.el6_3.noarch.rpm \
		/rpm/kernel-2.6.32-279.9.1.el6.x86_64.rpm \
		/rpm/kernel-2.6.32-279.el6.x86_64.rpm \
		/rpm/kernel-firmware-2.6.32-279.9.1.el6.noarch.rpm \
		/rpm/kpartx-0.4.9-56.el6_3.1.x86_64.rpm \
		/rpm/lvm2-2.02.95-10.el6.x86_64.rpm \
		/rpm/lvm2-libs-2.02.95-10.el6.x86_64.rpm \
		/rpm/selinux-policy-targeted-3.7.19-155.el6_3.4.noarch.rpm \
		/rpm/startup-notification-0.10-2.1.el6.x86_64.rpm \
        /rpm/libaio-0.3.107-10.el6.x86_64.rpm \
        /rpm/dracut-004-284.el6_3.noarch.rpm \
        /rpm/dracut-kernel-004-284.el6_3.noarch.rpm \
        /rpm/dracut-network-004-284.el6_3.noarch.rpm \
        /rpm/grubby-7.0.15-3.el6.x86_64.rpm \
        /rpm/libselinux-python-2.0.94-5.3.el6.x86_64.rpm \
        /rpm/libselinux-utils-2.0.94-5.3.el6.x86_64.rpm \
        /rpm/selinux-policy-3.7.19-155.el6_3.4.noarch.rpm \
        /rpm/selinux-policy-targeted-3.7.19-155.el6_3.4.noarch.rpm \
        /rpm/bridge-utils-1.2-9.el6.x86_64.rpm \
        /rpm/bzip2-1.0.5-7.el6_0.x86_64.rpm \
        /rpm/bzip2-libs-1.0.5-7.el6_0.x86_64.rpm \
        /rpm/ConsoleKit-x11-0.4.1-3.el6.x86_64.rpm \
        /rpm/control-center-filesystem-2.28.1-37.el6.x86_64.rpm \
        /rpm/dash-0.5.5.1-3.1.el6.x86_64.rpm \
        /rpm/dbus-x11-1.2.24-7.el6_3.x86_64.rpm \
        /rpm/desktop-file-utils-0.15-9.el6.x86_64.rpm \
        /rpm/DeviceKit-power-014-3.el6.x86_64.rpm \
        /rpm/device-mapper-1.02.74-10.el6.x86_64.rpm \
        /rpm/device-mapper-event-1.02.74-10.el6.x86_64.rpm \
        /rpm/device-mapper-event-libs-1.02.74-10.el6.x86_64.rpm \
        /rpm/device-mapper-libs-1.02.74-10.el6.x86_64.rpm \
        /rpm/device-mapper-multipath-0.4.9-56.el6_3.1.x86_64.rpm \
        /rpm/device-mapper-multipath-libs-0.4.9-56.el6_3.1.x86_64.rpm \
        /rpm/dhclient-4.1.1-31.0.1.P1.el6.centos.1.x86_64.rpm \
        /rpm/file-5.04-13.el6.x86_64.rpm \
        /rpm/file-libs-5.04-13.el6.x86_64.rpm \
        /rpm/iscsi-initiator-utils-6.2.0.872-41.el6.x86_64.rpm \
        /rpm/kbd-1.15-11.el6.x86_64.rpm \
        /rpm/kbd-misc-1.15-11.el6.noarch.rpm \
        /rpm/libgnomekbd-2.28.2-2.el6.x86_64.rpm \
        /rpm/libsndfile-1.0.20-5.el6.x86_64.rpm \
        /rpm/libxcb-1.5-1.el6.x86_64.rpm \
        /rpm/libxkbfile-1.0.6-1.1.el6.x86_64.rpm \
        /rpm/m4-1.4.13-5.el6.x86_64.rpm \
        /rpm/nfs-utils-1.2.3-26.el6.x86_64.rpm \
        /rpm/nfs-utils-lib-1.1.5-4.el6.x86_64.rpm \
        /rpm/plymouth-0.8.3-24.el6.centos.x86_64.rpm \
        /rpm/plymouth-core-libs-0.8.3-24.el6.centos.x86_64.rpm \
        /rpm/plymouth-gdm-hooks-0.8.3-24.el6.centos.x86_64.rpm \
        /rpm/plymouth-scripts-0.8.3-24.el6.centos.x86_64.rpm \
        /rpm/plymouth-utils-0.8.3-24.el6.centos.x86_64.rpm \
        /rpm/rootfiles-8.1-6.1.el6.noarch.rpm \
        /rpm/rpcbind-0.2.0-9.el6.x86_64.rpm \
        /rpm/spice-glib-0.11-11.el6_3.1.x86_64.rpm \
        /rpm/spice-gtk-0.11-11.el6_3.1.x86_64.rpm \
        /rpm/spice-gtk-python-0.11-11.el6_3.1.x86_64.rpm \
        /rpm/spice-server-0.10.1-10.el6.x86_64.rpm \
        /rpm/which-2.19-6.el6.x86_64.rpm \
        /rpm/xcb-util-0.3.6-1.el6.x86_64.rpm \
        /rpm/xorg-x11-drv-evdev-2.6.0-2.el6.x86_64.rpm \
        /rpm/xorg-x11-drv-vesa-2.3.0-2.el6.x86_64.rpm \
        /rpm/xorg-x11-drv-void-1.4.0-1.el6.x86_64.rpm \
        /rpm/xorg-x11-drv-wacom-0.13.0-6.el6.x86_64.rpm \
        /rpm/xorg-x11-fonts-misc-7.2-9.1.el6.noarch.rpm \
        /rpm/xorg-x11-fonts-Type1-7.2-9.1.el6.noarch.rpm \
        /rpm/xorg-x11-font-utils-7.2-11.el6.x86_64.rpm \
        /rpm/xorg-x11-server-common-1.10.6-1.el6.centos.x86_64.rpm \
        /rpm/xorg-x11-server-utils-7.5-5.2.el6.x86_64.rpm \
        /rpm/xorg-x11-server-Xorg-1.10.6-1.el6.centos.x86_64.rpm \
        /rpm/xorg-x11-xauth-1.0.2-7.1.el6.x86_64.rpm \
        /rpm/xorg-x11-xinit-1.0.9-13.el6.x86_64.rpm \
        /rpm/xorg-x11-xkb-utils-7.4-6.el6.x86_64.rpm \
		/rpm/tar-1.23-7.el6.x86_64.rpm
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


