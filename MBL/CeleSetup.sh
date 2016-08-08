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

apache2ctl restart
htpasswd -c /etc/apache2/htpasswd admin

#
cd /usr/local/mediacrawler 
./mediacrawlerd disable

# python
echo "#deb http://ftp.us.debian.org/debian/ unstable main contrib non-free" >> /etc/apt/sources.list
apt-get update
apt-get install python2.7
cd /usr/bin
ln -sf python2.7 python

#cd /usr/lib
#ln -s libcurl-gnutls.so.4.2.0
#ln -s libcurl-gnutls.so.4
#ln -s libcurl-gnutls.so.4
#ln -s libcurl-gnutls.so.3

# ffmpeg
cd /usr/lib/powerpc-linux-gnu
ln -s ibXfixes.so.3.1.0    libXfixes.so.3
ln -s libaacplus.so.2.0.2   libaacplus.so.2
ln -s libass.so.4.1.0    libass.so.4
ln -s libavcodec.so.54.59.100  libavcodec.so.54
ln -s libavdevice.so.54.2.101  libavdevice.so.54
ln -s libavfilter.so.3.17.100  libavfilter.so.3
ln -s libavformat.so.54.29.104  libavformat.so.54
ln -s libavutil.so.51.73.101  libavutil.so.51
ln -s libbluray.so.1.2.0   libbluray.so.1
ln -s libcdio.so.13.0.0    libcdio.so.13
ln -s libcdio_cdda.so.1.0.0   libcdio_cdda.so.1
ln -s libcdio_paranoia.so.1.0.0  libcdio_paranoia.so.1
ln -s libenca.so.0.5.1    libenca.so.0
ln -s libfaac.so.0.0.0    libfaac.so.0
ln -s libfontconfig.so.1.5.0  libfontconfig.so.1
ln -s libfribidi.so.0.3.3   libfribidi.so.0
ln -s libjack.so.0.0.28    libjack.so.0
ln -s libmp3lame.so.0.0.0   libmp3lame.so.0
ln -s libopencore-amrnb.so.0.0.3 libopencore-amrnb.so.0
ln -s libopencore-amrwb.so.0.0.3 libopencore-amrwb.so.0
ln -s libopus.so.0.2.0    libopus.so.0
ln -s libpostproc.so.52.0.100  libpostproc.so.52
ln -s libswresample.so.0.15.100  libswresample.so.0
ln -s libswscale.so.2.1.101   libswscale.so.2
ln -s libtalloc.so.2.0.7   libtalloc.so.2
ln -s libtdb.so.1.2.10    libtdb.so.1
ln -s libvo-aacenc.so.0.0.3   libvo-aacenc.so.0
ln -s libvo-amrwbenc.so.0.0.3  libvo-amrwbenc.so.0
ln -s libvpx.so.1.1.0    libvpx.so.1
ln -s libvpx.so.1.1.0    libvpx.so.1.1
ln -s libxvidcore.so.4.3   libxvidcore.so.4

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

cd /opt
wget http://mybookworld.wikidot.com/local--files/optware/setup-mybooklive.sh
sh setup-mybooklive.sh

ipkg update
ipkg install dnsmasq

ipkg install transmission
