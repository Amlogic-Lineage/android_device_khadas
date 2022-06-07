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
#ATV version, need compile DRM related modules
ifneq ($(BOARD_COMPILE_ATV),false)
  BOARD_COMPILE_CTS := true
endif

PRODUCT_DIR := kvim1s
#CONFIG_DEVICE_LOW_RAM := true
ifeq ($(CONFIG_DEVICE_LOW_RAM),true)
# Enable DM file pre-opting to reduce first boot time
PRODUCT_DEX_PREOPT_GENERATE_DM_FILES := true
PRODUCT_DEX_PREOPT_DEFAULT_COMPILER_FILTER := verify

#1G platform can't support vulkan, cts case need at least 1073741824 byte memory
BOARD_INSTALL_VULKAN := false

PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.heapgrowthlimit=160m \
    dalvik.vm.heapmaxfree=4m \
    dalvik.vm.heapsize=224m \
    dalvik.vm.heapstartsize=4m

# config of surfaceflinger
PRODUCT_PRODUCT_PROPERTIES += \
    ro.surface_flinger.max_frame_buffer_acquired_buffers=3 \
    ro.sf.disable_triple_buffer=0

# Inherit Go default properties, sets is-low-ram-device flag etc.
#call build/make/target/product/go_defaults.mk
PRODUCT_PROPERTY_OVERRIDES += \
     ro.config.low_ram=true \
     ro.config.max_starting_bg=4

# Speed profile services and wifi-service to reduce RAM and storage.
PRODUCT_SYSTEM_SERVER_COMPILER_FILTER := speed-profile

# Always preopt extracted APKs to prevent extracting out of the APK for gms
# modules.
PRODUCT_ALWAYS_PREOPT_EXTRACTED_APK := true

# Use a profile based boot image for this device. Note that this is currently a
# generic profile and not Android Go optimized.
PRODUCT_USE_PROFILE_FOR_BOOT_IMAGE := true
PRODUCT_DEX_PREOPT_BOOT_IMAGE_PROFILE_LOCATION := frameworks/base/config/boot-image-profile.txt

# Do not generate libartd.
#PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Disable Scudo outside of eng builds to save RAM.
ifneq (,$(filter eng, $(TARGET_BUILD_VARIANT)))
  PRODUCT_DISABLE_SCUDO := true
endif

# Add the system properties.
PRODUCT_PROPERTY_OVERRIDES += \
	ro.lmk.critical_upgrade=true \
	ro.lmk.upgrade_pressure=40 \
	ro.lmk.downgrade_pressure=60 \
	ro.lmk.kill_heaviest_task=false \
	pm.dexopt.downgrade_after_inactive_days=10 \
	pm.dexopt.shared=quicken

# Dedupe VNDK libraries with identical core variants.
TARGET_VNDK_USE_CORE_VARIANT := true
# Inherit Go default properties end

# Reduces GC frequency of foreground apps by 50%
#PRODUCT_PROPERTY_OVERRIDES += dalvik.vm.foreground-heap-growth-multiplier=2.0

#DONT_UNCOMPRESS_PRIV_APPS_DEXS := true

# use malloc svelet to save memory
MALLOC_SVELTE := true

# Reduces GC frequency of foreground apps by 50%
# Too much GC may impact performance
PRODUCT_PROPERTY_OVERRIDES += dalvik.vm.foreground-heap-growth-multiplier=2.0

#disable jit
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
	dalvik.vm.usejitprofiles=false \
	dalvik.vm.usejit=false

endif
ifeq ($(BOARD_COMPILE_ATV), false)
#config of AM301 1080P UI surfaceflinger
PRODUCT_PRODUCT_PROPERTIES += \
    ro.surface_flinger.max_graphics_width=1920  \
    ro.surface_flinger.max_graphics_height=1080 \
    ro.sf.lcd_density=240
endif


########################################################################
#
##                            HDR
#
#########################################################################
#hdr10_tmo
HDR10_TMO_MODULE := true
include device/khadas/common/video_algorithm/hdr10_tmo/hdr10_tmo.mk

########################################################################
#
#                            TV
#
########################################################################
TARGET_BUILD_LIVETV := true
#TARGET_BUILD_IRDETO := true
ifeq ($(TARGET_BUILD_LIVETV),true)
PRODUCT_PACKAGES += \
    droidlogic.tv.software.core.xml

#KVIM1S app
PRODUCT_PACKAGES += \
    FactoryTest \
    SchPwrOnOff

#dvbstack
BOARD_HAS_ADTV := true
#tuner
ifeq ($(TARGET_PRODUCT),oppen_mxl258c)
TUNER_MODULE := mxl258c
else
TUNER_MODULE := cxd2856 r836 av2018
endif
include device/khadas/common/tuner/tuner.mk

TARGET_BUILD_LIBDVR := true
ifeq ($(TARGET_BUILD_LIBDVR),true)
PRODUCT_PACKAGES += \
    libamdvr
endif

