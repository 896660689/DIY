#!/bin/sh
#SRC_DIR=`dirname $0`
SRC_DIR=/Volumes/DATA/Applications
DST_DIR=$HOME/Applications

# Check
if [ ! -d "$SRC_DIR" ]; then
	echo "Source Dir Not Exist"
	exit 1
fi

# Prepare
if [ -d "$DST_DIR" ]; then
	rm -rf $DST_DIR/*
else
	mkdir $DST_DIR
	touch $DST_DIR/.localized
fi

# Link
ITEMS=`ls "$SRC_DIR"|tr " " "?"`
for ITEM in $ITEMS
do
	ITEM=`echo $ITEM|tr "?" " "`
	if [ -d "$SRC_DIR/$ITEM" ]; then
		if [[ "$ITEM" =~ ".app" ]]; then
			if [ "$ITEM" == "AliWangwang.app" ]; then NAME="Wang Wang"
			elif [ "$ITEM" == "NeteaseMusic.app" ]; then NAME="Netease Music"
			elif [ "$ITEM" == "百度云同步盘.app" ]; then NAME="Baidu Cloud"
			elif [ "$ITEM" == "钉钉.app" ]; then NAME="Ding Talk"
			elif [ "$ITEM" == "有道词典.app" ]; then NAME="Youdao Dict"
			else NAME="${ITEM%*.app}"
			fi
			echo LINK\ "$DST_DIR/$NAME.app"
			ln -s "$SRC_DIR/$ITEM" "$DST_DIR/$NAME.app"
		else
			#if [ "$ITEM" == "Utilities" ]; then
			#	mkdir "$DST_DIR/$ITEM"
			#	touch "$DST_DIR/$ITEM/.localized"
			#fi
			APPS=`ls "$SRC_DIR/$ITEM"|tr " " "?"`
			for APP in $APPS
			do
				APP=`echo $APP|tr "?" " "`
				if [[ "$APP" =~ ".app" ]]; then
					if [ "$ITEM" == "Utilities" ]; then
						DST_APP="$DST_DIR/$ITEM/$APP"
					else
						if [[ "$ITEM" =~ "Photoshop" ]]; then
							DST_APP="$DST_DIR/Adobe Photoshop.app"
						else
							DST_APP="$DST_DIR/$APP"
						fi
					fi
					echo LINK\ "$DST_APP"
					ln -s "$SRC_DIR/$ITEM/$APP" "$DST_APP"
				elif [ "$ITEM" == "Utilities" ]; then
					UTILS=`ls "$SRC_DIR/$ITEM/$APP"|tr " " "?"`
					for UTIL in $UTILS
					do
						UTIL=`echo $UTIL|tr "?" " "`
						if [[ "$UTIL" =~ ".app" ]]; then
							DST_UTIL="$DST_DIR/$APP $UTIL"
							echo LINK\ "$DST_UTIL"
							ln -s "$SRC_DIR/$ITEM/$APP/$UTIL" "$DST_UTIL"
						fi
					done
				fi
			done
		fi
	fi
done

defaults write com.apple.dock ResetLaunchPad -bool true
killall Dock
