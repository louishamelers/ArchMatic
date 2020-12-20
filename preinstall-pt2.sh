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
mount /dev/nvme0n1p1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

pacman -S --noconfirm networkmanager git
systemctl enable NetworkManager

# done
exit
