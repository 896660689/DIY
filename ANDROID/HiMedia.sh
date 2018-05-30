adb connect HiMedia
adb remount
adb shell
cd /system/bin
ln -s busybox ftpd
ln -s busybox tcpsvd
tcpsvd -vE 0.0.0.0 21 ftpd /
