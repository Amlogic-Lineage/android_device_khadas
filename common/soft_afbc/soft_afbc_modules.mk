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

ifeq ($(KERNEL_A32_SUPPORT),true)
	DEFAULT_SOFTAFBC_KERNEL_MODULES := \
		device/amlogic/common/soft_afbc/32/amlogic_fbc_lib.ko
else
	DEFAULT_SOFTAFBC_KERNEL_MODULES := \
		device/amlogic/common/soft_afbc/64/amlogic_fbc_lib.ko
endif
