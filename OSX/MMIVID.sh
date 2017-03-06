#!/bin/sh

MakeMMIViD()
{
	DDIR="${1%/*}/MMIVID"
	if [ ! -d "$DDIR" ]; then
		mkdir "$DDIR"
	fi
	FILE="${1##*/}"
	NAME="${FILE%.*}"
	DVID="$DDIR/$NAME.mp4"
	ffmpeg -i "$1" -strict -2 -acodec aac -ab 225k -ar 44.1k -ac 2 -vf crop="in_w:in_w*338/720" -s 720x338 -vcodec libx264 -crf 16 -profile:v main -level 3.1 "$DVID"
}

VDIR=$1
if [ -z "$VDIR" ]; then
	VDIR=.
fi

if [ -f "$VDIR" ]; then
	MakeMMIViD "$VDIR"
else
	find -E "$VDIR" -iregex ".*\.(mp4|mkv|mov|avi)" -maxdepth 1 | while read f ; do MakeMMIViD "$f" ; done
fi
