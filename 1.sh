#!/usr/bin/env bash

echo "Please enter EFI paritition: (example /dev/sda1 or /dev/nvme0n1p1)"
read EFI

echo "Please enter SWAP paritition: (example /dev/sda2)"
read SWAP

echo "Please enter Root(/) paritition: (example /dev/sda3)"
read ROOT 

echo -e "\n create and mount partitions \n"

mkfs.fat -F32 "${EFI}"
mkfs.ext4 "${ROOT}"
mkswap "${SWAP}"

# mount target
mount -t ext4 "${ROOT}" /mnt
mkdir /mnt/boot
mount "${EFI}" /mnt/boot/
swapon "${SWAP}"

echo "installing arch base"
pacstrap /mnt base base-devel --noconfirm --needed

echo "installing linux"
pacstrap /mnt linux linux-firmware --noconfirm --needed

echo "installing basic tools"
pacstrap /mnt zsh networkmanager vim sof-firmware --noconfirm --needed

# fstab
genfstab -U /mnt >> /mnt/etc/fstab

echo "Please enter your hostname"
read HOSTNAME 

echo "Please enter your password"
read PASSWORD 

cat <<REALEND > /mnt/next.sh
useradd -m bole
usermod -aG wheel,storage,power,audio $USER
echo bole:$PASSWORD | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^#%wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

echo "set language and set locale"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

echo "set time"
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc

echo "${HOSTNAME}" > /etc/hostname
cat <<EOF > /etc/hosts
127.0.0.1	localhost
::1			localhost
127.0.1.1	${HOSTNAME}.localdomain	${HOSTNAME}
EOF

echo "-- installing bootloader  --"
pacman -S grub efibootmgr dosfstools mtools

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager

REALEND


arch-chroot /mnt sh next.sh

umount -lR /mnt
