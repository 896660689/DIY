#!/bin/sh
cd "${0%/*}"
CDIR=$(cd "${0%/*}"; pwd)

curl -s -u yonsmguo:asdf1234 http://members.3322.net/dyndns/update?hostname=yonsm.f3322.net
"$CDIR/UPNPC" -a `ifconfig | grep 'inet.*netmask.*broadcast' | awk '{print $2}'` 5900 5900 TCP
open "$CDIR/VNC.png"