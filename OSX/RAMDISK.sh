#!/bin/bash

echo Link ~/Library/Caches/Google to /private/tmp
rm -rf ~/Library/Caches/Google
ln -s /private/tmp ~/Library/Caches/Google

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

echo -n "Enter root password:"
read PASSWORD

#hdik -drivekey system-image=yes -nomount ram://4194304 # LOW SPEED
#hdiutil attach -nomount ram://4194304
#hdid -nomount ram://4194304

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
		<string>""echo $PASSWORD | sudo -S bash -c 'dev=\`hdid -nomount ram://4194304\`; newfs_hfs -v RAM \$dev; mount_hfs -o union \$dev /private/tmp; chmod 041777 /private/tmp'""</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
EOF
