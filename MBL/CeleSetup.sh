#!/bin/sh

#ipkg
echo 'export PATH=/opt/bin:$PATH ' >> ~/.bashrc
source ~/.bashrc
feed=http://ipkg.nslu2-linux.org/feeds/optware/ds101g/cross/stable
ipk_name=$(wget -qO- $feed/Packages | awk '/^Filename: ipkg-opt/ {print $2}')
wget $feed/$ipk_name
tar -xOvzf $ipk_name ./data.tar.gz | tar -C / -xzvf -
mkdir -p /opt/etc/ipkg
echo "src cross $feed" > /opt/etc/ipkg/feeds.conf
echo "src armel http://ipkg.nslu2-linux.org/feeds/optware/ds101g/cross/stable" $
wget http://mybookworld.wikidot.com/local--files/optware/sort_dirname.tar.gz
tar xvfz sort_dirname.tar.gz -C /

#
cd /etc/init.d
update-rc.d optware.sh defaults

#
cd /etc/apache2/mods-enabled/
ln -s ../mods-available/autoindex.load
ln -s ../mods-available/autoindex.conf
ln -s ../mods-available/cgi.load
ln -s ../mods-available/auth_basic.load

cd /var/www
ln -s /shares/Media ./media
ln -s /shares/Public ./public

cd /opt
ipkg update
ipkg install lynx

ipkg install dnsmasq
conf-file=/opt/etc/dnsmasq.custom

echo "#deb http://ftp.us.debian.org/debian/ unstable main contrib non-free" >> /etc/apt/sources.list
apt-get update
apt-get install python2.7
cd /usr/bin
ln -sf python2.7 python
#apt-cache search pycurl
#apt-get install python-pycurl

cd /usr/local/mediacrawler 
./mediacrawlerd disable

#http://ipkg.nslu2-linux.org/feeds/optware/ds101g/cross/stable/py26-curl_7.19.0-1_powerpc.ipk
# http://ipkg.nslu2-linux.org/feeds/optware/ds101g/cross/stable/python26_2.6.8-1_powerpc.ipk

cd /var/www
ln -s appletv/us/js/application.js
