# from https://qiita.com/penkoba/items/b245c42980f7b0e16193
# from https://gist.github.com/proshunsuke/420a060a9600320a2f456e10ebb3ce01
# from https://www.mk-mode.com/blog/2021/09/08/debian-11-initial-setting/
# from https://qiita.com/tadakado/items/625109cb9902b070042a

# root
nano /etc/apt/sources.list
apt update && apt upgrade
####################################
- deb cdrom:[Debian GNU/Linux 11.3.0 _Bullseye_ - Official amd64 DVD Binary-1 20220326-11:23]/ bullseye contrib main
+ #deb cdrom:[Debian GNU/Linux 11.3.0 _Bullseye_ - Official amd64 DVD Binary-1 20220326-11:23]/ bullseye contrib main
####################################

apt install sudo

usermod -G sudo juglans
ip a
# juglans
lsblk
#############################################
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda      8:0    0 223.6G  0 disk
├─sda1   8:1    0   512M  0 part /boot/efi
├─sda2   8:2    0   1.7G  0 part /boot
├─sda3   8:3    0   976M  0 part [SWAP]
└─sda4   8:4    0 220.4G  0 part /
sdb      8:16   0 931.5G  0 disk
└─sdb1   8:17   0 931.5G  0 part
sdc      8:32   0 465.8G  0 disk
└─sdc1   8:33   0 465.8G  0 part
##############################################

sudo apt install bcache-tools
sudo modprobe bcache
sudo /usr/sbin/make-bcache -B /dev/sdc1
sudo mkfs.ext4 /dev/bcache0

lsblk
#################################################
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda           8:0    0 223.6G  0 disk
├─sda1        8:1    0   512M  0 part /boot/efi
├─sda2        8:2    0   1.7G  0 part /boot
├─sda3        8:3    0   976M  0 part [SWAP]
└─sda4        8:4    0 220.4G  0 part /
sdb           8:16   0 931.5G  0 disk
└─sdb1        8:17   0 931.5G  0 part
sdc           8:32   0 465.8G  0 disk
└─sdc1        8:33   0 465.8G  0 part
  └─bcache0 254:0    0 465.8G  0 disk
##################################################

sudo mount /dev/bcache0 /mnt
sudo apt install libarchive-tools
sudo bsdtar cvpf - --one-file-system / | sudo bsdtar xvpf - -C /mnt
ls -l /dev/disk/by-uuid
######################################################################
total 0
lrwxrwxrwx 1 root root 10 May 28 14:15 2a9524aa-d43c-462a-a185-ceaea320928f -> ../../sdc1
lrwxrwxrwx 1 root root 10 May 28 14:04 4d921b83-ee06-40bd-b98d-0a7c56882ab6 -> ../../sda4
lrwxrwxrwx 1 root root 10 May 28 14:04 5A64E4CD64E4AD47 -> ../../sdb1
lrwxrwxrwx 1 root root 13 May 28 14:15 93c55e8c-c3f9-4fd2-aec4-75bd5fc8c67b -> ../../bcache0
lrwxrwxrwx 1 root root 10 May 28 14:04 D696-632A -> ../../sda1
lrwxrwxrwx 1 root root 10 May 28 14:04 d6db478e-ff08-47bc-a118-91fee8a28fc5 -> ../../sda2
lrwxrwxrwx 1 root root 10 May 28 14:04 f9333795-a363-41e5-a3e3-88ef22580270 -> ../../sda3
######################################################################

sudo nano /mnt/etc/fstab
##################################################################################################
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# systemd generates mount units based on this file, see systemd.mount(5).
# Please run 'systemctl daemon-reload' after making changes here.
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/sda4 during installation
UUID=93c55e8c-c3f9-4fd2-aec4-75bd5fc8c67b /               ext4    errors=remount-ro 0       1
# /boot was on /dev/sda2 during installation
UUID=d6db478e-ff08-47bc-a118-91fee8a28fc5 /boot           ext4    defaults        0       2
# /boot/efi was on /dev/sda1 during installation
UUID=D696-632A  /boot/efi       vfat    umask=0077      0       1
# swap was on /dev/sda3 during installation
UUID=f9333795-a363-41e5-a3e3-88ef22580270 none            swap    sw              0       0
#######################################################################################################

