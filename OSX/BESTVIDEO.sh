#!/bin/sh

inTypes="mp4|mkv|mov|avi|wmv|vob"
outDir=OUT

videoWidth=720
videoHeight=338
videoLevel=3.1
videoProfile=main
videoConstantRateFactor=17

audioChannel=2
audioCodec=aac
audioBitRate=225k
audioSampleRate=44.1k

audioOptions="-acodec $audioCodec -ab $audioBitRate -ar $audioSampleRate -ac $audioChannel"
videoOptions="-s ${videoWidth}x$videoHeight -vcodec libx264 -crf $videoConstantRateFactor -profile:v $videoProfile -level $videoLevel"
cropOptions1="-vf crop=in_w:in_w*$videoHeight/$videoWidth"
cropOptions2="-vf crop=in_h*$videoWidth/$videoHeight:in_h"

CDIR=$(cd "${0%/*}"; pwd)
PATH=$CDIR:$PATH
pushd $PWD >/dev/null

if [ $# = 0 ]; then
	videoPath=.
else
	videoPath="$1"
fi

MakeVideo()
{
	if [ ! -d "$outDir" ]; then mkdir "$outDir"; fi

	subtitle="${1%.*}.ass"
	if [ ! -f "$subtitle" ]; then subtitle="${1%.*}.srt"; fi
	if [ -f "$subtitle" ]; then 
		detectedCharset=`file -b --mime-encoding "$subtitle"`
		if [[ "$detectedCharset" =~ "utf" ]]; then charsetOption=; else charsetOption=":charenc=GB18030"; fi
		echo "Subtitle: $subtitle"
		echo "Charset: $detectedCharset"
		ffmpeg -i "$1" -y $audioOptions $videoOptions $cropOptions1,subtitles="$subtitle"$charsetOption "$outDir/${1%.*}.mp4" </dev/null
		if [ $? == 1 ]; then
			ffmpeg -i "$1" -y $audioOptions $videoOptions $cropOptions2,subtitles="$subtitle"$charsetOption "$outDir/${1%.*}.mp4" </dev/null
		fi
	else
		ffmpeg -i "$1" -y $audioOptions $videoOptions $cropOptions1 "$outDir/${1%.*}.mp4" </dev/null
		if [ $? == 1 ]; then
			ffmpeg -i "$1" -y $audioOptions $videoOptions $cropOptions2 "$outDir/${1%.*}.mp4" </dev/null
		fi
	fi
}

if [ -d "$videoPath" ]; then
	cd "$videoPath"
	find -E . -iregex ".*\.($inTypes)" -maxdepth 1 | while read f ; do MakeVideo "${f##*/}" ; done
	if [ ! -d "$outDir" ]; then
		cd "$CDIR"
		find -E . -iregex ".*\.($inTypes)" -maxdepth 1 | while read f ; do MakeVideo "${f##*/}" ; done
		if [ ! -d "$outDir" ]; then
			echo "Usage: $0 [FILE|DIR|] - Empty means ./ or $CDIR"
		fi
	fi
else
	if [[ "${videoPath}" =~ "/" ]]; then cd "${videoPath%/*}"; fi
	MakeVideo "${videoPath##*/}"
fi

popd >/dev/null