#dtvkit
ifneq ($(TARGET_BUILD_IRDETO),true)
PRODUCT_SUPPORT_DTVKIT := true
SUPPORT_DTVKIT_IN_VENDOR := true
endif
endif

ifeq ($(PRODUCT_SUPPORT_DTVKIT),true)

#PRODUCT_SUPPORT_DTVKIT_PIP := true
#PRODUCT_SUPPORT_DTVKIT_FCC := true

ifeq ($(PRODUCT_SUPPORT_DTVKIT_PIP),true)
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.tv.dtv.pipfcc.architecture=true \
    vendor.amtsplayer.pipeline=1 \
    vendor.tv.dtv.enable.pip=true
endif

ifeq ($(PRODUCT_SUPPORT_DTVKIT_FCC),true)
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.tv.dtv.pipfcc.architecture=true \
    vendor.amtsplayer.pipeline=1 \
    vendor.tv.dtv.enable.fcc=true
endif

endif#dtvkit

ifeq ($(CONFIG_DEVICE_LOW_RAM),true)
BOARD_ENABLE_FAR_FIELD_AEC := false
else
BOARD_ENABLE_FAR_FIELD_AEC := true
endif

$(call inherit-product, device/khadas/common/products/mbox/product_mbox.mk)
$(call inherit-product, device/khadas/$(PRODUCT_DIR)/device.mk)
$(call inherit-product, device/khadas/$(PRODUCT_DIR)/vendor_prop.mk)
$(call inherit-product-if-exists, vendor/amlogic/$(PRODUCT_DIR)/device-vendor.mk)

#########################################################################
#
#                                                CTC
#
#########################################################################
BUILD_WITH_CTC_MEDIAPROCESSOR := true

#########################################################################
#
#  Amlogic Media Platform API
#
#########################################################################
BUILD_WITH_AML_MP := true

#########################################################################
#
#  Media extension
#
#########################################################################
#TARGET_WITH_MEDIA_EXT_LEVEL := 4


PRODUCT_NAME := $(TARGET_PRODUCT)
PRODUCT_DEVICE := $(TARGET_PRODUCT)
PRODUCT_BRAND := Droidlogic
PRODUCT_MODEL := $(TARGET_PRODUCT)
PRODUCT_MANUFACTURER := Droidlogic

PRODUCT_TYPE := mbox

BOARD_AML_VENDOR_PATH := vendor/amlogic/common/
BOARD_WIDEVINE_TA_PATH := vendor/amlogic/

OTA_UP_PART_NUM_CHANGED := true

PLATFORM_TDK_VERSION := 38
BOARD_AML_SOC_TYPE ?= S905Y4
BOARD_AML_TDK_KEY_PATH := device/khadas/common/tdk_keys/
BUILD_WITH_AVB := true
BUILD_WITH_UDC := false
BOARD_USES_VBMETA_SYSTEM := true

AB_OTA_UPDATER ?=true
BOARD_USES_ODM_EXTIMAGE := true

ifeq ($(AB_OTA_UPDATER),true)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)
endif

BUILDING_VENDOR_BOOT_IMAGE ?= true

PRODUCT_USE_DYNAMIC_PARTITIONS := true
#BOARD_BUILD_SYSTEM_ROOT_IMAGE := true

#########################################################################
#
#  SECURE BOOT V3
#
#########################################################################
#########Support compiling out encrypted zip/aml_upgrade_package.img directly

#need be modified later
ifeq ($(TARGET_PRODUCT),newton)
BOARD_AML_SECUREBOOT_KEY_DIR := ./bootloader/uboot-repo/bl33/v2015/board/amlogic/sm1_ac215_v1/aml-key
else ifeq ($(TARGET_PRODUCT),newton_hybrid)
BOARD_AML_SECUREBOOT_KEY_DIR := ./bootloader/uboot-repo/bl33/v2015/board/amlogic/sm1_ac232_v1/aml-key
else ifeq ($(TARGET_PRODUCT),ac212)
BOARD_AML_SECUREBOOT_KEY_DIR := ./bootloader/uboot-repo/bl33/v2015/board/amlogic/sm1_ac212_v1/aml-key
else
BOARD_AML_SECUREBOOT_KEY_DIR := ./bootloader/uboot-repo/bl33/v2015/board/amlogic/sm1_ac214_v1/aml-key
endif

BOARD_AML_SECUREBOOT_SOC_TYPE := sc2

PRODUCT_GOOGLEREF_SECURE_BOOT := false
ifeq ($(PRODUCT_GOOGLEREF_SECURE_BOOT),true)
PRODUCT_GOOGLEREF_SECURE_BOOT_TOOL := ./device/khadas/$(PRODUCT_DIR)/tools/amlogic-sign-oppen.sh
endif

#########################################################################
#
#  Dm-Verity
#
#########################################################################
#TARGET_USE_SECURITY_DM_VERITY_MODE_WITH_TOOL := true

#########################################################################
#
#                      WiFi and Bluetooth
#
#########################################################################
include vendor/amlogic/common/wifi_bt/wifi/configs/wifi.mk
BOARD_HAVE_BLUETOOTH := true
include vendor/amlogic/common/wifi_bt/bluetooth/configs/bluetooth.mk

