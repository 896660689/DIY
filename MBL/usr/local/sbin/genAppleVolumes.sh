#!/bin/bash
#
# (c) 2013 Western Digital Technologies, Inc. All rights reserved.
#
# genAppleVolumes.sh <type>
#   generates apple volumes files from shares list

. /usr/local/sbin/share-param.sh
. /etc/system.conf
. /etc/nas/config/afp.conf

[ -f "${AFP_VETO_PATH}" ] && . "${AFP_VETO_PATH}"

if [ -f /etc/nas/timeMachine.conf ]; then
    . /etc/nas/timeMachine.conf
fi

# If backups are disabled, clear the backup share name (which may be set).

if [ "${backupEnabled}" = "false" ]; then
    backupShare=""
fi

backupShareOptions="time machine = yes"
if [ "$backupSizeLimit" -ne 0 ]; then
    let "sizeLimitMb = ($backupSizeLimit * 1000000)/1048576"
    shareSizeMb=`df "/shares/$backupShare" | awk '/^\// {printf("%.0f",$2/1024)}'`
	if [ "$sizeLimitMb" -lt "$shareSizeMb" ]; then
		backupShareOptions+=$'\n'
		backupShareOptions+="vol size limit = ${sizeLimitMb}"
	fi
fi

options="ea = auto"
options+=$'\n'
options+="convert appledouble = no"
options+=$'\n'
options+="stat vol = no"

options+=$'\n'
options+="veto = \"/Temporary Items/Network Trash Folder/\""


perm="file perm = 664"
perm+=$'\n'
perm+="directory perm = 775"

#PUBLIC share list
getShares.sh public > /tmp/public-share-list
while read publicshare; do
	echo "[${publicshare}]"
	echo "path = /shares/${publicshare}"
	if [ "${publicshare}" == "${backupShare}" ]; then
		echo "${backupShareOptions}"
	fi
	echo "${options}" 
	echo "${perm}"
	echo ""
	[ ! -z "${AFP_VETO}" ] && echo "veto files = ${AFP_VETO}"
done < /tmp/public-share-list > /etc/nas/afp_share.conf

#PRIVATE share list
getShares.sh private > /tmp/private-share-list
while read privateshare; do
	rwList=`getAcl.sh ${privateshare} RW | awk '{printf("%s,",$0)}'`
	roList=`getAcl.sh ${privateshare} RO | awk '{printf("%s,",$0)}'`
    accessLists="valid users = ${rwList}${roList}"
	if [ "${roList}" != "" ]; then
		accessLists+=$'\n'
		accessLists+="rolist = ${roList}"
	fi
	if [ "${rwList}" != "" ]; then
		accessLists+=$'\n'
		accessLists+="rwlist = ${rwList}"
	fi

	if [ "${rwList}" != "" ] || [ "${roList}" != "" ]; then
		echo "[${privateshare}]"
		echo "path = /shares/${privateshare}"
		if [ "${backupShare}" = "${privateshare}" ]; then
			echo "${backupShareOptions}"
		fi
		echo "${options}" 
		echo "${perm}"
		echo "${accessLists}"
		echo ""
		[ ! -z "${AFP_VETO}" ] && echo "veto files = ${AFP_VETO}"
	fi
done < /tmp/private-share-list >> /etc/nas/afp_share.conf
exit 0

