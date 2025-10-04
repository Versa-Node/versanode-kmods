#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for m in "$ROOT/modules"/*; do
  [ -d "$m" ] || continue
  name=$(grep -E '^PACKAGE_NAME=' "$m/dkms.conf" | cut -d'"' -f2)
  ver=$(grep -E '^PACKAGE_VERSION=' "$m/dkms.conf" | cut -d'"' -f2)
  echo "==> Installing $name/$ver via DKMS"
  sudo dkms add "$m"
  sudo dkms build "$name/$ver"
  sudo dkms install "$name/$ver" || true
done
echo "All modules installed (or already present)."
