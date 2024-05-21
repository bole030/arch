sudo pacman -S nvidia picom fuse3 os-prober
sed -i 's/^#%wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
