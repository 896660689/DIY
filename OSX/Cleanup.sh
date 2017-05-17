#!/bin/sh
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;
#chown -R admin:users .
find . -name "._*" -exec echo {} \;
find . -name ".DS_Store" -exec echo {} \;
find . -name ".AppleDouble" -exec echo {} \;
find . -name ".*"

