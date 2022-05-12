SOONG_CONFIG_NAMESPACES += amlogic_vendorconfig


#for system control
SOONG_CONFIG_amlogic_vendorconfig += board_platform
SOONG_CONFIG_amlogic_vendorconfig_board_platform := $(TARGET_BOARD_PLATFORM)
SOONG_CONFIG_amlogic_vendorconfig += hwc_dynamic_switch_viu
SOONG_CONFIG_amlogic_vendorconfig_hwc_dynamic_switch_viu := $(HWC_DYNAMIC_SWITCH_VIU)
SOONG_CONFIG_amlogic_vendorconfig += build_livetv
SOONG_CONFIG_amlogic_vendorconfig_build_livetv := $(TARGET_BUILD_LIVETV)

# for alsa library
SOONG_CONFIG_amlogic_vendorconfig += build_alsa_audio
SOONG_CONFIG_amlogic_vendorconfig_build_alsa_audio := $(BOARD_ALSA_AUDIO)


#SUPPORT_HDMIIN := true
SOONG_CONFIG_amlogic_vendorconfig += support_hdmiin
SOONG_CONFIG_amlogic_vendorconfig_support_hdmiin := $(SUPPORT_HDMIIN)


SOONG_CONFIG_amlogic_vendorconfig += custom_mediaserver_extensions
SOONG_CONFIG_amlogic_vendorconfig_custom_mediaserver_extensions := $(BOARD_USE_CUSTOM_MEDIASERVEREXTENSIONS)



SOONG_CONFIG_amlogic_vendorconfig += ddlib_from_customer
SOONG_CONFIG_amlogic_vendorconfig_ddlib_from_customer := $(TARGET_DDLIB_BUILT_FROM_CUSTOMER)

SOONG_CONFIG_amlogic_vendorconfig += build_livetv_from_source
SOONG_CONFIG_amlogic_vendorconfig_build_livetv_from_source := $(TARGET_LIVETV_BUILT_FROM_SOURCE)


SOONG_CONFIG_amlogic_vendorconfig += netflix_mgkid
SOONG_CONFIG_amlogic_vendorconfig_netflix_mgkid := $(TARGET_BUILD_NETFLIX_MGKID)

# for ta sign related

ifeq ($(PLATFORM_TDK_VERSION),)
PLATFORM_TDK_VERSION := 24
endif
SOONG_CONFIG_amlogic_vendorconfig += tdk_version
SOONG_CONFIG_amlogic_vendorconfig_tdk_version := TDK$(PLATFORM_TDK_VERSION)

SOONG_CONFIG_amlogic_vendorconfig += enable_ta_sign
SOONG_CONFIG_amlogic_vendorconfig_enable_ta_sign := $(TARGET_ENABLE_TA_SIGN)

SOONG_CONFIG_amlogic_vendorconfig += enable_ta_encrypt
SOONG_CONFIG_amlogic_vendorconfig_enable_ta_encrypt := $(TARGET_ENABLE_TA_ENCRYPT)

SOONG_CONFIG_amlogic_vendorconfig += omx_with_optee_tvp
SOONG_CONFIG_amlogic_vendorconfig_omx_with_optee_tvp := $(BOARD_OMX_WITH_OPTEE_TVP)

SOONG_CONFIG_amlogic_vendorconfig += widevine_oemcrypto_level
SOONG_CONFIG_amlogic_vendorconfig_widevine_oemcrypto_level := $(BOARD_WIDEVINE_OEMCRYPTO_LEVEL)

SOONG_CONFIG_amlogic_vendorconfig += with_playready_drm
SOONG_CONFIG_amlogic_vendorconfig_with_playready_drm := $(BUILD_WITH_PLAYREADY_DRM)

SOONG_CONFIG_amlogic_vendorconfig += playready_tvp
SOONG_CONFIG_amlogic_vendorconfig_playready_tvp := $(BOARD_PLAYREADY_TVP)

# for media_ext
SOONG_CONFIG_amlogic_vendorconfig += enable_swcodec
SOONG_CONFIG_amlogic_vendorconfig_enable_swcodec := $(TARGET_WITH_SWCODEC_EXT)