#!/bin/sh
CDIR=$(cd "${0%/*}"; pwd)
cd $CDIR

sudo ln -sf "$CDIR/usr/local/bin/RENIMG.sh" /usr/local/bin/renimg
sudo ln -sf "$CDIR/usr/local/bin/LINKAPP.sh" /usr/local/bin/linkapp
sudo ln -sf "$CDIR/usr/local/bin/jhead" /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/ffmpeg" /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/adb" /usr/local/bin/
sudo ln -sf "$CDIR/usr/local/bin/fastboot" /usr/local/bin/

sudo ln -s "$CDIR/usr/local/bin/fastboot" /usr/local/bin/

sudo cp etc/hosts /etc/hosts

defaults write com.apple.desktopservices DSDontWriteNetworkStores true
defaults write com.apple.iTunes DeviceBackupsDisabled -bool YES
defaults write com.apple.iTunes AutomaticDeviceBackupsDisabled -bool true
