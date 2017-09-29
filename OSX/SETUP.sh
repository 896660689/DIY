#!/bin/sh
CDIR=$(cd "${0%/*}"; pwd)
cd $CDIR

sudo mkdir -p /usr/local/bin/
sudo ln -sf "$CDIR/BestVideo.sh" /usr/local/bin/bestvideo
sudo ln -sf "$CDIR/RenImg.sh" /usr/local/bin/renimg
sudo ln -sf "$CDIR/LinkApp.sh" /usr/local/bin/linkapp
sudo ln -sf "$CDIR/usr/local/bin/jhead" /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/ffmpeg" /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/adb" /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/fastboot" /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/aria2c" /usr/local/bin/

sudo cp etc/hosts /etc/hosts

sudo spctl --master-disable
defaults write com.apple.desktopservices DSDontWriteNetworkStores true
#defaults write com.apple.iTunes DeviceBackupsDisabled -bool YES
defaults write com.apple.iTunes AutomaticDeviceBackupsDisabled -bool true


# Chrome + Baidu (com.google.Chrome.mobileconfig): https://github.com/acgotaku/BaiduExporter