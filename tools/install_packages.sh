#!/usr/bin/env bash
# Copyright (c) 2026 iiPython

set -euo pipefail

: "${ROOTFS:=$(realpath rootfs)}"

env -i \
    ROOTFS="$ROOTFS" \
    PATH="$ROOTFS/toolchain/bin:/usr/bin:/bin" \
    LC_ALL=POSIX \
    CONFIG_SITE="$ROOTFS/usr/share/config.site" \
    MAKEFLAGS="-j$(nproc)" \
    python3 tools/lx.py \
        --root-dir "$ROOTFS" \
        --temp-dir "$PWD/temp" \
        --sources-dir "$PWD/packages" \
        --config-dir "$ROOTFS/var/lx" \
        $1
