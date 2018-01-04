#!/bin/sh

# https://blog.agchapman.com/using-qemu-to-emulate-a-raspberry-pi/
# https://github.com/dhruvvyas90/qemu-rpi-kernel
# http://www.cnblogs.com/chengchen/p/6751420.html
# http://tuntaposx.sourceforge.net/
# http://drupal.bitfunnel.net/drupal/macosx-bridge-qemu

sudo qemu-system-arm \
-kernel ./kernel-qemu-4.4.34-jessie \
-append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" \
-hda ~/Downloads/raspbian-stretch-lite.qcow \
-cpu arm1176 -m 256 \
-M versatilepb \
-serial stdio \
-net nic -net user \
-net tap,ifname=tap0,script=no,downscript=no

#-net nic,model=virtio,macaddr=54:54:00:55:55:55 \
#-net tap,script=./tap-up.sh,downscript=./tap-down.sh
