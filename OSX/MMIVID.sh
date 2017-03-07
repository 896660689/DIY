#!/bin/sh

MakeMMIViD()
{
	DDIR="${1%/*}/OUT"
	if [ ! -d "$DDIR" ]; then
		mkdir "$DDIR"
	fi
	
	FILE="${1##*/}"
	NAME="${FILE%.*}"
	DVID="$DDIR/$NAME.mp4"

	FOPT="-y -strict -2 -acodec aac -ab 225k -ar 44.1k -ac 2 -vf crop=in_w:in_w*338/720 -s 720x338 -vcodec libx264 -crf 17 -profile:v main -level 3.1"
	
	SUBT="${1%.*}.srt"
	if [ ! -f "$SUBT" ]; then
		SUBT="${1%.*}.ass"
	fi
	if [ -f "$SUBT" ]; then
		ffmpeg -i "$1" $FOPT -vf subtitles="$SUBT":original_size=720x338 "$DVID"</dev/null
	else
		ffmpeg -i "$1" $FOPT "$DVID"</dev/null
	fi
}

VDIR=$1
if [ -z "$VDIR" ]; then
	VDIR=.
fi

if [ -f "$VDIR" ]; then
	MakeMMIViD "$VDIR"
else
	find -E "$VDIR" -iregex ".*\.(mp4|mkv|mov|avi|wmv|vob)" -maxdepth 1 | while read f ; do MakeMMIViD "$f" ; done
fi
