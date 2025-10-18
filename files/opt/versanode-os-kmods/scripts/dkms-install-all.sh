#!/bin/bash
set -euo pipefail
MODS_DIR="/opt/versanode-os-kmods/modules"
[ -d "$MODS_DIR" ] || exit 0

shopt -s nullglob
for M in "$MODS_DIR"/*; do
  [ -f "$M/dkms.conf" ] || continue
  echo "==> DKMS installing: $M"
  pushd "$M" >/dev/null
  NAME=$(awk -F'"' '/^PACKAGE_NAME=/{print $2}' dkms.conf || true)
  VER=$(awk -F'"' '/^PACKAGE_VERSION=/{print $2}' dkms.conf || true)
  dkms add . || true
  if [ -n "${NAME:-}" ] && [ -n "${VER:-}" ]; then
    dkms build "${NAME}/${VER}"
    dkms install "${NAME}/${VER}" || true
  else
    dkms build .
    dkms install . || true
  fi
  popd >/dev/null
done
