#!/bin/sh
CDIR=$(cd "${0%/*}"; pwd)

sudo spctl --master-disable

echo "$CDIR/bin" | sudo tee /etc/paths.d/tools.admin.diy

#defaults write com.apple.iTunes DeviceBackupsDisabled -bool YES
defaults write com.apple.desktopservices DSDontWriteNetworkStores true
defaults write com.apple.iTunes AutomaticDeviceBackupsDisabled -bool true

#$CDIR/RAMDISK.sh

exit

# Brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
#brew install telnet
#pip3 install esptool

# Speed Test
cd $CDIR/bin
curl -o ./speedtest https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
chmod +x ./speedtest

# NTFS Mount
sudo umount /dev/disk3s1
sudo mount_ntfs -o rw,nobrowse /dev/disk3s1 /Volumes/USBD

# Disk Speed Test
dd bs=64k count=4k if=/dev/zero of=test conv=fsync
dd bs=64k count=4k if=/dev/zero of=test conv=fdatasync
hdparm -Tt --direct /dev/mmcblk0p2
dd if=test.dbf bs=8k count=300000 of=/dev/null

# WireShark
#sudo chmod 666 /dev/bpf*
ssh root@localhost 'tcpdump -s 0 -U -n -i en0 -w - not port 22' | wireshark -k -i -

# Aria
aria2c -c -s10 -k1M -x16 --enable-rpc=false -o "xxxx" --header "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36" --header "Referer: https://pan.baidu.com/disk/home" --header "Cookie: BDUSS=; pcsett=" "https://d.pcs.baidu.com/"

# Chrome + Baidu https://github.com/acgotaku/BaiduExporter
cd ~/Downloads && git clone https://github.com/CodeTips/BaiduNetdiskPlugin-macOS.git && ./BaiduNetdiskPlugin-macOS/Other/Install.sh

# Flutter
cd /Users/admin/Sites
git clone -b master https://github.com/flutter/flutter.git
cat << \EOF > ~/.bash_profile
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export PATH=/Users/admin/Sites/flutter/bin:$PATH
EOF
flutter doctor

# VS Code
cat << \EOF > "~/Library/Application Support/Code/User/settings.json"
{
    "diffEditor.ignoreTrimWhitespace": false,
    "editor.detectIndentation": true,
    "editor.insertSpaces": false,
    "editor.minimap.enabled": false,
    "editor.useTabStops": true,
    "html.format.wrapLineLength": 160,
    "prettier.endOfLine": "lf",
    "prettier.htmlWhitespaceSensitivity": "strict",
    "prettier.printWidth": 160,
    "prettier.semi": false,
    "prettier.singleQuote": true,
    "prettier.tabWidth": 4,
    "prettier.useTabs": true,
    "python.autoComplete.addBrackets": true,
    "python.pythonPath": "/usr/local/bin/python3",
    "workbench.startupEditor": "newUntitledFile",
}
EOF
