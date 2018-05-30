
adb connect HiMedia

adb install OpenBlurayMode.apk
adb install Superuser.apk

adb remount
adb push xbin/su /system/xbin/

adb shell
cd /system/bin
ln -s busybox ftpd
ln -s busybox tcpsvd
#tcpsvd -vE 0.0.0.0 21 ftpd /
