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
# 1.for dnlp_alg ko file copy
#======================================================================================

ifeq ($(strip $(DNLP_MODULE)),true)
    $(warning DNLP_MODULE is $(DNLP_MODULE))
    ifeq ($(TARGET_BUILD_KERNEL_4_9),true)
        ifeq ($(KERNEL_A32_SUPPORT),true)
           PRODUCT_COPY_FILES += \
               device/amlogic/common/video_algorithm/dnlp/32_4_9/dnlp_alg_32.ko:$(PRODUCT_OUT)/obj/lib_vendor/dnlp_alg.ko \
               device/amlogic/common/initscripts/dnlp.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/dnlp.rc
        else
           PRODUCT_COPY_FILES += \
                device/amlogic/common/video_algorithm/dnlp/64_4_9/dnlp_alg_64.ko:$(PRODUCT_OUT)/obj/lib_vendor/dnlp_alg.ko \
                device/amlogic/common/initscripts/dnlp.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/dnlp.rc
        endif
    else
        ifeq ($(KERNEL_A32_SUPPORT),true)
            PRODUCT_COPY_FILES += \
                device/amlogic/common/video_algorithm/dnlp/32/dnlp_alg_32.ko:$(PRODUCT_OUT)/obj/lib_vendor/dnlp_alg.ko \
                device/amlogic/common/initscripts/dnlp.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/dnlp.rc
        else
            PRODUCT_COPY_FILES += \
                device/amlogic/common/video_algorithm/dnlp/64/dnlp_alg_64.ko:$(PRODUCT_OUT)/obj/lib_vendor/dnlp_alg.ko \
                device/amlogic/common/initscripts/dnlp.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/dnlp.rc
        endif
    endif
endif
