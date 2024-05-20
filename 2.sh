sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22

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
