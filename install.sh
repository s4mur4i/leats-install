#!/bin/bash
#### Linux from scratch install script

check_mount() {
    grep -q $LFS /proc/mounts
    ret=$?
    if [ $ret -eq 0 ]; then
	echo 0
    else
        echo 1
    fi
}

do_umount() {
	for i in `mount |grep '/mnt/lfs/dev/' |awk '{print $3}'` ; do umount -f $i >$OUT 2>&1 ; done
	for i in `mount |grep '/mnt/lfs/' |awk '{print $3}'` ; do umount -f $i >$OUT 2>&1 ; done
	umount -l $LFS >$OUT 2>&1
}

usage() {
    cat <<EOF
	usage:$0 options
	OPTIONS:
	-t Target disk
	-h This menu
	-v Verbose
EOF
}

###
# Variables
TARGET=/dev/sdb
OUT=/dev/null
LFS=/mnt/lfs
BASE=`dirname $0`
RPM=/mnt/rpm

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
# For debugging and error handling
set -e

# Since we are testing we need to umount previous swaps
swapoff ${TARGET}2 || echo "No swap found from previous build."
###
# Main
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
dd if=/dev/zero of=$TARGET bs=1M >$OUT 2>&1 || echo "DD found not round block."
echo "Done, Now creating partitions."
max=`sfdisk -lsuM $TARGET 2>/dev/null | head -1`
max=$(((($max/1024)/1024)))
if [ $max -gt 12 ] ;then
	(fdisk $TARGET >$OUT 2>&1 <<EOF
	n
	p
	1

	+10G
	a
	1
	n
	p
	2

	+2G
	t
	2
	82
	w
EOF
	) || partprobe
else
	echo "Need more space"
	exit 1
fi
echo "Created, Doing Filesystem."
mkfs.ext3 ${TARGET}1 >$OUT 2>&1
mkswap ${TARGET}2 >$OUT 2>&1
swapon -v ${TARGET}2 >$OUT 2>&1
echo "Creating LFS directories"
mkdir -pv $LFS >$OUT 2>&1
mount -v -t ext3 ${TARGET}1 $LFS >$OUT 2>&1
echo "Mounted partitions"
$BASE/packages.sh
mkdir -pv $LFS/var/tmp/chroot/var/lib/rpm
rpm --rebuilddb --root=$LFS
rpm -i --root=$LFS --nodeps $RPM/centos-release-6-3.el6.centos.9.x86_64.rpm
mkdir -pv $LFS/repo
createrepo $LFS/repo
cp $RPM/* $LFS/repo
echo "[localrepo]
name=RPM for installing
baseurl=file://$LFS/repo/
enabled=1
gpgcheck=0" > $LFS/etc/yum.repos.d/local.repo
createrepo $LFS/repo
yum --installroot=$LFS --disablerepo=* --enablerepo=localrepo clean all
yum --installroot=$LFS install --disablerepo=* --enablerepo=localrepo -y rpm-build yum
echo "Finished base system"
mkdir -pv $LFS/proc
mkdir -pv $LFS/dev
mount --bind /proc $LFS/proc
mount --bind /dev $LFS/dev
cp /etc/resolv.conf $LFS/etc/resolv.conf
echo "Get the list of required packages"
#PACKAGE=`cat $BASE/desktop_list | xargs echo`
#yum --installroot=$LFS install -y $PACKAGE
#grub-install $TARGET
### Create some required files
echo "/dev/sda1 /	ext4	defaults	1 1
/dev/sda2 swap                    swap    defaults        0 0
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
sysfs                   /sys                    sysfs   defaults        0 0
proc                    /proc                   proc    defaults        0 0

" > $LFS/etc/fstab
RPM=`ls -1 $RPM/*.rpm | xargs echo`
rpm -iv --replacepkgs --root=$LFS --nodeps $RPM
echo "(hd0)	/dev/sda" >$LFS/boot/grub/device.map
echo -e "default=0\n
timeout=5\n
splashimage=(hd0,0)/boot/grub/splash.xpm.gz\n
hiddenmenu\n
title CentOS (2.6.32-279.el6.x86_64)\n
\troot (hd0,0)\n
\tkernel /boot/vmlinuz-2.6.32-279.9.1.el6.x86_64 ro root=/dev/sda1 rdshell\n
\tinitrd /boot/initramfs-2.6.32-279.9.1.el6.x86_64.img\n" >$LFS/boot/grub/grub.conf
grub-install --recheck --root-directory=$LFS $TARGET
## Set selinux
echo "SELINUX=disabled
SELINUXTYPE=targeted" > $LFS/etc/selinux/config
chroot $LFS mkinitrd -f --with=sd_mod --with=libata /boot/initrd-2.6.32-279.9.1.el6.x86_64.img 2.6.32-279.9.1.el6.x86_64
