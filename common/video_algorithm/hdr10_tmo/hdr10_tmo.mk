#
# Copyright (C) 2015 The Android Open Source Project
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

#======================================================================================
# 1.for hdr10_tmo_alg ko file copy
#======================================================================================

ifeq ($(strip $(HDR10_TMO_MODULE)),true)
    $(warning HDR10_TMO_MODULE is $(HDR10_TMO_MODULE))
    ifeq ($(TARGET_BUILD_KERNEL_4_9),true)
        ifeq ($(KERNEL_A32_SUPPORT),true)
           PRODUCT_COPY_FILES += \
               device/amlogic/common/video_algorithm/hdr10_tmo/32_4_9/hdr10_tmo_alg_32.ko:$(PRODUCT_OUT)/obj/lib_vendor/hdr10_tmo_alg.ko \
               device/amlogic/common/initscripts/hdr10_tmo.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hdr10_tmo.rc
        else
           PRODUCT_COPY_FILES += \
                device/amlogic/common/video_algorithm/hdr10_tmo/64_4_9/hdr10_tmo_alg_64.ko:$(PRODUCT_OUT)/obj/lib_vendor/hdr10_tmo_alg.ko \
                device/amlogic/common/initscripts/hdr10_tmo.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hdr10_tmo.rc
        endif
    else
        ifeq ($(KERNEL_A32_SUPPORT),true)
            PRODUCT_COPY_FILES += \
                device/amlogic/common/video_algorithm/hdr10_tmo/32/hdr10_tmo_alg_32.ko:$(PRODUCT_OUT)/obj/lib_vendor/hdr10_tmo_alg.ko \
                device/amlogic/common/initscripts/hdr10_tmo.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hdr10_tmo.rc
        else
            PRODUCT_COPY_FILES += \
                device/amlogic/common/video_algorithm/hdr10_tmo/64/hdr10_tmo_alg_64.ko:$(PRODUCT_OUT)/obj/lib_vendor/hdr10_tmo_alg.ko \
                device/amlogic/common/initscripts/hdr10_tmo.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hdr10_tmo.rc
        endif
    endif
endif
