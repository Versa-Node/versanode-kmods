#!/usr/bin/env bash
set -euo pipefail
set -x

: "${ROOTFS_DIR:?ROOTFS_DIR must be set}"

# Resolve paths relative to this script (robust in CI)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES_DIR="${SCRIPT_DIR}/files"

echo "── bus-io stage: begin ─────────────────────────────────────────"
echo "ROOTFS_DIR=${ROOTFS_DIR}"
echo "SCRIPT_DIR=${SCRIPT_DIR}"
echo "FILES_DIR=${FILES_DIR}"
[ -d "${FILES_DIR}" ] || { echo "❌ files/ directory not found at ${FILES_DIR}"; exit 1; }

# Choose the right config.txt location (RPi OS variants)
BOOTCFG="${ROOTFS_DIR}/boot/firmware/config.txt"
[ -e "${BOOTCFG}" ] || BOOTCFG="${ROOTFS_DIR}/boot/config.txt"

# Ensure config exists
mkdir -p "$(dirname "${BOOTCFG}")"
touch "${BOOTCFG}"

# Helper: add or replace a dtparam/dtoverlay line in config.txt
add_or_replace() {
  local key="$1"   # e.g. dtparam=i2c_arm
  local line="$2"  # e.g. dtparam=i2c_arm=on
  if grep -qE "^(#\s*)?${key}(=|$)" "${BOOTCFG}"; then
    sed -i -E "s|^(#\s*)?${key}.*$|${line}|" "${BOOTCFG}"
  else
    echo "${line}" >> "${BOOTCFG}"
  fi
}

# --- Enable I2C / SPI / 1-Wire overlays ---
add_or_replace "dtparam=i2c_arm" "dtparam=i2c_arm=on"
add_or_replace "dtparam=spi"     "dtparam=spi=on"
grep -q "^dtoverlay=w1-gpio" "${BOOTCFG}" || echo "dtoverlay=w1-gpio" >> "${BOOTCFG}"

echo ">> bus-io: updated ${BOOTCFG} (tail)"
tail -n 50 "${BOOTCFG}" || true

# ---------------------------------------------------------------------------
# Explicitly copy the udev rule from this sub-stage's files/ overlay
#   Expected: ${FILES_DIR}/etc/udev/rules.d/99-versa-bus.rules
# ---------------------------------------------------------------------------
RULE_SRC="${FILES_DIR}/etc/udev/rules.d/99-versa-bus.rules"
RULE_DST_DIR="${ROOTFS_DIR}/etc/udev/rules.d"
RULE_DST="${RULE_DST_DIR}/99-versa-bus.rules"

mkdir -p "${RULE_DST_DIR}"

if [ -f "${RULE_SRC}" ]; then
  cp -v "${RULE_SRC}" "${RULE_DST}"
  # Normalize CRLF (harmless if already LF)
  sed -i 's/\r$//' "${RULE_DST}" || true
  chmod 0644 "${RULE_DST}" || true
  echo ">> Copied udev rule to: ${RULE_DST}"
else
  echo "!! WARNING: ${RULE_SRC} not found. Skipping udev rule copy."
fi

# Show what landed
ls -l "${RULE_DST_DIR}" || true
[ -f "${RULE_DST}" ] && head -n 20 "${RULE_DST}" || true

# ---------------------------------------------------------------------------
# Make the kernel see the (new/changed) udev rules at runtime
# ---------------------------------------------------------------------------
on_chroot <<'EOF'
set -eux
udevadm control --reload
udevadm trigger || true
EOF

echo "── bus-io stage: done ───────────────────────────────────────────"
