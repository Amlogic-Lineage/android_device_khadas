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
# 1.for speech ko file copy
#======================================================================================

ifeq ($(strip $(SPEECH_MODULE)),true)
    $(warning SPEECH_MODULE is $(SPEECH_MODULE))
    ifeq ($(TARGET_BUILD_KERNEL_4_9),true)
        ifeq ($(KERNEL_A32_SUPPORT),true)
            PRODUCT_COPY_FILES += \
                device/khadas/common/speech/32_4_9/speech_32.ko:$(PRODUCT_OUT)/obj/lib_vendor/speech.ko \
                device/khadas/common/initscripts/speech.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/speech.rc
        else
            PRODUCT_COPY_FILES += \
                device/khadas/common/speech/64_4_9/speech_64.ko:$(PRODUCT_OUT)/obj/lib_vendor/speech.ko \
                device/khadas/common/initscripts/speech.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/speech.rc
        endif
    else
        ifeq ($(KERNEL_A32_SUPPORT),true)
            PRODUCT_COPY_FILES += \
                device/khadas/common/speech/32/speech_32.ko:$(PRODUCT_OUT)/obj/lib_vendor/speech.ko \
                device/khadas/common/initscripts/speech.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/speech.rc
        else
            PRODUCT_COPY_FILES += \
                device/khadas/common/speech/64/speech_64.ko:$(PRODUCT_OUT)/obj/lib_vendor/speech.ko \
                device/khadas/common/initscripts/speech.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/speech.rc
        endif
    endif
endif
