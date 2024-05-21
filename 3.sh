sudo pacman -S nvidia picom fuse3 os-prober
sudo sed -i 's/^GRUB_TIMEOUT=5/GRUB_TIMEOUT=20/' /etc/default/grub
sudo sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
sudo sed -i 's/^# GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
