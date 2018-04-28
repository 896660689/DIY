#!/bin/sh

#ssh pi@hassbian

sudo passwd root
sudo passwd --unlock root
sudo nano /etc/ssh/sshd_config #PermitRootLogin yes
sudo mkdir /root/.ssh
mkdir ~/.ssh
sudo reboot

#scp ~/.ssh/authorized_keys root@hassbian:~/.ssh/
#scp ~/.ssh/authorized_keys pi@hassbian:~/.ssh/
#ssh root@hassbian

# Rename pi->admin
usermod -l admin pi
groupmod -n admin pi
mv /home/pi /home/admin
usermod -d /home/admin admin
passwd admin
echo "admin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

raspi-config # Hostname, WiFi, locales(en_US.UTF-8/zh_CN.GB18030/zh_CN.UTF-8), Timezone

#
apt-get update
apt-get upgrade -y

# Home Assistant
apt-get install python3 python3-pip
pip3 install homeassistant

# HomeKit
apt-get install libavahi-compat-libdnssd-dev
pip3 install pycryptodome #https://github.com/home-assistant/home-assistant/issues/12675

# Mosquitto
apt-get install mosquitto mosquitto-clients
#cat /etc/mosquitto/mosquitto.conf #allow_anonymous true
#systemctl stop mosquitto
#sleep 2
#rm -rf /var/lib/mosquitto/mosquitto.db
#systemctl start mosquitto
#sleep 2
#mosquitto_sub -v -t '#'

# Auto start
cat <<EOF > /etc/systemd/system/homeassistant.service
[Unit]
Description=Home Assistant
After=network-online.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/hass

[Install]
WantedBy=multi-user.target

EOF

systemctl --system daemon-reload
systemctl enable homeassistant
systemctl start home-assistant

# Debug
hass

# Restart
echo .> /var/log/daemon.log; echo .>~/.homeassistant/home-assistant.log; systemctl restart homeassistant; tail -f /var/log/daemon.log

# Upgrage
systemctl stop homeassistant
pip3 install --upgrade homeassistant
systemctl start homeassistant
