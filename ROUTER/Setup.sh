
ln -nsf /jffs /tmp/opt
wget -O - http://pkg.entware.net/binaries/armv7/installer/entware_install.sh | /bin/sh

echo "#!/bin/sh" > /jffs/scripts/services-start
echo "sleep 20" >> /jffs/scripts/services-start
echo "ln -ns /jffs /tmp/opt" >> /jffs/scripts/services-start
echo "/opt/etc/init.d/rc.unslung start" >> /jffs/scripts/services-start
echo "#!/bin/sh" > /jffs/scripts/services-stop
echo "/opt/etc/init.d/rc.unslung stop" >> /jffs/scripts/services-stop
chmod a+rx /jffs/scripts/*

opkg update
opkg list
#opkg install
opkg remove


#~/.ssh
cd /jffs/bin
wget -O speedtest https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py; chmod +x speedtest;
./speedtest

#tcpdump -i br0 host 114.141.173.62 -w /tmp/tcpdump.cap
