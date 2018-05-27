
#Aria Deamon
# mv /opt /volume1/Downloads/.opt
# ln -s /volume1/Downloads/.opt /opt
# /volume1/Downloads/.opt/etc/init.d/S90aria

/opt/bin/busybox passwd admin
/opt/bin/busybox passwd root

#~/.ssh
cd mv /opt/bin
wget -O speedtest https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py; chmod +x speedtest.py; ./speedtest
