#!/bin/bash

readonly oppenDIR=device/amlogic/oppen
readonly TOOLS_DIR="$NEWTONDIR"/tools
readonly KEY_DIR="$oppenDIR"/recovery/releasetools/keys
readonly DEVICE_DIR="$oppenDIR"/upgrade
readonly UBOOT_DIR="$oppenDIR"/prebuilt/bootloader
readonly UBOOT_DIR_OUT="out/target/product/oppen"


#generate bootloader.img.encrypt & bootloader.img.encrypt.encrypt.efuse

"$TOOLS_DIR"/amlogic-sign-g12a.sh \
		-s g12a \
		-p  "$UBOOT_DIR"/  \
		-r "$KEY_DIR"/ \
		-a "$KEY_DIR"/  \
		-b "$DEVICE_DIR"/fw_arb.txt \
		-o  "$UBOOT_DIR_OUT"

mv "$UBOOT_DIR_OUT"/u-boot.bin.signed.encrypted "$UBOOT_DIR_OUT"/u-boot.bin.signed
mv "$UBOOT_DIR_OUT"/u-boot.bin.signed.encrypted.sd.bin "$UBOOT_DIR_OUT"/u-boot.bin.sd.signed
mv "$UBOOT_DIR_OUT"/u-boot.bin.usb.bl2.signed.encrypted "$UBOOT_DIR_OUT"/u-boot.bin.usb.bl2.signed
mv "$UBOOT_DIR_OUT"/u-boot.bin.usb.tpl.signed.encrypted "$UBOOT_DIR_OUT"/u-boot.bin.usb.tpl.signed

mv "$UBOOT_DIR_OUT"/u-boot.bin.unsigned "$UBOOT_DIR_OUT"/u-boot.bin
mv "$UBOOT_DIR_OUT"/u-boot.bin.unsigned.sd.bin "$UBOOT_DIR_OUT"/u-boot.bin.sd
mv "$UBOOT_DIR_OUT"/u-boot.bin.usb.bl2.unsigned "$UBOOT_DIR_OUT"/u-boot.bin.usb.bl2
mv "$UBOOT_DIR_OUT"/u-boot.bin.usb.tpl.unsigned "$UBOOT_DIR_OUT"/u-boot.bin.usb.tpl

mv "$UBOOT_DIR_OUT"/u-boot.bin.signed "$UBOOT_DIR_OUT"/bootloader.img
cp "$UBOOT_DIR_OUT"/bootloader.img "$UBOOT_DIR_OUT"/upgrade/bootloader.img.encrypt
mv "$UBOOT_DIR_OUT"/u-boot.bin.sd.signed "$UBOOT_DIR_OUT"/upgrade/
mv "$UBOOT_DIR_OUT"/u-boot.bin.usb.bl2.signed "$UBOOT_DIR_OUT"/upgrade/
mv "$UBOOT_DIR_OUT"/u-boot.bin.usb.tpl.signed "$UBOOT_DIR_OUT"/upgrade/

mv "$UBOOT_DIR_OUT"/u-boot.bin "$UBOOT_DIR_OUT"/upgrade/bootloader.img
mv "$UBOOT_DIR_OUT"/u-boot.bin.sd "$UBOOT_DIR_OUT"/upgrade/
mv "$UBOOT_DIR_OUT"/u-boot.bin.usb.bl2 "$UBOOT_DIR_OUT"/upgrade/
mv "$UBOOT_DIR_OUT"/u-boot.bin.usb.tpl "$UBOOT_DIR_OUT"/upgrade/


