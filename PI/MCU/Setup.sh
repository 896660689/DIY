#!/bin/sh

1. vscode
2. platformio 黄色虫子图标
3. 加入 espeasy项目
4. 修改路由器配置 ESPEasy.ino
5. 编译 (点击下面的长得像编译的按钮)
6. esptool upload

esptool.py --port /dev/cu.SLAB_USBtoUAR write_flash 0x00000 .pioenvs/test_4096/firmware.bin  我是这么烧录的
mac上装了那个驱动, 开机 要到安全中心确认运行... 你懂的 kernelModule新的安全机制
sudo su
touch /System/Library/Extensions && kextcache -u /

# https://cn.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers