http://rt.cn2k.net/
https://eyun.baidu.com/s/3pLMbUqR
https://www.right.com.cn/forum/thread-342918-1-1.html

#自定义脚本0
/sbin/stop_samba
killall -9 nmbd
killall -9 smbd
sed -i '/\[global\]/a\veto files=/aria/transmission/.Trashes/._*/' /etc/smb.conf
/sbin/smbd -D -s /etc/smb.conf
/sbin/nmbd -D -s /etc/smb.conf

curl -o /tmp/ntfslabel  https://pkg.musl.cc/ntfs-3g-2017.3.23/mipsel-linux-musl/sbin/ntfslabel


