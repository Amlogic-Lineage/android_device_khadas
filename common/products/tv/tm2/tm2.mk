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

########################################################################
#
#                          Netflix
#
########################################################################
ifeq ($(TARGET_BUILD_NETFLIX), true)
TARGET_WITH_VP9_NETFLIX:= true
$(call inherit-product-if-exists, device/amlogic/common/netflix/nts.mk)
PRODUCT_COPY_FILES += \
    device/amlogic/common/droidlogic.software.netflix.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/droidlogic.software.netflix.xml
endif

########################################################################

########################################################################
# Dynamic enable start/stop zygote_secondary in 64bits
# and 32bit system, default closed
# TARGET_DYNAMIC_ZYGOTE_SECONDARY_ENABLE := true

# Inherit from those products. Most specific first.
########################################################################
ifeq ($(ANDROID_BUILD_TYPE), 64)
ifeq ($(TARGET_DYNAMIC_ZYGOTE_SECONDARY_ENABLE), true)
$(call inherit-product, device/amlogic/common/dynamic_zygote_seondary/dynamic_zygote_64_bit.mk)
else
$(call inherit-product, build/target/product/core_64_bit.mk)
endif
endif
########################################################################

#########################################################################
#
#                     media ext
#
#########################################################################
ifeq ($(TARGET_WITH_MEDIA_EXT_LEVEL), 1)
    TARGET_WITH_MEDIA_EXT :=true
    TARGET_WITH_SWCODEC_EXT := true
else
ifeq ($(TARGET_WITH_MEDIA_EXT_LEVEL), 2)
    TARGET_WITH_MEDIA_EXT :=true
    TARGET_WITH_CODEC_EXT := true
else
ifeq ($(TARGET_WITH_MEDIA_EXT_LEVEL), 3)
    TARGET_WITH_MEDIA_EXT :=true
    TARGET_WITH_SWCODEC_EXT := true
    TARGET_WITH_CODEC_EXT := true
else
ifeq ($(TARGET_WITH_MEDIA_EXT_LEVEL), 4)
    TARGET_WITH_MEDIA_EXT :=true
    TARGET_WITH_SWCODEC_EXT := true
    TARGET_WITH_CODEC_EXT := true
    TARGET_WITH_PLAYERS_EXT := true
endif
endif
endif
endif
#########################################################################

PRODUCT_COPY_FILES += \
    device/amlogic/common/products/tv/tm2/files/sadConfig.xml:$(TARGET_COPY_OUT_VENDOR)/etc/sadConfig.xml

#########################################################################
#
#                    AVB
#
#########################################################################
ifeq ($(BUILD_WITH_AVB),true)
BOARD_AVB_ENABLE := true
#BOARD_BUILD_DISABLED_VBMETAIMAGE := true
BOARD_AVB_ALGORITHM := SHA256_RSA2048
BOARD_AVB_KEY_PATH := device/amlogic/common/security/testkey_rsa2048.pem
BOARD_AVB_ROLLBACK_INDEX := 0

ifneq ($(AB_OTA_UPDATER),true)
BOARD_AVB_RECOVERY_KEY_PATH := device/amlogic/common/security/testkey_rsa2048.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA2048
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 2
endif
endif

#########################################################################

#########################################################################
#
#                    SECURE BOOT V3
#
#########################################################################
ifeq ($(PRODUCT_AML_SECURE_BOOT_VERSION3),true)
PRODUCT_AML_SECUREBOOT_RSAKEY_DIR := ./bootloader/uboot-repo/bl33/board/amlogic/$(PROCUDT_UBOOT_PARAMS)/aml-key
PRODUCT_AML_SECUREBOOT_AESKEY_DIR := ./bootloader/uboot-repo/bl33/board/amlogic/$(PROCUDT_UBOOT_PARAMS)/aml-key
PRODUCT_SBV3_SIGBL_TOOL  := ./bootloader/uboot-repo/fip/stool/amlogic-sign-tl1.sh -s tm2
PRODUCT_SBV3_SIGIMG_TOOL := ./bootloader/uboot-repo/fip/stool/signing-tool-tl1/sign-boot-tl1.sh --sign-kernel -h 2
else
PRODUCT_AML_SECUREBOOT_USERKEY := ./bootloader/uboot-repo/bl33/board/amlogic/$(PROCUDT_UBOOT_PARAMS)/aml-user-key.sig
PRODUCT_AML_SECUREBOOT_SIGNTOOL := ./bootloader/uboot-repo/fip/tl1/aml_encrypt_tm2
PRODUCT_AML_SECUREBOOT_SIGNBOOTLOADER := $(PRODUCT_AML_SECUREBOOT_SIGNTOOL) --bootsig \
						--amluserkey $(PRODUCT_AML_SECUREBOOT_USERKEY) \
						--aeskey enable
