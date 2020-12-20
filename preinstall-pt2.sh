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
