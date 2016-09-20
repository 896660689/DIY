#!/bin/sh
#DAT=`dirname $0`
DAT=/Volumes/DATA/百度云同步盘
echo $DAT
if [ ! -d "$DAT" ]; then
	echo "Data Dir Not Exist"
	exit 1
fi

cd $DAT
find . -name ".*" -print0 | xargs -0 rm

for DIR in `ls $DAT`
do
	if [ "$DIR" = "Videos" ]; then
		DST="Movies"
	else
		DST=$DIR
	fi
	
	if [ -d ~/$DST ]; then
		FILES=`ls $HOME/$DST|tr " " "?"`
		for NAME in $FILES
		do
			NAME=`echo $NAME|tr "?" " "`
			if [ -L "$HOME/$DST/$NAME" ]; then
				TARGET=`ls -la "$HOME/$DST/$NAME"|sed 's/.*-> //'`
				if [[ $TARGET = $DAT* ]]; then
					echo Remove\ $HOME/$DST/$NAME
					rm "$HOME/$DST/$NAME"
				else
					echo Retain\ $HOME/$DST/$NAME
				fi
			fi
		done

		FILES=`ls $DIR|tr " " "?"`
		for NAME in $FILES
		do
			NAME=`echo $NAME|tr "?" " "`
			if [ -d "$DAT/$DIR/$NAME" ]; then
				if [ "$NAME" != "iTools" ]; then
				if [ "$NAME" != "Tencent Files" ]; then
				if [ "$NAME" != "Visual Studio 2012" ]; then
					echo Create\ ~/$DST/$NAME
					ln -s "$DAT/$DIR/$NAME" "$HOME/$DST/$NAME"
				fi
				fi
				fi
			fi
		done
	fi
done

