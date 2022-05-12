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
$(warning 'Dolby MS12 2.4 will be installed')

BOARD_SEPOLICY_DIRS += \
   device/amlogic/common/dolby_ms12/install/sepolicy

PRODUCT_PACKAGES += \
    dolby_fw_dolbyms12 \

PRODUCT_COPY_FILES += \
    device/amlogic/common/dolby_ms12/install/encrypted_lib/libdolbyms12.so:odm/etc/ms12/libdolbyms12.so

endif
