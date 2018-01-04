#!/bin/sh
cd `dirname $0`
/usr/bin/python3 configurator.py settings.conf

#sudo systemctl enable home-assistant-configurator@homeassistant.service
#ln -s /home/homeassistant/.homeassistant/configurator/home-assistant-configurator@homeassistant.service /etc/systemd/system/home-assistant-configurator@homeassistant.service
