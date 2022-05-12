# Copyright (C) 2011 Amlogic Inc
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

#
# This file is the build configuration for a full Android
# build for Meson reference board.
#

# Set display related config
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.platform.has.mbxuimode=true \
    ro.vendor.platform.has.realoutputmode=true \
    ro.vendor.platform.need.display.hdmicec=true

#camera max to 720p
#PRODUCT_PROPERTY_OVERRIDES += \
    #ro.media.camera_preview.maxsize=1280x720 \
    #ro.media.camera_preview.limitedrate=1280x720x30,640x480x30,320x240x28

#camera max to 1080p
PRODUCT_PRODUCT_PROPERTIES += \
    ro.media.camera_preview.maxsize=1920x1080 \
    ro.media.camera_preview.limitedrate=1920x1080x30,1280x720x30,640x480x30,320x240x28 \
    ro.media.camera_preview.usemjpeg=1

# screencontrol option
# The prop is used to limit record buffer size,
# expectially for software encode platform
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.screencontrol.maxbufsize=104857600

#the prop is used for enable or disable
#DD+/DD force output when HDMI EDID is not supported
#by default,the force output mode is enabled.
#Note,please do not set the prop to true by default
#only for netflix,just disable the feature.so set the prop to true
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.platform.disable.audiorawout=false

#Dolby DD+ decoder option
#this prop to for videoplayer display the DD+/DD icon when playback
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.platform.support.dolby=true
#DTS decoder option
#display dts icon when playback
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.platform.support.dts=true
#DTS-HD support prop
#PRODUCT_PROPERTY_OVERRIDES += \
    #ro.vendor.platform.support.dtstrans=true \
    #ro.vendor.platform.support.dtsmulasset=true
#DTS-HD prop end
# Enable player buildin

#platform support dolby vision
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.platform.support.dolbyvision=true \
    vendor.media.support.dolbyvision = true

# Define drm for this device
PRODUCT_PROPERTY_OVERRIDES += \
    drm.service.enabled=1

#set memory upper limit for extractor process
PRODUCT_PRODUCT_PROPERTIES += \
    ro.media.maxmem=629145600

#adb
PRODUCT_PROPERTY_OVERRIDES += \
    service.adb.tcp.port=5555

#enable/disable afbc
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.afbcd.enable=1

# low memory for 1G
#PRODUCT_PROPERTY_OVERRIDES += \
#    ro.config.low_ram=true

# crypto volume
PRODUCT_PROPERTY_OVERRIDES += \
    ro.crypto.volume.filenames_mode=aes-256-cts

# hwui
PRODUCT_PROPERTY_OVERRIDES += \
    ro.hwui.texture_cache_size=40.5f \
    ro.hwui.layer_cache_size=33.75f

# default enable sdr to hdr
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.sdr2hdr.enable=true

ifeq ($(TARGET_BUILD_LIVETV), true)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.platform.has.tuner=1
else ifeq ($(TARGET_BUILD_IRDETO), true)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.platform.has.tuner=1
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.platform.has.tuner=0
endif

ifeq ($(PRODUCT_SUPPORT_DTVKIT),true)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.platform.is.tv=1
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.platform.is.tv=0
endif

#bootvideo
#0                      |050
#^                      |
#|                      |
#0:bootanim             |
#1:bootanim + bootvideo |
#2:bootvideo + bootanim |
#3:bootvideo            |
#others:bootanim        |
#-----------------------|050
#050:default volume value, volume range 0~100
#note that the high position 0 can not be omitted
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.media.bootvideo=0050

PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.platform.hdmi.device_type=4
#disable timeshift
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.tv.dtv.tf.disable=false

#enable video and audio sync show
PRODUCT_PROPERTY_OVERRIDES += \
     vendor.media.audio.syncshow=1

#support mvc
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.media.support.mvc=true

#omx2
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.media.support.omx2=true \
    vendor.media.omx2.in_buffer=5 \
    vendor.media.omx2.support_mpeg=true \
    vendor.ionvideo.enable=1 \
    vendor.media.omx.dibypass.enable=false \
    vendor.media.omx.videolayerrotation.enable=false \
    vendor.omx2.nr.enable=true \
    vendor.omx2.di.localbuf.enable=true \
    vendor.media.omx.secure.prealloc=true

#use dv frame mode
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.media.omx.use_dv_frame=true

PRODUCT_PROPERTY_OVERRIDES += \
     ro.vendor.platform.is.dualspdif=true

# set default USB configuration
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    persist.sys.usb.config=mtp

#support hardware av1 decoder
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.platform.support.av1=true

#usb controller
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.usb.controller=fdd00000.dwc2_a

PRODUCT_PROPERTY_OVERRIDES += \
    vendor.tv.dtv.tsplayer.enable=true