sudo mount -B /dev /mnt/dev
sudo mount -B /proc /mnt/proc
sudo mount -B /sys /mnt/sys
sudo mount -B /sys/firmware/efi/efivars /mnt/sys/firmware/efi/efivars
sudo mount /dev/sda2 /mnt/boot
sudo mount /dev/sda1 /mnt/boot/efi
sudo chroot /mnt
grub-install --recheck /dev/sda
update-grub
exit
sudo reboot

df
##############################################################
Filesystem     1K-blocks    Used Available Use% Mounted on
udev             8099952       0   8099952   0% /dev
tmpfs            1623268    1252   1622016   1% /run
/dev/bcache0   479595168 1379156 453780404   1% /
tmpfs            8116332       0   8116332   0% /dev/shm
tmpfs               5120       0      5120   0% /run/lock
/dev/sda2        1692648   81524   1506832   6% /boot
/dev/sda1         523244    3492    519752   1% /boot/efi
tmpfs            1623264       0   1623264   0% /run/user/1000
#################################################################

lsblk
###############################################################
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda           8:0    0 223.6G  0 disk
├─sda1        8:1    0   512M  0 part /boot/efi
├─sda2        8:2    0   1.7G  0 part /boot
├─sda3        8:3    0   976M  0 part [SWAP]
└─sda4        8:4    0 220.4G  0 part
sdb           8:16   0 931.5G  0 disk
└─sdb1        8:17   0 931.5G  0 part
sdc           8:32   0 465.8G  0 disk
└─sdc1        8:33   0 465.8G  0 part
  └─bcache0 254:0    0 465.8G  0 disk /
###############################################################

sudo wipefs -a /dev/sda4
sudo make-bcache -C /dev/sda4
######################################################
UUID:                   368f0a62-46d5-48a5-af8e-02e163a087b9
Set UUID:               bfe6d77a-b3be-4876-957e-a30a6c6614cb
version:                0
nbuckets:               451460
block_size:             1
bucket_size:            1024
nr_in_set:              1
nr_this_dev:            0
first_bucket:           1
######################################################

echo bfe6d77a-b3be-4876-957e-a30a6c6614cb | sudo tee /sys/block/bcache0/bcache/attach


# 消すとき
echo 1 | sudo tee /sys/block/bcache0/bcache/stop
sudo wipefs -a /dev/sdc1



# proxmoxintall ###############################################
sudo su -
apt-get install -y man-db less sudo net-tools tmux unzip
nano /etc/network/interfaces
##################################################################
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug enp0s31f6
auto enp0s31f6
#iface enp0s31f6 inet dhcp
# This is an autoconfigured IPv6 interface
iface enp0s31f6 inet6 auto

iface enp0s31f6 inet static
    address 192.168.0.11
    netmask 255.255.255.0
    gateway 192.168.0.1
##################################################################
nano /etc/hosts
#############
192.168.0.11    alice.alice.home        alice
#############

nano /etc/ssh/sshd_config
#####
PasswordAuthentication yes
PermitRootLogin yes
#######
systemctl reload ssh
#######sshclientで
ssh-keygen -t rsa -b 4096
ssh-copy-id -i pve.pub juglans@192.168.0.11
#######

echo "deb [arch=amd64] http://download.proxmox.com/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list

wget https://enterprise.proxmox.com/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg 
sha512sum /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg

apt update && apt full-upgrade

apt install proxmox-ve postfix open-iscsi

mkdir /root/config.bak
mv /etc/apt/sources.list.d/pve-enterprise.list /root/config.bak/pve-enterprise.list.bak

systemctl reboot

apt remove linux-image-amd64 'linux-image-5.10*'
update-grub

