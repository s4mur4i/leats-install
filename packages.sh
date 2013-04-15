#!/bin/bash
yum install -y createrepo >/dev/null 2>&1
rm -rf /mnt/repo || echo "Repo doesn't exist to delete"
MIRROR=http://mirror.centos.org/centos-6/6.3/os/x86_64/Packages
UPDATES=http://mirror.centos.org/centos-6/6.3/updates/x86_64/Packages
BASE=`dirname $0`
DEST=/mnt/rpm
mkdir -pv $DEST
rm $DEST/log >/dev/null 2>&1 || echo "No previous logs found"
rm $DEST/error >/dev/null 2>&1 || echo "No previous errors found"
for RPM in `cat $BASE/desktop_list`; do
	if [[ $RPM == \#* ]] ; 
	then
		continue
	fi
	wget -nv -A.rpm -nc -P $DEST "$MIRROR/$RPM.rpm" >>$DEST/log 2>&1
	ret=$?
	if [ $ret -ne 0 ]; then
		wget -nv -A.rpm -nc -P $DEST "$UPDATES/$RPM.rpm" >>$DEST/log 2>&1
		ret=$?
		    if [ $ret -ne 0 ]; then
				echo "Error Downloading a package: $RPM" >>$DEST/error 2>&1
			fi
	fi
done
wget -nv -A.rpm -nc -P $DEST http://mirror.centos.org/centos-6/6.3/os/x86_64/RPM-GPG-KEY-CentOS-6
#mkdir -pv /mnt/repo
#createrepo /mnt/repo
#cp /mnt/rpm/* /mnt/repo
#echo "[localrepo]
#name=RPM for installing
#baseurl=file:///mnt/repo/
#enabled=1
#gpgcheck=0" > /etc/yum.repos.d/local.repo
