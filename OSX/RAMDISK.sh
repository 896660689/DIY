#!/bin/bash

case "$1" in
    1|2|3|4)
        GSIZE=$1
        ;;
    '')
        GSIZE=2
        ;;
    *)
        echo 'RAMDISK Utility for macOS 10.13-10.14\n'
        echo 'Usage: $0 [GSIZE] [HDCMD]\n'
        echo 'GSIZE - Size in GB, 1/2/3/4 Only, Default 2, RECOMMENDATION: based on physycle memory 4G=1, 8G=2, 16G=3, 32G=4'
        echo 'HDCMD - hdid/hdik/hdiutil Only, Default hdid, NOTE: hdik=kernel but low speed, hdiutil=fast but shutdown slowly\n'
        echo
        exit
        ;;
esac

case "$2" in
    hdik)
        HDCMD="hdik -drivekey system-image=yes -nomount ram://$(($GSIZE*1024*1024*2))"
        ;;
    hdiutil)
        HDCMD="hdiutil attach -nomount ram://$(($GSIZE*1024*1024*2))"
        ;;
    *)
        HDCMD="hdid -nomount ram://$(($GSIZE*1024*1024*2))"
        ;;
esac

RAMCMD="dev=\`$HDCMD\`; newfs_hfs -v RAM \$dev; mount_hfs -o union \$dev /private/tmp; chmod 041777 /private/tmp"
echo "$RAMCMD"
echo

echo -n "Enter root password:"
read PASSWORD
echo

cat << EOF | sudo tee /Library/LaunchAgents/net.yonsm.ramdisk.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>net.yonsm.ramdisk</string>
	<key>ProgramArguments</key>
	<array>
		<string>bash</string>
		<string>-c</string>
		<string>""echo $PASSWORD | sudo -S bash -c '$RAMCMD'""</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
EOF
echo

#
if [ -d ~/Library/Caches/Google ] ; then
    echo Link ~/Library/Caches/Google to /private/tmp
    rm -rf ~/Library/Caches/Google
    ln -s /private/tmp ~/Library/Caches/Google
fi

if [ -d ~/Library/Developer/Xcode ] ; then
    echo Link ~/Library/Developer/Xcode/DerivedData to /private/tmp
    rm -rf ~/Library/Developer/Xcode/DerivedData
    ln -s /private/tmp ~/Library/Developer/Xcode/DerivedData
fi

if [ -d ~/Library/Developer/Xcode ] ; then
    echo Link ~/Library/Developer/Xcode/Archives to /private/tmp
    rm -rf ~/Library/Developer/Xcode/Archives
    ln -s /private/tmp ~/Library/Developer/Xcode/Archives
fi

echo
echo "Done, please reboot to take effect. Enjoy:)"
echo
