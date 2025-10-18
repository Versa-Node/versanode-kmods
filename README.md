# VersaNode OS Kernel/Bus I/O (pi-gen stage2-kmods, no chroot)

This stage enables I²C/SPI/1‑Wire and drops a udev rule without using `on_chroot`.
All actions are **file edits under `${ROOTFS_DIR}`**. Packages are installed via
`00-packages` (handled by pi-gen).

## What it does
- Adds/updates in `${ROOTFS_DIR}/boot/firmware/config.txt`:
  - `dtparam=i2c_arm=on`
  - `dtparam=spi=on`
  - `dtoverlay=w1-gpio`
- Installs tools via `00-packages`: `i2c-tools`, `python3-smbus`, `spi-tools`
- Installs udev rule to grant `plugdev` group access to I2C/SPI device nodes.

## Files
```
stage2-kmods/
  00-versanode-bus-io/
    00-packages
    00-run.sh
    files/
      etc/udev/rules.d/99-versa-bus.rules
```

Idempotent: re-runs won’t duplicate config lines.
