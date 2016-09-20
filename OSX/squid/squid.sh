#!/bin/sh
cd "${0%/*}"

echo "\033[31m1.DYNAMIC DNS\033[0m"

echo "\033[31m\n2.PORT FORWARD\033[0m"
./upnpc -a `ifconfig | grep 'inet.*netmask.*broadcast' | awk '{print $2}'` 8888 8888 TCP

echo "\033[31m\n3.START PROXY\033[0m"

if [ ! -d /usr/local/squid ]; then
	sudo ln -s "`pwd`" /usr/local/squid
fi
./sbin/squid -f squid.conf -k kill
sleep 0.1

#rm -f var/logs/access.log
#rm -f var/logs/cache.log

./sbin/squid -f squid.conf #-d 1

