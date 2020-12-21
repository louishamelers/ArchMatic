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
echo "Enter a username for a standard user: "
read USERNAME
useradd -m -G wheel ${USERNAME}
echo "Password for ${USERNAME}"
passwd louis

echo "--------------------------------------"
echo "--      Installing stuff            --"
echo "--------------------------------------"

# install sudo
pacman -S --noconfirm sudo
# configure sudo 
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# install grub & boot
pacman -S --noconfirm grub
pacman -S --noconfirm efibootmgr
pacman -S --noconfirm dosfstools
pacman -S --noconfirm os-prober
pacman -S --noconfirm mtools
# configure grub
mkdir /boot/EFI
mount /dev/nvme0n1p1 /boot/EFI
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --efi-directory=/boot/EFI --recheck
grub-mkconfig -o /boot/grub/grub.cfg

pacman -S --noconfirm networkmanager
systemctl enable NetworkManager

# done
exit
