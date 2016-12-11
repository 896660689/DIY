#!/bin/sh
if [ ! -d OUT ]; then
	mkdir OUT
fi
find . -name "*.mp4" -exec ffmpeg -i {} -strict -2 -acodec aac -ab 225k -ar 44.1k -ac 2 -s 720x338 -vcodec libx264 -crf 17 -profile:v main -level 3.1 out/{} \;
