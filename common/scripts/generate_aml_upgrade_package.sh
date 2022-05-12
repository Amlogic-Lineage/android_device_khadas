#!/bin/bash

# Copyright 2018 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

usage () {
    echo
    echo "Generate aml_upgrade_package.img with aml_image_v2_packer tool."
    echo
    echo "Usage: $0 image_dir target_name output"
    echo
    echo "image_dir is the path to the unpacked images, which could be $OUT, "
    echo "    or manually unzipped from <target>-img*.zip. bootloader.img "
    echo "    should be also available in the dir."
    echo "target_name is the target, e.g. \"atom\"."
    echo "output is the output filename, e.g. \"aml_upgrade_package.img\"."
    echo
    echo "For example:"
    echo "  $0 images atom aml_upgrade_package.img"
    echo
    echo "Note that the script should be run in the top-level dir of the "
    echo "Android tree."
}

exit_badparam () {
    echo "ERROR: $1" >&2
    usage
    exit 1
}

cleanup_and_exit () {
    readonly result="$?"
    rm -rf "$TEMP_DIR"
    exit "$result"
}

if [[ $# -lt 3 ]]; then
    exit_badparam "Unexpected number of arguments"
fi

readonly IMAGES_DIR="$1"
readonly TARGET_NAME="$2"
readonly OUTPUT="$3"
if [[ $# -gt 3 ]]; then
    readonly TARGET_SIGNED="$4"
fi

# Map the target name to device dir.
if [ "$TARGET_NAME" = "atom" ]
then
    DEVICE_DIR=device/harman/atom/upgrade
else
    exit_badparam "Unsupported target name $TARGET_NAME"
fi

readonly AMLOGIC_COMMON_DIR=device/khadas/common
readonly AMLOGIC_IMAGE_PACKER=vendor/amlogic/common/tools/aml_upgrade/aml_image_v2_packer
readonly TEMP_DIR="$(mktemp -d --tmpdir "$(basename $0)"_XXXXXXXX)"

# Copy all the source files to the temp dir.
cp "$DEVICE_DIR"/aml_sdc_burn.ini \
     "$DEVICE_DIR"/u-boot.bin.sd.bin \
     "$DEVICE_DIR"/u-boot.bin.usb.bl2 \
     "$DEVICE_DIR"/u-boot.bin.usb.tpl \
     "$DEVICE_DIR"/platform.conf \
     "$TEMP_DIR"

# Copy all images to be packed.
cp "$IMAGES_DIR"/boot.img \
    "$IMAGES_DIR"/bootloader.img \
    "$IMAGES_DIR"/dt.img \
    "$IMAGES_DIR"/logo.img \
    "$IMAGES_DIR"/odm.img \
    "$IMAGES_DIR"/product.img \
    "$IMAGES_DIR"/recovery.img \
    "$IMAGES_DIR"/system.img \
    "$IMAGES_DIR"/vbmeta.img \
    "$IMAGES_DIR"/vendor.img \
    "$TEMP_DIR"

if [ "$TARGET_SIGNED" = "signed" ]
then
    cp "$DEVICE_DIR"/u-boot.bin.encrypt.usb.bl2 \
        "$TEMP_DIR"/u-boot.bin.encrypt.usb.bl2
    cp "$DEVICE_DIR"/u-boot.bin.encrypt.usb.tpl \
        "$TEMP_DIR"/u-boot.bin.encrypt.usb.tpl
    cp "$DEVICE_DIR"/u-boot.bin.encrypt.sd.bin \
        "$TEMP_DIR"/u-boot.bin.encrypt.sd.bin
    cp "$TEMP_DIR"/dt.img \
        "$TEMP_DIR"/dt.img.encrypt

    mv "$TEMP_DIR"/boot.img \
        "$TEMP_DIR"/boot.img.encrypt
    mv "$TEMP_DIR"/recovery.img \
        "$TEMP_DIR"/recovery.img.encrypt
    mv "$TEMP_DIR"/bootloader.img \
        "$TEMP_DIR"/bootloader.img.encrypt

    cp "$AMLOGIC_COMMON_DIR"/products/tv/upgrade_4.9/aml_upgrade_package_avb_enc.conf "$TEMP_DIR"

    # Trigger the packer.
    "$AMLOGIC_IMAGE_PACKER" \
        -r "$TEMP_DIR"/aml_upgrade_package_avb_enc.conf \
        "$TEMP_DIR" \
        "$OUTPUT"
else
    cp "$AMLOGIC_COMMON_DIR"/products/tv/upgrade_4.9/aml_upgrade_package_avb.conf "$TEMP_DIR"
    # Trigger the packer.
    "$AMLOGIC_IMAGE_PACKER" \
        -r "$TEMP_DIR"/aml_upgrade_package_avb.conf \
        "$TEMP_DIR" \
        "$OUTPUT"
fi
