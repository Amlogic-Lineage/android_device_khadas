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
###############################################################################



###############################################################################
# !!! This line of code needs to be on the last line.
# vendor_prop.mk defines the default prop values.
# if change the default values, need define prop above.
$(call inherit-product, device/khadas/common/products/mbox/s4/vendor_prop.mk)

PRODUCT_PROPERTY_OVERRIDES += \
    ro.hdmi.device_type=4 \
    ro.hdmi.set_menu_language=false \
    persist.sys.hdmi.keep_awake=false

#media
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.media.dv.standalone.component=true
