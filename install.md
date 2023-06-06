from https://qiita.com/penkoba/items/b245c42980f7b0e16193

from https://gist.github.com/proshunsuke/420a060a9600320a2f456e10ebb3ce01

from https://www.mk-mode.com/blog/2021/09/08/debian-11-initial-setting/

from https://qiita.com/tadakado/items/625109cb9902b070042a

root
nano /etc/apt/sources.list

```
- deb cdrom:[Debian GNU/Linux 11.3.0 _Bullseye_ - Official amd64 DVD Binary-1 20220326-11:23]/ bullseye contrib main
+ #deb cdrom:[Debian GNU/Linux 11.3.0 _Bullseye_ - Official amd64 DVD Binary-1 20220326-11:23]/ bullseye contrib main
```
apt update && apt upgrade
apt install sudo

usermod -G sudo juglans
ip a

lsblk
```
NAME                  MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda                     8:0    0 223.6G  0 disk
├─sda1                  8:1    0   512M  0 part /boot/efi
├─sda2                  8:2    0   1.4G  0 part /boot
├─sda3                  8:3    0   953M  0 part [SWAP]
└─sda4                  8:4    0 220.7G  0 part
  └─237000MB-ssdcache 254:0    0 220.7G  0 lvm  /
sdb                     8:16   0 931.5G  0 disk
└─sdb1                  8:17   0 931.5G  0 part
sdc                     8:32   0 465.8G  0 disk
└─sdc1                  8:33   0 465.8G  0 part
  └─500100MB-hddroot  254:1    0 465.8G  0 lvm
```

sudo apt install bcache-tools
sudo modprobe bcache
sudo /usr/sbin/make-bcache -B /dev/mapper/500100MB-hddroot
sudo mkfs.ext4 /dev/bcache0

lsblk
```
NAME                  MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda                     8:0    0 223.6G  0 disk
├─sda1                  8:1    0   512M  0 part /boot/efi
├─sda2                  8:2    0   1.4G  0 part /boot
├─sda3                  8:3    0   953M  0 part [SWAP]
└─sda4                  8:4    0 220.7G  0 part
  └─237000MB-ssdcache 254:0    0 220.7G  0 lvm  /
sdb                     8:16   0 931.5G  0 disk
└─sdb1                  8:17   0 931.5G  0 part
sdc                     8:32   0 465.8G  0 disk
└─sdc1                  8:33   0 465.8G  0 part
  └─500100MB-hddroot  254:1    0 465.8G  0 lvm
    └─bcache0         253:0    0 465.8G  0 disk
```

sudo mount /dev/bcache0 /mnt
sudo apt install libarchive-tools
sudo bsdtar cvpf - --one-file-system / | sudo bsdtar xvpf - -C /mnt
ls -l /dev/disk/by-uuid

```
total 0
lrwxrwxrwx 1 root root 10 May 28 21:18 137c9885-945a-4ff3-aca6-ef85017ae5e1 -> ../../sda2
lrwxrwxrwx 1 root root 10 May 28 21:18 5A64E4CD64E4AD47 -> ../../sdb1
lrwxrwxrwx 1 root root 10 May 28 21:18 5db31726-7f98-4c8b-afdd-b8abb4a04840 -> ../../sda3
lrwxrwxrwx 1 root root 13 May 28 21:25 69400c3e-523a-46e7-bec0-7e74bb498a69 -> ../../bcache0
lrwxrwxrwx 1 root root 10 May 28 21:18 d812e2c5-4cd2-4b94-91f0-edbd8f36d4ef -> ../../dm-0
lrwxrwxrwx 1 root root 10 May 28 21:18 ED63-690E -> ../../sda1
lrwxrwxrwx 1 root root 10 May 28 21:25 f865d415-c4cb-4473-8099-f984f287c60b -> ../../dm-1
```

sudo nano /mnt/etc/fstab
``````
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
UUID=69400c3e-523a-46e7-bec0-7e74bb498a69 /               ext4    errors=remount-ro 0       1
# /boot was on /dev/sda2 during installation
UUID=137c9885-945a-4ff3-aca6-ef85017ae5e1 /boot           ext4    defaults        0       2
# /boot/efi was on /dev/sda1 during installation
UUID=ED63-690E  /boot/efi       vfat    umask=0077      0       1
# swap was on /dev/sda3 during installation
UUID=5db31726-7f98-4c8b-afdd-b8abb4a04840 none            swap    sw              0       0
``````

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
```
Filesystem     1K-blocks    Used Available Use% Mounted on
udev             8098512       0   8098512   0% /dev
tmpfs            1623268    1272   1621996   1% /run
/dev/bcache0   479593120 1378248 453779368   1% /
tmpfs            8116328       0   8116328   0% /dev/shm
tmpfs               5120       0      5120   0% /run/lock
/dev/sda2        1405264   87272   1228344   7% /boot
/dev/sda1         523244    3484    519760   1% /boot/efi
tmpfs            1623264       0   1623264   0% /run/user/1000
```

