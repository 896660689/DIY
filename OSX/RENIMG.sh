#!/bin/sh
CDIR=$(cd "${0%/*}"; pwd)
PATH=$CDIR:$PATH
SDIR=$1

if [ ! -d "$SDIR" ]; then
	echo "Usage: $0 <DIR>"
	exit 1
fi

RENAME()
{
	SRC="$1/$2"
	DST="$1/$3.$4"
	if [ "$SRC" != "$DST" ]; then
		if [[ -f "$DST" ]]; then
			RENAME "$1" "$2" "$3_" "$4" "$5" "$6"
		else
			echo "$5: $2 => $3.$4"
			if [ "$6" == "" ]; then
				mv "$SRC" "$DST"
				if [[ -f "$1/.thumb.$2.jpg" ]]; then
					echo "$5: .thumb.$2.jpg => .thumb.$3.$4.jpg"
					mv "$1/.thumb.$2.jpg" "$1/.thumb.$3.$4.jpg"
				fi
			fi
		fi
	else
		echo "$5: $2 => SAME"
	fi
}

for FILE in `ls "$SDIR"|tr " " "?"`
do
	FILE=`echo $FILE|tr "?" " "`
	EXT=${FILE##*.}
	EXT=`echo $EXT | tr "[:upper:]" "[:lower:]"`
	
	if [[ "$EXT" = jpg ]] || [[ "$EXT" = jpeg ]]; then
		DATE=`jhead "$SDIR/$FILE" | grep "Date/Time"`
		if [ -z "$DATE" ]; then
			NAME=""
		else
			NAME="`echo ${DATE:15:10} | tr : -` `echo ${DATE:26} | tr -d :`"
		fi
		RESULT="EXIF"
	elif [[ "$EXT" = png ]] || [[ "$EXT" = gif ]] || [[ "$EXT" = mov ]] || [[ "$EXT" = mp4 ]] || [[ "$EXT" = avi ]]; then
		NAME=""
	else
		continue
	fi

	if [ -z "$NAME" ]; then
		if [ ${#FILE} -eq 21 ] && [ "${FILE:4:1}" == "-" ] && [ "${FILE:7:1}" == "-" ] && [ "${FILE:10:1}" == " " ]; then
			echo "KEEP: $FILE"
			continue
		else
			if [ ${#FILE} -ge 23 ] && [ "${FILE:4:1}" == "-" ] && [ "${FILE:7:1}" == "-" ] && [ "${FILE:10:1}" == "_" ] && [ "${FILE:13:1}" == "-" ] && [ "${FILE:16:1}" == "-" ]; then
				NAME="${FILE:0:10} ${FILE:11:2}${FILE:14:2}${FILE:17:2}"
				RESULT="NAME"
			else
				if [ "${OSTYPE:0:6}" == "darwin" ]; then
					NAME=`stat -f "%Sm" -t "%Y-%m-%d %H%M%S" "$SDIR/$FILE"`
				else
					DATE=`stat -c "%y" "$SDIR/$FILE" | cut -c1-33`
					NAME=`date +%Y-%m-%d %H%M%S -d "$DATE"`
				fi
				RESULT="STAT"
			fi
		fi
	fi

	if [ ! -z "$NAME" ]; then
		RENAME "$SDIR" "$FILE" "$NAME" "$EXT" "$RESULT" "$2"
	else
		echo "FAIL: $FILE"
	fi
done
