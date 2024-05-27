#!/usr/bin/env bash

#cfdisk

lsblk

echo "enter 1 to setup DUALBOOT"
read DUALBOOT

echo "enter diskname"
read DISKNAME

EFIINDEX="1"
SWAPINDEX="2"
ROOTINDEX="3"

echo "enter efi partition index"
#read EFIINDEX
EFI="/dev/${DISKNAME}p${EFIINDEX}"
echo $EFI

echo "enter swap partition index"
#read SWAPINDEX
SWAP="/dev/${DISKNAME}p${SWAPINDEX}"
echo $SWAP

echo "enter root partition index"
#read ROOTINDEX
ROOT="/dev/${DISKNAME}p${ROOTINDEX}"
echo $ROOT

echo "enter hostname"
read HOSTNAME

echo "enter root password"
read ROOTPASSWORD

echo "enter username"
read USERNAME

echo "enter password"
read PASSWORD

echo "enter 1 to get DISCORD"
read DISCORD

echo "enter 1 to get PYTHON"
read PYTHON

echo "enter 1 to get NVM"
read NVM

echo "enter 1 to get NVIDIA and PICOM"
read NVIDIAPICOM

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

cat <<REALEND > /mnt/next.sh
echo root:$ROOTPASSWORD | chpasswd
useradd -m $USERNAME
usermod -aG wheel,storage,power,audio $USERNAME
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

echo "installing bootloader"
pacman -S grub efibootmgr dosfstools mtools

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager

echo "auth       optional     pam_gnome_keyring.so" >> /etc/pam.d/login
echo "session    optional     pam_gnome_keyring.so auto_start" >> /etc/pam.d/login

su $USERNAME

echo "installing compressing stuff"
sudo pacman -S zip unzip --noconfirm --needed

echo "installing time sync"
sudo pacman -S ntp --noconfirm --needed

echo "installing bluetooth stuff"
sudo pacman -S bluez bluez-utils blueman --noconfirm --needed
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service
sudo sed -i 's/^#AutoEnable=true/AutoEnable=true/' /etc/bluetooth/main.conf
sudo sed -i 's/^# AutoEnable=true/AutoEnable=true/' /etc/bluetooth/main.conf
sudo sed -i 's/^#AutoEnable = true/AutoEnable=true/' /etc/bluetooth/main.conf
sudo sed -i 's/^# AutoEnable = true/AutoEnable=true/' /etc/bluetooth/main.conf
sudo sed -i 's/^#FastConnectable = false/FastConnectable = false/' /etc/bluetooth/main.conf
sudo sed -i 's/^# FastConnectable = false/FastConnectable = false/' /etc/bluetooth/main.conf

echo "installing remote stuff (ssh, ufw, rsync, git)"
sudo pacman -S openssl openssh ufw rsync git --noconfirm --needed
sudo systemctl enable sshd
sudo systemctl start sshd
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22
sudo ufw enable

echo "installing manuals"
sudo pacman -S man-db

echo "installing display stuff"
sudo pacman -S xorg feh figlet --noconfirm --needed

echo "installing audio stuff"
sudo pacman -S pulseaudio --noconfirm --needed

echo "installing gnome-kering-daemon"
sudo pacman -S gnome-keyring

echo "installing browsers"
sudo pacman -S firefox chromium

echo "installing xdotool and xclip"
sudo pacman -S xdotool xclip

echo "installing vnc"
sudo pacman -S tigervnc

if [[ $DISCORD == "1" ]]; then 
echo "installing discord"
sudo pacman -S discord
fi

if [[ $PYTHON == "1" ]]; then 
echo "installing python"
sudo pacman -S python
fi

if [[ $NVM == "1" ]]; then 
echo "installing nvm for node"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

if [[ $NVIDIAPICOM == "1" ]]; then 
sudo pacman -S nvidia picom
fi

if [[ $DUALBOOT == "1" ]]; then 
sudo pacman -S fuse3 os-prober
sudo sed -i 's/^GRUB_TIMEOUT=5/GRUB_TIMEOUT=20/' /etc/default/grub
sudo sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
sudo sed -i 's/^# GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
fi

REALEND

arch-chroot /mnt sh next.sh

umount -lR /mnt
