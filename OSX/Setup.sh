#!/bin/sh
CDIR=$(cd "${0%/*}"; pwd)
cd $CDIR

sudo mkdir -p /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/bestvideo" /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/renimg" /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/linkapp" /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/jhead" /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/ffmpeg" /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/adb" /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/fastboot" /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/aria2c" /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/jq" /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/jtool" /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/jurple" /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/iperf3" /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/speedtest" /usr/local/bin/

sudo cp etc/hosts /etc/hosts

sudo spctl --master-disable

defaults write com.apple.desktopservices DSDontWriteNetworkStores true
defaults write com.apple.iTunes AutomaticDeviceBackupsDisabled -bool true
#defaults write com.apple.iTunes DeviceBackupsDisabled -bool YES

# Chrome + Baidu (com.google.Chrome.mobileconfig): https://github.com/acgotaku/BaiduExporter
open ./Chrome.mobileconfig
#./RamDisk.sh

#dd bs=64k count=4k if=/dev/zero of=test conv=fsync
#dd bs=64k count=4k if=/dev/zero of=test conv=fdatasync
#hdparm -Tt --direct /dev/mmcblk0p2
#dd if=test.dbf bs=8k count=300000 of=/dev/null


sudo chmod 666 /dev/bpf*


#aria2c -c -s10 -k1M -x16 --enable-rpc=false -o "xxxx" --header "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36" --header "Referer: https://pan.baidu.com/disk/home" --header "Cookie: BDUSS=; pcsett=" "https://d.pcs.baidu.com/"
