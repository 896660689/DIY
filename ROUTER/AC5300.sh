#!/bin/sh

nvram set "dhcp_staticlist=<00:90:4C:1E:50:50>192.168.1.2>Router2"
nvram commit
exit 0

addthis.com
alphacoders.com
amazonaws.com
americanexpress.com
bandwagonhost.com
bitbucket.org
brew.sh
cloudfront.net
hdroute.org
ip138.com
lithium.com
pypi.org
python.org
pythonhosted.org
files.pythonhosted.org
twitter.com
wikipedia.org
yonsm.net
code.org
scratch.mit.edu
debian.org
github.com
api.github.com
codeload.github.com
raw.githubusercontent.com
homebrew.bintray.com

#
nvram set https_crt_save=0
nvram unset https_crt_file
service restart_httpd
nvram get https_crt_file
#scp
nvram set https_crt_save=1
nvram get https_crt_save
service restart_httpd
nvram get https_crt_file
nvram commit


cat <<EOF > /jffs/dnsmasq.dhcp
...
EOF

#
cat <<\EOF > /jffs/jffs.sh
#!/bin/sh
/jffs/jffs2.sh &
EOF
chmod 755 /jffs/jffs.sh

#
cat <<\EOF > /jffs/jffs2.sh
#!/bin/sh

echo `date` --- 1 >> /jffs/jffs.log
ps|grep dns >> /jffs/jffs.log
sleep 12

i=0
while [ $i -le 20 ]; do
      success_start_service=`nvram get success_start_service`
      if [ "$success_start_service" == "1" ]; then
              break
      fi
      i=$(($i+1))
      echo "autorun APP: wait $i seconds...";
      sleep 1
done

echo `date` Step --- 2 i=$i >> /jffs/jffs.log
ps|grep dns >> /jffs/jffs.log

killall dnsmasq
sleep 2
dnsmasq --dhcp-hostsfile=/jffs/dnsmasq.dhcp --log-async --address=/xxx/192.168.1.1

echo `date` Step --- 3 >> /jffs/jffs.log
ps|grep dns >> /jffs/jffs.log

EOF
chmod 755 /jffs/jffs2.sh

#
nvram set jffs2_exec=/jffs/jffs.sh
nvram commit

