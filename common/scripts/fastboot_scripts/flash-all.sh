#!/bin/bash

# Copyright 2012 The Android Open Source Project
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

set -e
cd $(dirname $0)

lflag="unlock"
if [[ $# -gt 0 ]]; then
    lflag="$1"
fi

sern=""
if [[ $# -gt 1 ]]; then
    sern="-s $2"
fi

skipreboot=""
if [[ $# -gt 2 ]]; then
    skipreboot="$3"
fi

if [ "$skipreboot" != "skip" ]
then
    # Ignore failure, in case we are already in fastboot.
    adb $sern reboot bootloader || true
fi

function flash_with_retry() {
  local partition=${1};
  local img=${2};
  msg=$(fastboot ${sern} flash ${partition} ${img} 2>&1)
  echo "${msg}"
  if [[ ${msg} =~ 'FAILED' ]]; then
    echo "\nFlashing ${img} is not done properly. Do it again."
    fastboot ${sern} reboot-bootloader
    fastboot ${sern} flash ${partition} ${img}
  fi
}

fastboot $sern flashing unlock
fastboot $sern flash bootloader bootloader.img
fastboot $sern flash bootloader-boot0 bootloader.img
fastboot $sern flash bootloader-boot1 bootloader.img
fastboot $sern flash dts dt.img
fastboot $sern erase env
fastboot $sern erase misc
fastboot $sern reboot-bootloader

sleep 5
fastboot $sern flashing unlock
fastboot $sern flash dtbo dtbo.img
fastboot $sern -w
fastboot $sern erase param
fastboot $sern erase tee

flash_with_retry vbmeta vbmeta.img
flash_with_retry logo logo.img
flash_with_retry odm_ext odm_ext.img
flash_with_retry boot boot.img
if [ -f oem.img ]
then
        flash_with_retry oem oem.img
fi
if [ -f vbmeta_system.img ]
then
        flash_with_retry vbmeta_system vbmeta_system.img
fi
if [ -f recovery.img ]
then
	flash_with_retry recovery recovery.img
fi
if [ -f vendor_boot.img ]
then
	flash_with_retry vendor_boot vendor_boot.img
fi
fastboot $sern reboot-fastboot
sleep 10

flash_with_retry super super_empty_all.img
flash_with_retry odm odm.img
flash_with_retry system system.img
flash_with_retry system_ext system_ext.img
flash_with_retry vendor vendor.img
flash_with_retry product product.img
fastboot $sern reboot-bootloader
sleep 5

if [ "$lflag" = "lock" ]
then
    fastboot $sern flashing lock
fi

fastboot $sern reboot
