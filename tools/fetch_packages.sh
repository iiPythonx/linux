#!/usr/bin/env bash
# Copyright (c) 2026 iiPython

set -euo pipefail

: "${ROOTFS:=$(realpath rootfs)}"

sudo python3 tools/lx.py \
    --root-path "$ROOTFS" \
    --data-path "$ROOTFS/var/lx" \
    --fetch $@
