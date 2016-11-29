#!/bin.sh

nvram set https_crt_save=0
nvram unset https_crt_file
service restart_httpd

#Ensure blank
nvram get https_crt_file

cd /etc
chmod 666 cert.pem key.pem

nvram set https_crt_save=1
#Ensure 1
nvram get https_crt_save

service restart_httpd

#Ensurebefore reboot
nvram get https_crt_file

#Ensure after reboot
reboot
