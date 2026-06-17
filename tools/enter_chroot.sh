#!/usr/bin/env bash
# Copyright (c) 2026 iiPython

set -euo pipefail

: "${ROOTFS:=$(realpath rootfs)}"

sudo chroot "$ROOTFS" /usr/bin/env -i \
    HOME=/root \
    TERM="${TERM:-xterm}" \
    PS1='(iipython-linux) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin:/usr/local/bin \
    MAKEFLAGS="-j$(nproc)" \
    TESTSUITEFLAGS="-j$(nproc)" \
    /usr/bin/bash --login