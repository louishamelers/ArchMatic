#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo "-------------------------------------------------"
echo "Sync clock etc"
echo "-------------------------------------------------"
timedatectl set-ntp true
timedatectl status

echo "-------------------------------------------------"
echo "-------select your disk to format----------------"
echo "-------------------------------------------------"
lsblk
echo "Please enter disk: (example /dev/sda)"
read DISK
echo "--------------------------------------"
echo -e "\nFormatting disk...\n$HR"
echo "--------------------------------------"

# disk prep
sgdisk -Z ${DISK} # zap all on disk
sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment

# create partitions
sgdisk -n 1:0:+550M ${DISK} # partition 1 (UEFI SYS), default start block, 512MB
sgdisk -n 2:0:+2G   ${DISK} # partition 2 (SWAP), default start block, 2GB
sgdisk -n 3:0:0     ${DISK} # partition 3 (Root), default start block, remaining

# set partition types
sgdisk -t 1:ef00 ${DISK}
sgdisk -t 2:8200 ${DISK}
sgdisk -t 3:8300 ${DISK}

# label partitions
sgdisk -c 1:"UEFISYS" ${DISK}
sgdisk -c 2:"SWAP" ${DISK}
sgdisk -c 3:"ROOT" ${DISK}

# make filesystems
echo -e "\nCreating Filesystems...\n$HR"

mkfs.fat -F32 -n "UEFISYS" "${DISK}p1"
mkswap "${DISK}p2"
swapon "${DISK}p2"
mkfs.ext4 -L "ROOT" "${DISK}p3"

# mount target
# mkdir /mnt
mount -t ext4 "${DISK}p3" /mnt
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount -t vfat "${DISK}p1" /mnt/boot/

echo "done"
read -p "Press enter to continue"

echo "--------------------------------------"
echo "-- Arch Install on Main Drive       --"
echo "--------------------------------------"
pacstrap /mnt base base-devel linux linux-firmware vim sudo --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt


echo "done"
read -p "Press enter to continue"

echo "--------------------------------------"
echo "-- Timezone, hw clock & locale      --"
echo "--------------------------------------"

ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc
## Locales
# edit /etc/locale.gen -> uncomment nl-NL...
# locale-gen

## Hostname
# /etc/hostname -> 'Rollo'

## Hosts
# /etc/hosts -> add following lines:
# 127.0.0.1     localhost
# ::1           localhost
# 127.0.1.1     Rollo.localdomain      Rollo


echo "done"
read -p "Press enter to continue"

echo "--------------------------------------"
echo "--      User management             --"
echo "--------------------------------------"
# root user
echo "Enter password for root user: "
passwd

# louis user
useradd -m louis
echo "Enter password for louis: "
passwd louis
usermod -aG wheel,audio,video,optical,storage louis

echo "done"
read -p "Press enter to continue"

# echo "--------------------------------------"
# echo "--      Installing Sudo             --"
# echo "--------------------------------------"

# pacman -S sudo --noconfirm --needed

# echo "done"
# read -p "Press enter to continue"

echo "--------------------------------------"
echo "-- Bootloader Systemd Installation  --"
echo "--------------------------------------"
bootctl install
cat <<EOF > /boot/loader/entries/arch.conf
title Arch Linux  
linux /vmlinuz-linux  
initrd  /initramfs-linux.img  
options root=${DISK}1 rw
EOF


echo "done"
read -p "Press enter to continue"

echo "--------------------------------------"
echo "--          Network Setup           --"
echo "--------------------------------------"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager

exit
umount -R /mnt

echo "--------------------------------------"
echo "--   SYSTEM READY FOR FIRST BOOT    --"
echo "--------------------------------------"
