#!/bin/sh
CDIR=$(cd "${0%/*}"; pwd)
cd $CDIR

sudo mkdir -p /usr/local/bin/
sudo ln -sf "$CDIR/bin/bestvideo" /usr/local/bin/
sudo ln -sf "$CDIR/bin/renimg" /usr/local/bin/
sudo ln -sf "$CDIR/bin/linkapp" /usr/local/bin/
sudo ln -sf "$CDIR/bin/jhead" /usr/local/bin/
sudo ln -sf "$CDIR/bin/ffmpeg" /usr/local/bin/
sudo ln -sf "$CDIR/bin/adb" /usr/local/bin/
sudo ln -sf "$CDIR/bin/aapt" /usr/local/bin/
sudo ln -sf "$CDIR/bin/fastboot" /usr/local/bin/
sudo ln -sf "$CDIR/bin/aria2c" /usr/local/bin/
sudo ln -sf "$CDIR/bin/jq" /usr/local/bin/
sudo ln -sf "$CDIR/bin/jtool" /usr/local/bin/
sudo ln -sf "$CDIR/bin/jurple" /usr/local/bin/
sudo ln -sf "$CDIR/bin/iperf3" /usr/local/bin/
sudo ln -sf "$CDIR/bin/speedtest" /usr/local/bin/

sudo spctl --master-disable

defaults write com.apple.iTunes DeviceBackupsDisabled -bool YES
defaults write com.apple.desktopservices DSDontWriteNetworkStores true
defaults write com.apple.iTunes AutomaticDeviceBackupsDisabled -bool true

# Chrome + Baidu (com.google.Chrome.mobileconfig): https://github.com/acgotaku/BaiduExporter
#open ./Chrome.mobileconfig

#./RamDisk.sh

# Disk speed test
#dd bs=64k count=4k if=/dev/zero of=test conv=fsync
#dd bs=64k count=4k if=/dev/zero of=test conv=fdatasync
#hdparm -Tt --direct /dev/mmcblk0p2
#dd if=test.dbf bs=8k count=300000 of=/dev/null

# WireShark
#sudo chmod 666 /dev/bpf*

#aria
#aria2c -c -s10 -k1M -x16 --enable-rpc=false -o "xxxx" --header "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36" --header "Referer: https://pan.baidu.com/disk/home" --header "Cookie: BDUSS=; pcsett=" "https://d.pcs.baidu.com/"


#Flutter
cd /Users/admin/Sites
git clone -b master https://github.com/flutter/flutter.git
cat << \EOF > ~/.bash_profile
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export PATH=/Users/admin/Sites/flutter/bin:$PATH
EOF
flutter doctor
