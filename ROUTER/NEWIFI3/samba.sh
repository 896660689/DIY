
#!/bin/sh

cat <<\EOF > /etc/smb.conf
[global]
workgroup = WORKGROUP
netbios name = Store
server string = Storage
local master = yes
os level = 128
name resolve order = lmhosts hosts bcast
log file = /var/log/samba.log
log level = 0
max log size = 5
socket options = TCP_NODELAY SO_KEEPALIVE
unix charset = UTF8
display charset = UTF8
bind interfaces only = yes
interfaces = br0
unix extensions = no
encrypt passwords = yes
pam password change = no
obey pam restrictions = no
host msdfs = no
disable spoolss = yes
max protocol = SMB2
passdb backend = smbpasswd
security = USER
username level = 8
map to guest = Bad User
hide unreadable = yes
directory mode = 0777
create mask = 0777
force directory mode = 0777
max connections = 10
use spnego = no
client use spnego = no
null passwords = yes
strict allocate = no
use sendfile = yes
dos filemode = yes
dos filetimes = yes
dos filetime resolution = yes
access based share enum = yes

[Downloads]
path = /media/STORE/Downloads
public = yes
writable = yes

[Public]
path = /media/STORE/Public
public = yes
write list = admin

[Music]
path = /media/STORE/Music
public = yes
write list = admin

[Pictures]
path = /media/STORE/Pictures
write list = admin

[Movies]
path = /media/STORE/Movies
write list = admin

[Documents]
path = /media/STORE/Documents
write list = admin

EOF

killall -9 nmbd
killall -9 smbd
/sbin/smbd -D -s /etc/smb.conf
/sbin/nmbd -D -s /etc/smb.conf
smbpasswd admin admin

