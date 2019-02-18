# First: Tv Tool root

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

mkdir /system/etc/init.d
echo "#!/system/bin/sh" > /system/etc/init.d/99SuperSuDaemon
echo "/system/xbin/daemonsu --auto-daemon &" > /system/etc/init.d/99SuperSuDaemon
chmod 755 /system/etc/init.d/99SuperSuDaemon

echo "#!/system/bin/sh" > /system/etc/init.d/88HomeAssistant
echo "curl -k -d '{\"state\": \"on\", \"attributes\": {\"friendly_name\": \"播放器\"}}' https://192.168.1.10:8123/api/states/switch.himedia" >> /system/etc/init.d/88HomeAssistant
chmod 755 /system/etc/init.d/88HomeAssistant

#curl -k -d '{"state": "off", "attributes": {"friendly_name": "播放器"}}' https://192.168.1.10:8123/api/states/switch.himedia


# adb connect 192.168.1.2
# 安装apk
# adb shell settings put secure install_non_market_apps 1
# adb push com.he.ardc_2.1.1369.apk /data/local/tmp/
# adb shell /system/bin/pm install -t /data/local/tmp/com.he.ardc_2.1.1369.apk
# 截屏
# adb shell screencap -p /data/local/tmp/1.png && adb pull /data/local/tmp/1.png
# 模拟点击
# adb shell input tap 551 258
# 卸载应用
# adb shell /system/bin/pm uninstall com.he.ardc