PRODUCT_AML_SECUREBOOT_SIGNIMAGE := $(PRODUCT_AML_SECUREBOOT_SIGNTOOL) --imgsig \
					--amluserkey $(PRODUCT_AML_SECUREBOOT_USERKEY)
PRODUCT_AML_SECUREBOOT_SIGBIN	:= $(PRODUCT_AML_SECUREBOOT_SIGNTOOL) --binsig \
					--amluserkey $(PRODUCT_AML_SECUREBOOT_USERKEY)
endif# PRODUCT_AML_SECURE_BOOT_VERSION3 := true
#########################################################################


#########################################################################
#
#                    Dm-Verity
#
#########################################################################
ifeq ($(TARGET_USE_SECURITY_DM_VERITY_MODE_WITH_TOOL), true)
BUILD_WITH_DM_VERITY := true
endif # ifeq ($(TARGET_USE_SECURITY_DM_VERITY_MODE_WITH_TOOL), true)

ifeq ($(BUILD_WITH_DM_VERITY), true)
PRODUCT_PACKAGES += \
	libfs_mgr \
	fs_mgr \
	slideshow
endif
#########################################################################


#########################################################################
#
#                      ConsumerIr
#
#########################################################################
PRODUCT_PACKAGES += \
    consumerir.amlogic

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.consumerir.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.consumerir.xml

#consumerir hal
PRODUCT_PACKAGES += \
    android.hardware.ir@1.0-impl \
    android.hardware.ir@1.0-service

#########################################################################
#
#                      HDMIIN
#
#########################################################################
ifeq ($(SUPPORT_HDMIIN),true)
PRODUCT_PACKAGES += \
    libhdmiin \
    HdmiIn
endif
#########################################################################

#########################################################################
#
#                                                Languages
#
#########################################################################

# For all locales, $(call inherit-product, build/target/product/languages_full.mk)
PRODUCT_LOCALES := en_US en_AU en_IN fr_FR it_IT es_ES et_EE de_DE nl_NL cs_CZ pl_PL ja_JP \
  zh_TW zh_CN zh_HK ru_RU ko_KR nb_NO es_US da_DK el_GR tr_TR pt_PT pt_BR rm_CH sv_SE bg_BG \
  ca_ES en_GB fi_FI hi_IN hr_HR hu_HU in_ID iw_IL lt_LT lv_LV ro_RO sk_SK sl_SI sr_RS uk_UA \
  vi_VN tl_PH ar_EG fa_IR th_TH sw_TZ ms_MY af_ZA zu_ZA am_ET hi_IN en_XA ar_XB fr_CA km_KH \
  lo_LA ne_NP si_LK mn_MN hy_AM az_AZ ka_GE my_MM mr_IN ml_IN is_IS mk_MK ky_KG eu_ES gl_ES \
  bn_BD ta_IN kn_IN te_IN uz_UZ ur_PK kk_KZ
#################################################################################

#################################################################################
#
#                                                PPPOE
#
#################################################################################
#BUILD_WITH_PPPOE := false

ifeq ($(BUILD_WITH_PPPOE),true)
PRODUCT_PACKAGES += \
    PPPoE \
    libpppoejni \
    libpppoe \
    pppoe_wrapper \
    pppoe \
    droidlogic.frameworks.pppoe \
    droidlogic.external.pppoe \
    droidlogic.software.pppoe.xml
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.platform.has.pppoe=true
endif

#########################################################################
#
#                                    DVB
#
#########################################################################

PRODUCT_COPY_FILES += \
    device/amlogic/common/initscripts/dvb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/dvb.rc \
    device/amlogic/common/initscripts/irblaster1.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/irblaster1.rc

#########################################################################
#
#                            SEI BT Remote Control
#
#########################################################################
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,device/amlogic/common/products/mbox/g12a/files/hbg_ble/ble/b01_8.0/system/etc,vendor/etc) \
    device/amlogic/common/products/mbox/g12a/files/hbg_ble/sei/init.hbg.remote.rc:/vendor/etc/init/init.hbg.remote.rc

#########################################################################
#
#                                    HDMIRX
#
#########################################################################

PRODUCT_COPY_FILES += \
    device/amlogic/common/products/tv/tm2/files/tv/dec:$(TARGET_COPY_OUT_VENDOR)/bin/dec