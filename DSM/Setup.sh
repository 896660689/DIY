
#Aria Deamon
ln -s /volume1/Downloads/.opt /opt
#Run as admin: /volume1/Downloads/.opt/bin/aria

#~/.ssh
cd /opt/bin
wget -O speedtest https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py; chmod +x speedtest; ./speedtest

cat << \EOF > ~/.bashrc
#!/bin/sh
LS_OPTIONS=-la
PATH=$PATH:/volume1/Downloads/.opt/bin
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
EOF

/opt/bin/busybox passwd admin
/opt/bin/busybox passwd root
