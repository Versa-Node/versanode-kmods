# stage2-kmods — VersaNode dummy DKMS module for pi-gen

This repository is a **drop-in pi-gen stage** that builds and installs a dummy
kernel module named **versanode-bus-io** via **DKMS**. Put this folder as
`pi-gen/stage2-kmods/` in your OS build and include `stage2-kmods` right after
`stage2` in `STAGE_LIST`.

It creates a simple misc device `/dev/versanode-bus-io` that currently does
nothing useful; it's a scaffold for future development.

## Usage (in your OS repo)
1. Place this repo at `pi-gen/stage2-kmods/` (or add as a submodule).
2. Ensure your pi-gen config includes it right after stage2, e.g.:
   ```
   STAGE_LIST="stage0 stage1 stage2 stage2-kmods export-image"
   ```
3. Build as usual.

## Local test on a running Pi
```bash
sudo apt-get install -y dkms raspberrypi-kernel-headers build-essential
# Copy module sources to /opt/versanode-os-kmods then run:
sudo /opt/versanode-os-kmods/scripts/dkms-install-all.sh
# Load the module:
sudo modprobe versanode-bus-io
ls -l /dev/versanode-bus-io
dmesg | tail -n 50
```

## Layout
```
stage2-kmods/
  00-kmods/
    00-packages
    00-run-chroot.sh
  files/
    opt/versanode-os-kmods/
      modules/versanode-bus-io/
        dkms.conf
        Makefile
        versanode-bus-io.c
      scripts/dkms-install-all.sh
```
