# VersaNode OS – Kernel-level mods Pi-gen stage

<p align="center">
  <!-- Workflows -->
  <a href="https://github.com/Versa-Node/versanode-os/actions/workflows/ci.yml">
    <img src="https://github.com/Versa-Node/versanode-os/actions/workflows/ci.yml/badge.svg?branch=main" alt="CI (lint & sanity)" />
  </a>
  <a href="https://github.com/Versa-Node/versanode-os/actions/workflows/build-release.yml">
    <img src="https://github.com/Versa-Node/versanode-os/actions/workflows/build-release.yml/badge.svg?branch=main" alt="Build & Release (pi-gen)" />
  </a>
  <a href="https://github.com/Versa-Node/versanode-os/actions/workflows/pr-labeler.yml">
    <img src="https://github.com/Versa-Node/versanode-os/actions/workflows/pr-labeler.yml/badge.svg?branch=main" alt="PR Labeler" />
  </a>
  <a href="https://github.com/Versa-Node/versanode-os/actions/workflows/release-drafter.yml">
    <img src="https://github.com/Versa-Node/versanode-os/actions/workflows/release-drafter.yml/badge.svg?branch=main" alt="Release Drafter" />
  </a>
</p>

<p align="center">
  <img src="docs/media/logo-white.png" alt="VersaNode OS logo" width="50%"/>
</p>

---
## 🔧 Overview

The **VersaNode OS Kernel-level Mod Stage** enables **I²C**, **SPI**, and **1‑Wire** interfaces and drops a udev rule —
all without using `on_chroot`. Every modification is applied directly to
**`${ROOTFS_DIR}`**, making it safe for automated builds and reproducible images.

---

## 🚀 What It Does

- Adds or updates the following entries in `${ROOTFS_DIR}/boot/firmware/config.txt`:
  ```ini
  dtparam=i2c_arm=on
  dtparam=spi=on
  dtoverlay=w1-gpio
  ```
- Installs I/O toolchain packages via **00-packages** (handled automatically by pi-gen):
  - `i2c-tools`
  - `python3-smbus`
  - `spi-tools`
- Drops a **udev rule** to grant the `plugdev` group access to I2C and SPI device nodes.

---

## 📂 File Structure

```
stage2-kmods/
  00-versanode-bus-io/
    00-packages
    00-run.sh
    files/
      etc/udev/rules.d/99-versa-bus.rules
```

---

## ♻️ Notes

- **Idempotent:** re-runs won’t duplicate lines in `config.txt`.
- Compatible with both **Raspberry Pi OS Lite** and **custom pi-gen derivatives**.
- No root filesystem mounting tricks required — everything is path-relative.
