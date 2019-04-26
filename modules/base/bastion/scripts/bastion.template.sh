#!/bin/bash

# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

yum update --security

sed -i -e "s/autoinstall\s=\sno/# autoinstall = yes/g" /etc/uptrack/uptrack.conf

uptrack-upgrade

touch /etc/modprobe.d/blacklist-filesystems.conf
echo "blacklist cramfs" >> /etc/modprobe.d/blacklist-filesystems.conf
echo "blacklist freevxfs" >> /etc/modprobe.d/blacklist-filesystems.conf
echo "blacklist jffs2" >> /etc/modprobe.d/blacklist-filesystems.conf
echo "blacklist hfs" >> /etc/modprobe.d/blacklist-filesystems.conf
echo "blacklist hfsplus" >> /etc/modprobe.d/blacklist-filesystems.conf
echo "blacklist squashfs" >> /etc/modprobe.d/blacklist-filesystems.conf
echo "blacklist udf" >> /etc/modprobe.d/blacklist-filesystems.conf

rmmod cramfs freevxfs jffs2 hfs hfsplus squashfs udf 

sed -i -e "s/Options=mode=1777,strictatime/Options=mode=1777,strictatime,noexec,nodev,nosuid/g" /etc/systemd/system/local-fs.target.wants/tmp.mount
mount -o remount,nodev /tmp
mount -o remount,nosuid /tmp
mount -o remount,noexec /tmp

yum install -y aide
aide --init 
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

echo "0 5 * * 5 root /usr/sbin/aide --update" >> /etc/crontab

echo "0 6 * * 5 root mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz" >> /etc/crontab

echo "0 2 * * * root /usr/sbin/aide --check" >> /etc/crontab

echo "* hard core 0" >> /etc/security/limits.conf
echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf
sysctl -w fs.suid_dumpable=0

ntpdate 169.254.169.254
sed -i -e "s/server\s0.rhel.pool.ntp.org\siburst/# server 0.rhel.pool.ntp.org iburst/g" /etc/ntp.conf
sed -i -e "s/server\s1.rhel.pool.ntp.org\siburst/# server 1.rhel.pool.ntp.org iburst/g" /etc/ntp.conf
sed -i -e "s/server\s2.rhel.pool.ntp.org\siburst/# server 2.rhel.pool.ntp.org iburst/g" /etc/ntp.conf
sed -i -e "s/server\s3.rhel.pool.ntp.org\siburst/# server 3.rhel.pool.ntp.org iburst\nserver 169.254.169.254 iburst/g" /etc/ntp.conf

systemctl enable ntpd
systemctl start ntpd

systemctl stop chronyd
systemctl disable chronyd

systemctl disable rpcbind

sed -i -e "s/inet_interfaces\s=\slocalhost/inet_interfaces = loopback-only/g" /etc/postfix/main.cf
systemctl stop postfix.service
systemctl disable postfix.service

echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf
sysctl -w net.ipv4.ip_forward=0

echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.conf
sysctl -w net.ipv4.conf.all.send_redirects=0 
sysctl -w net.ipv4.conf.default.send_redirects=0

echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.conf
sysctl -w net.ipv4.conf.all.accept_source_route=0
sysctl -w net.ipv4.conf.default.accept_source_route=0


echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.conf
sysctl -w net.ipv4.conf.all.accept_redirects=0 
sysctl -w net.ipv4.conf.default.accept_redirects=0

echo "net.ipv4.conf.all.secure_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.secure_redirects = 0" >> /etc/sysctl.conf
sysctl -w net.ipv4.conf.all.secure_redirects=0
sysctl -w net.ipv4.conf.default.secure_redirects=0

echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.log_martians = 1" >> /etc/sysctl.conf
sysctl -w net.ipv4.conf.all.log_martians=1
sysctl -w net.ipv4.conf.default.log_martians=1

echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf
sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1

echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.conf
sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1

echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter = 1" >> /etc/sysctl.conf

echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
sysctl -w net.ipv4.tcp_syncookies=1

sysctl -w net.ipv4.route.flush=1

echo "net.ipv6.conf.all.accept_ra = 0" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.accept_ra = 0" >> /etc/sysctl.conf
sysctl -w net.ipv6.conf.all.accept_ra=0
sysctl -w net.ipv6.conf.default.accept_ra=0

echo "net.ipv6.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.accept_redirects = 0" >> /etc/sysctl.conf
sysctl -w net.ipv6.conf.all.accept_redirects=0 
sysctl -w net.ipv6.conf.default.accept_redirects=0

sysctl -w net.ipv6.route.flush=1

touch /etc/modprobe.d/blacklist-protocols.conf
echo "blacklist sctp" >> /etc/modprobe.d/blacklist-protocols.conf
echo "blacklist rds" >> /etc/modprobe.d/blacklist-protocols.conf
echo "blacklist tipc" >> /etc/modprobe.d/blacklist-protocols.conf

echo "max_log_file = 20MB" >> /etc/audit/auditd.conf

echo "$FileCreateMode 0640" >> /etc/rsyslog.conf

chown root:root /etc/cron.hourly
chmod og-rwx /etc/cron.hourly

chown root:root /etc/cron.daily
chmod og-rwx /etc/cron.daily

chown root:root /etc/cron.weekly
chmod og-rwx /etc/cron.weekly

chown root:root /etc/cron.monthly
chmod og-rwx /etc/cron.monthly

chown root:root /etc/cron.d
chmod og-rwx /etc/cron.d

rm -f /etc/cron.deny
rm -f /etc/at.deny 
touch /etc/cron.allow
touch /etc/at.allow
chmod og-rwx /etc/cron.allow
chmod og-rwx /etc/at.allow
chown root:root /etc/cron.allow
chown root:root /etc/at.allow

echo "Protocol 2" >> /etc/ssh/sshd_config
sed -i -e "s/#LogLevel\sINFO/LogLevel INFO/g" /etc/ssh/sshd_config
sed -i -e "s/X11Forwarding\syes/X11Forwarding no/g" /etc/ssh/sshd_config
sed -i -e "s/#MaxAuthTries\s6/MaxAuthTries 3/g" /etc/ssh/sshd_config
sed -i -e "s/#IgnoreRhosts\syes/IgnoreRhosts yes/g" /etc/ssh/sshd_config
sed -i -e "s/#HostbasedAuthentication\sno/HostbasedAuthentication no/g" /etc/ssh/sshd_config
sed -i -e "s/#PermitEmptyPasswords\sno/PermitEmptyPasswords no/g" /etc/ssh/sshd_config
sed -i -e "s/#PermitUserEnvironment\sno/PermitUserEnvironment no/g" /etc/ssh/sshd_config
echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 100" >> /etc/ssh/sshd_config
echo "LoginGraceTime 60" >> /etc/ssh/sshd_config
systemctl reload sshd

sed -i -e "s/minlen\s=\s8/minlen = 14/g" /etc/security/pwquality.conf
sed -i -e "s/password\s\s\s\ssufficient\s\s\s\spam_unix.so\ssha512\sshadow\snullok\stry_first_pass\suse_authtok/password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=4/g" /etc/pam.d/password-auth

echo "TMOUT=900" >> /etc/bashrc
echo "TMOUT=900" >> /etc/profile

chown root:root /etc/passwd- 
chmod u-x,go-wx /etc/passwd-

chown root:root /etc/group-
chmod u-x,go-wx /etc/group-