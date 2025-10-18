#!/bin/bash -e
# This script runs inside the target rootfs (on_chroot).

on_chroot <<'CHROOT'
set -euxo pipefail

apt-get update
apt-get install -y --no-install-recommends   dkms build-essential raspberrypi-kernel-headers git

KMODS_ROOT="/opt/versanode-os-kmods"
MODS_DIR="${KMODS_ROOT}/modules"
HELPER="${KMODS_ROOT}/scripts/dkms-install-all.sh"

# Use helper if present, otherwise loop modules
if [ -x "${HELPER}" ]; then
  bash "${HELPER}"
else
  echo "Helper ${HELPER} not found; using generic DKMS loop."
  if [ -d "${MODS_DIR}" ]; then
    for M in "${MODS_DIR}"/*; do
      [ -f "${M}/dkms.conf" ] || continue
      echo "==> Installing DKMS module from: ${M}"
      pushd "${M}" >/dev/null
      NAME=$(awk -F'"' '/^PACKAGE_NAME=/{print $2}' dkms.conf || true)
      VER=$(awk -F'"' '/^PACKAGE_VERSION=/{print $2}' dkms.conf || true)
      dkms add . || true
      if [ -n "${NAME}" ] && [ -n "${VER}" ]; then
        dkms build "${NAME}/${VER}"
        dkms install "${NAME}/${VER}" || true
      else
        dkms build .
        dkms install . || true
      fi
      popd >/dev/null
    done
  else
    echo "No modules directory at ${MODS_DIR}; nothing to install."
  fi
fi

# Enable loading the dummy module at boot (optional; comment if undesired)
echo versanode-bus-io | tee -a /etc/modules-load.d/versanode.conf >/dev/null || true

dkms status || true
CHROOT
