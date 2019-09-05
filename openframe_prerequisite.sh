#! /bin/bash
#############################################################
# Author: Permander malik , Nirpendra Kumar
# Version: v1.0.0
# Date: 2019-09-03
# Description: 
# Change History:
#             Date         description          author
#           dd/mm/yy
# Usage:
##############################################################
#### Variables Section ####
SVRNAME=oframessi
IP=`ifconfig eth0 |grep inet |head -1 |awk '{print $2}'`

#### Step1 ########

#### Creating Groups with GID(300 & 305) and add users(oframe & oftibr) in groups (mqm & DBA) ############

groupadd mqm -g 300
groupadd dba -g 305
useradd -d /home/oframe -g mqm -s /bin/bash -m oframe -u 301 
useradd -d /home/oftibr -g dba -s /bin/bash -m oftibr -u 302

### Step2###########
### Assign password to users that has created ###

echo "tmax123" | passwd --stdin oframe
echo "tmax123" | passwd --stdin oftibr

### Step3###########
### Grant Read and execute permissions to all users ###

chmod -R 755 /home/oftibr
chmod -R 755 /home/oframe

### Step4###########
### Copy pubic key from ec2 user home to oframe home directory so that oframe user can be logged in without password ###

cp -R /home/ec2-user/.ssh /home/oframe  ; chown -R oframe:mqm /home/oframe/.ssh 

### Step5###########
### Create Multiple directories for Installation of different openframe components ###

cd /opt ; mkdir tmaxapp tmaxdb tmaxui  tmaxsw


##### Step 6 ######
#### Assign Permission to directories ###
chgrp mqm -R tmaxapp tmaxui
chgrp dba -R tmaxdb
chmod g+w tmaxapp tmaxdb tmaxui
chown -R oframe tmaxapp tmaxui tmaxsw
chown -R oftibr tmaxdb
###OR ####
chown -R oframe:mqm tmaxapp tmaxsw tmaxui
chown -R oftibr:dba tmaxdb


###### Step 7 ######
#### Add users into Sudo file ######
cat >>/etc/sudoers.d/90-cloud-init-users <<EOF
oframe ALL=(ALL) NOPASSWD:ALL
oftibr ALL=(ALL) NOPASSWD:ALL
EOF

####Step 8 ######
##### Enable Password Authentication  and Restart sshd service  #####
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
service sshd restart >/dev/null 



###Step 9 ###
### Add Kernel Parameters ########
cat>>/etc/sysctl.conf<<EOF
kernel.shmall = 7294967296 
kernel.sem = 10000 32000 10000 10000 
EOF

sysctl -p >/dev/null


### Step 10 ######
### Adding iP and hostname entry in /etc/hosts file #####
#cat >>/etc/hosts <<EOF
#`hostname -i` $SVRNAME  $SVRNAME
#EOF
####   OR   ####

cat>>/etc/hosts<<EOF
$IP $SVRNAME $SVRNAME
EOF
#### Set hostame ###
hostnamectl set-hostname $SVRNAME
hostname $SVRNAME 


### Step 11 ###
#### Setting up Ulimit ####

cat >>/etc/security/limits.conf <<EOF
oftibr           soft    nofile          1024
oftibr           hard    nofile          65536
oftibr           soft    nproc           2047
oftibr           hard    nproc           16384
oframe           soft    nofile          65536
oframe           hard    nofile          65536
oframe           soft    nproc           unlimited
oframe           hard    nproc           unlimited
oframe           soft    core            unlimited
oframe           hard    core            unlimited
EOF


### Step 12 ####

### Install required Packages #####
yum install -y -q  dos2unix  glib*  glibc.i686 glibc.x86_64 glibc-devel.i686 libaio java-1.7.0-openjdk-devel gcc gcc-c++ strace ltrace gdb libaio-devel.x86_64 sysstat telnet git wget  dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm ntp htop >/dev/null 


### Step 13 ####
### Start ntpd service ####
systemctl enable ntpd >/dev/null
systemctl start ntpd >/dev/null
	  
	
#### Now Copy the Software to any Location on Server #######
DIR=/opt/tmaxsw/software
if [ -d "$DIR" ]; then
    echo "$DIR exist"
else 
    echo "$Please copy the file then only we can proceed further"
fi
	
	






            



