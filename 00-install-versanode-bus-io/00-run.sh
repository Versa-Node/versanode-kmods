#!/bin/bash -e
# No-chroot variant: edit files under ${ROOTFS_DIR}

BOOTCFG="${ROOTFS_DIR}/boot/firmware/config.txt"
mkdir -p "$(dirname "${BOOTCFG}")"
touch "${BOOTCFG}"

add_or_replace() {
  local key="$1"
  local line="$2"
  if grep -qE "^(#\s*)?${key}(=|$)" "${BOOTCFG}"; then
    # Replace existing (commented or not)
    sed -i -E "s|^(#\s*)?${key}.*$|${line}|" "${BOOTCFG}"
  else 
    echo "${line}" >> "${BOOTCFG}"
  fi
}
# I2C

add_or_replace "dtparam=i2c_arm" "dtparam=i2c_arm=on"
# SPI
add_or_replace "dtparam=spi" "dtparam=spi=on"
# 1-Wire (GPIO4 by default)
grep -q "^dtoverlay=w1-gpio" "${BOOTCFG}" || echo "dtoverlay=w1-gpio" >> "${BOOTCFG}"

# udev rule is delivered via files/ overlay:
#   files/etc/udev/rules.d/99-versa-bus.rules
# pi-gen copies it into ${ROOTFS_DIR}. Nothing to do here.

echo ">> bus-io: updated ${BOOTCFG} (tail)"
tail -n 50 "${BOOTCFG}" || true