lsblk
```
NAME                  MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda                     8:0    0 223.6G  0 disk
├─sda1                  8:1    0   512M  0 part /boot/efi
├─sda2                  8:2    0   1.4G  0 part /boot
├─sda3                  8:3    0   953M  0 part [SWAP]
└─sda4                  8:4    0 220.7G  0 part
  └─237000MB-ssdcache 254:0    0 220.7G  0 lvm
sdb                     8:16   0 931.5G  0 disk
└─sdb1                  8:17   0 931.5G  0 part
sdc                     8:32   0 465.8G  0 disk
└─sdc1                  8:33   0 465.8G  0 part
  └─500100MB-hddroot  254:1    0 465.8G  0 lvm
    └─bcache0         253:0    0 465.8G  0 disk /
```

sudo wipefs -a /dev/mapper/237000MB-ssdcache
sudo make-bcache -C /dev/mapper/237000MB-ssdcache

```
UUID:                   a7ae10f2-7881-4f9a-a2a0-192fb4380c2d
Set UUID:               3c229b96-671a-4309-a9a4-5866a5ecffcf
version:                0
nbuckets:               452072
block_size:             1
bucket_size:            1024
nr_in_set:              1
nr_this_dev:            0
first_bucket:           1
```

echo 3c229b96-671a-4309-a9a4-5866a5ecffcf | sudo tee /sys/block/bcache0/bcache/attach
lsblk
```
NAME                  MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda                     8:0    0 223.6G  0 disk
├─sda1                  8:1    0   512M  0 part /boot/efi
├─sda2                  8:2    0   1.4G  0 part /boot
├─sda3                  8:3    0   953M  0 part [SWAP]
└─sda4                  8:4    0 220.7G  0 part
  └─237000MB-ssdcache 254:0    0 220.7G  0 lvm
    └─bcache0         253:0    0 465.8G  0 disk /
sdb                     8:16   0 931.5G  0 disk
└─sdb1                  8:17   0 931.5G  0 part
sdc                     8:32   0 465.8G  0 disk
└─sdc1                  8:33   0 465.8G  0 part
  └─500100MB-hddroot  254:1    0 465.8G  0 lvm
    └─bcache0         253:0    0 465.8G  0 disk /
```

echo writeback | sudo tee /sys/block/bcache0/bcache/cache_mode

消すとき
echo 1 | sudo tee /sys/block/bcache0/bcache/stop
sudo wipefs -a /dev/sdc1



## proxmoxintall

sudo su -
apt install -y man-db less sudo net-tools tmux unzip
nano /etc/network/interfaces
```
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
    dhcp 1
iface enp0s31f6 inet static
    address 192.168.0.11
    netmask 255.255.255.0
    gateway 192.168.0.1
```
nano /etc/hosts
```
192.168.0.11    alice.alice.home        alice
```

nano /etc/ssh/sshd_config
```
PasswordAuthentication yes
PermitRootLogin yes
```
systemctl reload ssh
reboot

## sshclientで

```
ssh-keygen -t rsa -b 4096
ssh-copy-id -i pve.pub juglans@192.168.0.11
```

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

nano /etc/network/interfaces
```
# network interface settings; autogenerated
# Please do NOT modify this file directly, unless you know what
# you're doing.
#
# If you want to manage parts of the network configuration manually,
# please utilize the 'source' or 'source-directory' directives to do
# so.
# PVE will preserve these directives, but will NOT read its network
# configuration from sourced files, so do not attempt to move any of
# the PVE managed interfaces into external files!

source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto enp0s31f6
iface enp0s31f6 inet6 auto

iface enp0s31f6 inet static
        address 192.168.0.11/24
        gateway 192.168.0.1

iface enp4s0 inet manual
auto vmbr0
iface vmbr0 inet static
    address  192.168.0.11
    netmask  255.255.255.0
    gateway  192.168.0.1
    bridge-ports enp0s31f6
    bridge-stp off
    bridge-fd 0
```

## reboot

https://zenn.dev/northeggman/articles/49c6b73c03c81c#vm%E4%BD%9C%E6%88%90
