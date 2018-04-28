#!/bin/sh

sudo passwd root
sudo passwd --unlock root
nano /etc/ssh/sshd_config #PermitRootLogin yes

#root
usermod -l admin pi
groupmod -n admin pi
mv /home/pi /home/admin
usermod -d /home/admin admin
nano /etc/sudoer #admin ALL=(ALL) NOPASSWD: ALL

# Home Assistant
apt-get update
apt-get upgrade -y

apt-get install python3 python3-pip
apt-get install libavahi-compat-libdnssd-dev # homekit
apt-get install mosquitto mosquitto-clients

pip3 install homeassistant
hass

