echo "--------------------------------------"
echo "-- Timezone, hw clock & locale      --"
echo "--------------------------------------"

## Hostname
echo Rollo > /etc/hostname

# set timezone
ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc

# generate locale
echo "nl_NL.UTF-8 UTF-8" > /etc/locale.gen
locale-gen


# edit hosts file
echo "127.0.0.1     localhost" > /etc/hosts
echo "::1           localhost" > /etc/hosts
echo "127.0.1.1     Rollo.localdomain      Rollo" > /etc/hosts

echo "--------------------------------------"
echo "--      User management             --"
echo "--------------------------------------"

# set root user password
echo "Enter password for root user: "
passwd

# make default user
echo "Enter a username for ya boi: "
read USERNAME
useradd -m -G wheel ${USERNAME}
echo "Password for ${USERNAME}"
passwd louis

echo "--------------------------------------"
echo "--      Installing stuff            --"
echo "--------------------------------------"

# install boot stuff
pacman -S --noconfirm efibootmgr
pacman -S --noconfirm dosfstools
pacman -S --noconfirm os-prober
pacman -S --noconfirm mtools

# install sudo
pacman -S --noconfirm sudo
# configure sudo 
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# install grub
pacman -S --noconfirm grub
# configure grub
mkdir /boot/EFI
mount /dev/nvme0n1p1 /boot/EFI
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck

















# # install xorg
# pacman -S --noconfirm mesa
# pacman -S --noconfirm xorg
# pacman -S --noconfirm xorg-xinit
# # configure xinit
# echo "exec awesome" > /home/arch/.xinitrc

# # install window manager
# pacman -S --noconfirm awesome

































# # echo "done"
# # read -p "Press enter to continue"

# echo "--------------------------------------"
# echo "-- Bootloader Systemd Installation  --"
# echo "--------------------------------------"
# bootctl install
# cat <<EOF > /boot/loader/entries/arch.conf
# title Arch Linux  
# linux /vmlinuz-linux  
# initrd  /initramfs-linux.img  
# options root=${DISK}1 rw
# EOF


# echo "done"
# read -p "Press enter to continue"

# echo "--------------------------------------"
# echo "--          Network Setup           --"
# echo "--------------------------------------"
# pacman -S networkmanager dhclient --noconfirm --needed
# systemctl enable --now NetworkManager

# exit
# umount -R /mnt
