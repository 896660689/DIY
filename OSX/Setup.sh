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
sudo ln -sf "$CDIR/usr/local/bin/iperf" /usr/local/bin/

sudo cp etc/hosts /etc/hosts

sudo spctl --master-disable

defaults write com.apple.desktopservices DSDontWriteNetworkStores true
defaults write com.apple.iTunes AutomaticDeviceBackupsDisabled -bool true
#defaults write com.apple.iTunes DeviceBackupsDisabled -bool YES

# Chrome + Baidu (com.google.Chrome.mobileconfig): https://github.com/acgotaku/BaiduExporter
open ./Chrome.mobileconfig
#./RamDisk.sh
