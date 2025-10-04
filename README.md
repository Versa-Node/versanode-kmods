# versanode-kmods (Multiple DKMS Kernel Modules)

A collection of small example Linux kernel modules, each packaged for **DKMS** so they rebuild automatically on kernel updates.
Intended for Raspberry Pi and other Debian-based systems, but portable to any Linux with DKMS.

## Layout
```
modules/
  hellopi/        # misc device: /dev/hellopi (greeting string)
  versatime/      # procfs: /proc/versatime shows jiffies & uptime
scripts/
  dkms-install-all.sh
  dkms-remove-all.sh
```

Each subdirectory in `modules/` is a **self-contained DKMS module** with its own `dkms.conf`, `Makefile`, and sources.

## Install *all* modules (DKMS)
```bash
sudo apt-get update && sudo apt-get install -y build-essential dkms raspberrypi-kernel-headers
./scripts/dkms-install-all.sh
```

## Remove *all* modules
```bash
./scripts/dkms-remove-all.sh
```

## Install a single module (example: hellopi)
```bash
cd modules/hellopi
sudo dkms add .
sudo dkms build hellopi/1.0
sudo dkms install hellopi/1.0
```

## License
Each module uses GPL-2.0 (same as the Linux kernel). See `LICENSES/GPL-2.0-only.txt`.
