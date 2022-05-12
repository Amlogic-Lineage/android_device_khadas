# Copyright (C) 2017 Amlogic Corporation.
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

ifeq ($(TARGET_BUILD_DOLBY_MS12_V2), true)
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := dolby_fw_dolbyms12
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := bin/$(LOCAL_MODULE)
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/bin
LOCAL_INIT_RC := rc/$(LOCAL_MODULE).rc

# creates mount point
LOCAL_POST_INSTALL_CMD += \
    mkdir -p $(TARGET_OUT_ODM)/lib/ms12; \

include $(BUILD_PREBUILT)
endif
