#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for m in "$ROOT/modules"/*; do
  [ -d "$m" ] || continue
  name=$(grep -E '^PACKAGE_NAME=' "$m/dkms.conf" | cut -d'"' -f2)
  ver=$(grep -E '^PACKAGE_VERSION=' "$m/dkms.conf" | cut -d'"' -f2)
  echo "==> Removing $name/$ver via DKMS"
  sudo dkms remove "$name/$ver" --all || true
done
echo "All modules removed."
