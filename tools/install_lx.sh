#!/usr/bin/env bash
# Copyright (c) 2026 iiPython

set -euo pipefail

: "${ROOTFS:=$(realpath rootfs)}"

sudo install -Dm755 tools/lx.py "$ROOTFS/usr/bin/lx"

sudo mkdir -p "$ROOTFS/var/cache/lx"

sudo rm -rf "$ROOTFS/var/cache/lx/sources"
sudo cp -rv packages "$ROOTFS/var/cache/lx/sources"
