
echo "installing compressing stuff"
pacman -S zip unzip --noconfirm --needed

echo "installing bluetooth stuff"
pacman -S bluez bluez-utils --noconfirm --needed
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

echo "installing remote stuff (ssh, ufw, rsync, git)"
pacman -S openssl openssh ufw rsync git --noconfirm --needed
sudo systemctl enable sshd
sudo systemctl start sshd

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22
sudo ufw enable

echo "installing display stuff"
pacman -S xorg --noconfirm --needed

echo "installing audio stuff"
pacman -S pulseaudio --noconfirm --needed

echo "installing browsers"
sudo pacman -S firefox discord chromium xdotool xclip tigervnc man-db

echo "installing browsers"
sudo pacman -S discord

echo "installing xdotool and xclip"
sudo pacman -S xdotool xclip

echo "installing manuals"
sudo pacman -S man-db

echo "installing vnc"
sudo pacman -S tigervnc
