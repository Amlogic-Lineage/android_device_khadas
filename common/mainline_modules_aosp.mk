# Mainline configuration for the AOSP devices.

# Non updatable APEX
OVERRIDE_TARGET_FLATTEN_APEX := true
PRODUCT_PROPERTY_OVERRIDES += ro.apex.updatable=false

