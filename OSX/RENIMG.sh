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
			RENAME "$1" "$2" "$3_" "$4"
		else
			echo "$2 => $3.$4"
			mv "$SRC" "$DST"
		fi
	else
		echo "$2: NOT CHANGED"
	fi
}

for FILE in `ls "$SDIR"|tr " " "?"`
do
	FILE=`echo $FILE|tr "?" " "`
	EXT=${FILE##*.}
	EXT=`echo $EXT | tr "[:upper:]" "[:lower:]"`

	if [[ "$EXT" =~ jpg ]] || [[ "$FILE" =~ jpeg ]]; then
		DATE=`jhead "$SDIR/$FILE" | grep "Date/Time"`
		NAME=`echo ${DATE:15} | tr ":" "-" | tr " " "_"`
	elif [[ "$FILE" =~ png ]] || [[ "$FILE" =~ gif ]]; then
		NAME=""
	else
		continue
	fi

	if [ -z "$NAME" ]; then
		if [ "${OSTYPE:0:6}" == "darwin" ]; then
			NAME=`stat -f "%Sm" -t "%Y-%m-%d_%H-%M-%S" "$SDIR/$FILE"`
		else
			NAME=`stat -c "%y" "$SDIR/$FILE" | tr " " "_" | tr ":" "-" | cut -c1-19`
		fi
		echo "$FILE: NO EXIF"
	fi

	if [ ! -z "$NAME" ]; then
		RENAME "$SDIR" "$FILE" "$NAME" "$EXT"
	else
		echo "$FILE: STAT ERROR"
	fi
done