#########################################################################
#
# Audio
#
#########################################################################
BOARD_ALSA_AUDIO=tiny
include device/khadas/common/audio.mk

#########################################################################
#
#  PlayReady DRM
#
#########################################################################
#export BOARD_PLAYREADY_LEVEL=3 for PlayReady+NOTVP
#export BOARD_PLAYREADY_LEVEL=1 for PlayReady+OPTEE+TVP

#########################################################################
#
#  Verimatrix DRM
#
##########################################################################
#verimatrix web
BUILD_WITH_VIEWRIGHT_WEB := false
#verimatrix stb
BUILD_WITH_VIEWRIGHT_STB := false

#########################################################################

#########################################################################
#
#  WifiDisplay
#
##########################################################################
ifeq ($(BOARD_COMPILE_ATV), false)
BUILD_WITH_MIRACAST := true
endif

#########################################################################

########################################################################
#
#                        dsp_util
#
########################################################################
PRODUCT_PACKAGES += \
    dsp_util \
    hifi4_rpc_test \
    hifi4rpc_client_test

########################################################################
#
#                          Netflix
#
#########################################################################
#TARGET_BUILD_NETFLIX:= true
#TARGET_BUILD_NETFLIX_MGKID := true
#TARGET_BUILD_NETFLIX_MODELGROUP:= XXXXX

ifeq ($(TARGET_BUILD_NETFLIX), true)
BOARD_ENABLE_FAR_FIELD_AEC := false
endif
########################################################################
#
#                          Audio License Decoder
#
########################################################################
TARGET_DOLBY_MS12_VERSION := 2
ifeq ($(TARGET_DOLBY_MS12_VERSION), 2)
    TARGET_BUILD_DOLBY_MS12_V2 := true
else
    #TARGET_BUILD_DOLBY_MS12 := true
endif

#TARGET_BUILD_DOLBY_DDP := true
TARGET_BUILD_DTSHD := true

#################################################################################
#
#  DEFAULT LOWMEMORYKILLER CONFIG
#
#################################################################################
BUILD_WITH_LOWMEM_COMMON_CONFIG := true

BOARD_USES_USB_PM := true

#########################################################################
#
#           OEM Partitions based dynamic fingerprint
#
#########################################################################
BOARD_USES_DYNAMIC_FINGERPRINT ?= true

#########################################################################
#
#                                     TB detect
#
#########################################################################
$(call inherit-product, device/khadas/common/tb_detect.mk)

ifeq ($(AB_OTA_UPDATER),true)
my_src_fstab := fstab.ab
else
my_src_fstab := fstab.system
endif

ifeq ($(BOARD_USES_DYNAMIC_FINGERPRINT),true)
my_src_fstab := $(my_src_fstab)_oem
endif

my_dst_fstab := $(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.amlogic

PRODUCT_COPY_FILES += \
    device/khadas/$(PRODUCT_DIR)/$(my_src_fstab).amlogic:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.amlogic \
    device/khadas/$(PRODUCT_DIR)/$(my_src_fstab).amlogic:$(my_dst_fstab)

BOARD_ENABLE_LIGHT_CONTROL := true

$(call inherit-product, device/khadas/common/media.mk)

include device/khadas/common/gpu/dvalin-user-arm64.mk

include device/khadas/common/products/mbox/s4/s4.mk
#########################################################################
#
##                                     Auto Patch
#                          must put in the end of mk files
##########################################################################
AUTO_PATCH_SHELL_FILE := vendor/amlogic/common/pre_submit_for_google/auto_patch.sh
HAVE_WRITED_SHELL_FILE := $(shell test -f $(AUTO_PATCH_SHELL_FILE) && echo yes)
IS_REFERENCE_PROJECT := true

ifeq ($(IS_REFERENCE_PROJECT), true)
REFERENCE_PARAMS := true
else
REFERENCE_PARAMS := false
endif

ifneq ($(BOARD_COMPILE_ATV), false)
ATV_PARAMS := true
else
ATV_PARAMS := false
endif

ifeq ($(TARGET_BUILD_LIVETV), true)
LIVETV_PARAMS := true
else
LIVETV_PARAMS := false
endif

ifeq ($(HAVE_WRITED_SHELL_FILE),yes)
SCRIPT_RESULT :=$(shell ($(AUTO_PATCH_SHELL_FILE) $(REFERENCE_PARAMS) $(LIVETV_PARAMS)  $(ATV_PARAMS) ))
ifeq ($(filter Error,$(SCRIPT_RESULT)), Error)
$(error $(SCRIPT_RESULT))
else
$(warning $(SCRIPT_RESULT))
endif
endif

#########################################################################
#
#                  ueventd parallel restorecon dirs
#
#
#########################################################################
PRODUCT_COPY_FILES += \
    device/khadas/$(PRODUCT_DIR)/ueventd.parallel.rc:$(TARGET_COPY_OUT_ODM)/ueventd.rc
