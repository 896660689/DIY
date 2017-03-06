#!/bin/sh
if [ ! -d OUT ]; then
	mkdir OUT
fi
find . -iname "*.mp4" -or -iname "*.mkv" -or -iname "*.mov" -or -iname "*.avi" -exec ffmpeg -i {} -strict -2 -acodec aac -ab 225k -ar 44.1k -ac 2 -vf crop="in_w:in_w*338/720" -s 720x338 -vcodec libx264 -crf 17 -profile:v main -level 3.1 out/{} \;
