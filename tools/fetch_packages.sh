#!/usr/bin/env bash
# Copyright (c) 2026 iiPython

set -euo pipefail

: "${ROOTFS:=$(realpath rootfs)}"

sudo python3 tools/lx.py \
    --root-dir "$ROOTFS" \
    --temp-dir "$ROOTFS/tmp/lx" \
    --sources-dir "$PWD/packages" \
    --config-dir "$ROOTFS/var/lx" \
    --fetch $1
