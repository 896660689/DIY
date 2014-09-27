#!/bin/sh

#
cd /etc/init.d
update-rc.d optware.sh defaults

#
cd /etc/apache2/mods-enabled/
ln -s ../mods-available/autoindex.load
ln -s ../mods-available/autoindex.conf
ln -s ../mods-available/cgi.load
ln -s ../mods-available/auth_basic.load

#
cd /var/www
ln -s /shares/Media ./media
ln -s /shares/Public ./public
ln -s appletv/us/js/application.js
chmod -R 775 appletv
chmod -R 775 aria   
chmod -R 664 aria/*.*
chmod -R 775 appletv/
chmod -R 664 appletv/*.*
chmod -R 775 appletv/*.cgi

#
cd /usr/local/mediacrawler 
./mediacrawlerd disable

#
 mkdir /usr/ffmpeg
 cd /usr/ffmpeg
 tar xzf ../ffmpeg.tgz
 mv bin/* /usr/bin/
 mv lib/powerpc-linux-gnu/* /usr/lib/powerpc-linux-gnu/
cd ..
rm -rf ffmpeg

#cd /opt
#pkg update
#pkg install lynx

#ipkg install dnsmasq
#onf-file=/opt/etc/dnsmasq.custom

echo "#deb http://ftp.us.debian.org/debian/ unstable main contrib non-free" >> /etc/apt/sources.list
apt-get update
apt-get install python2.7
cd /usr/bin
ln -sf python2.7 python
cd /usr/lib
ln -s libcurl-gnutls.so.4.2.0 ln -s libcurl-gnutls.so.4
ln -s libcurl-gnutls.so.4 ln -s libcurl-gnutls.so.3

#ipkg
#echo 'export PATH=/opt/bin:$PATH ' >> ~/.bashrc
#source ~/.bashrc
#feed=http://ipkg.nslu2-linux.org/feeds/optware/ds101g/cross/stable
#ipk_name=$(wget -qO- $feed/Packages | awk '/^Filename: ipkg-opt/ {print $2}')
#wget $feed/$ipk_name
#tar -xOvzf $ipk_name ./data.tar.gz | tar -C / -xzvf -
#mkdir -p /opt/etc/ipkg
#echo "src cross $feed" > /opt/etc/ipkg/feeds.conf
#echo "src armel http://ipkg.nslu2-linux.org/feeds/optware/ds101g/cross/stable" $
#wget http://mybookworld.wikidot.com/local--files/optware/sort_dirname.tar.gz
#tar xvfz sort_dirname.tar.gz -C /
