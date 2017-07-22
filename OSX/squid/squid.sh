#!/bin/sh
cd "${0%/*}"
CDIR=$(cd "${0%/*}"; pwd)

if [ ! -f /usr/local/squid ]; then
	sudo ln -s "`pwd`" /usr/local/squid
fi

#rm -f var/logs/access.log
#rm -f var/logs/cache.log

if [ ! -f /Library/LaunchAgents/net.squid.plist ]; then
cat << EOF | sudo tee /Library/LaunchAgents/net.squid.plist > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>net.squid</string>
	<key>ProgramArguments</key>
	<array>
		<string>$CDIR/squid.sh</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
EOF
fi

echo "\033[31m1.DYNAMIC DNS\033[0m"

echo "\033[31m\n2.PORT FORWARD\033[0m"
./upnpc -a `ifconfig | grep 'inet.*netmask.*broadcast' | awk '{print $2}'` 8888 8888 TCP
curl https://freedns.afraid.org/dynamic/update.php?YnU1UFlWRWpwTEpIVGJZTzkyYWs6MTYyNTU3Njg=

echo "\033[31m\n3.START PROXY\033[0m"

./sbin/squid -f squid.conf -k kill
sleep 0.1
./sbin/squid -f squid.conf #-d 1

