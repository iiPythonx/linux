#!/usr/bin/env bash
# Copyright (c) 2026 iiPython

set -euo pipefail

: "${ROOTFS:=$(realpath rootfs)}"

sudo mkdir -pv "$ROOTFS"/{dev,proc,sys,run}

sudo chown -R root:root "$ROOTFS"/{usr,var}

sudo mount --bind /dev "$ROOTFS/dev"

sudo mount \
    -t devpts devpts \
    "$ROOTFS/dev/pts" \
    -o gid=5,mode=0620

sudo mount -t proc proc "$ROOTFS/proc"
sudo mount -t sysfs sysfs "$ROOTFS/sys"
sudo mount -t tmpfs tmpfs "$ROOTFS/run"

if [[ -h "$ROOTFS/dev/shm" ]]; then
    sudo install -d -m 1777 "$ROOTFS$(realpath /dev/shm)"
else
    sudo mount \
        -t tmpfs \
        -o nosuid,nodev \
        tmpfs \
        "$ROOTFS/dev/shm"
fi
