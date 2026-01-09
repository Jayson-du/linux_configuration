#/usr/bin/bash


sudo swapoff -a
sudo rm /swapfile

# 创建一个 4GB 的空文件（用 dd 或 fallocate）
sudo fallocate -l 4G /swapfile

sudo chmod 600 /swapfile

# 格式化
sudo mkswap /swapfile

sudo swapon /swapfile

echo "需要 sudo vim /etc/fstab"
echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab

free -h
swapon --show