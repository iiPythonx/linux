#!/usr/bin/env bash
# Copyright (c) 2026 iiPython

set -euo pipefail

ROOTFS="$(realpath rootfs)"
mkdir -p "$ROOTFS"

# Package handling
BASE_PACKAGES=(
    m4 ncurses bash coreutils diffutils file findutils
    gawk grep gzip make patch sed tar xz binutils gcc
)

install_package() {
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
}

# Install base system
install_package iipython-filesystem
for package in "${BASE_PACKAGES[@]}"; do
    install_package $package
done

# Install lx
# cp -v tools/lx.py $ROOTFS/usr/bin/lx
# chmod +x $ROOTFS/usr/bin/lx

# Setup for chroot
# mkdir -pv $ROOTFS/{dev,proc,sys,run}
# sudo chown -R root:root $ROOTFS/{usr,var}

# sudo mount -v --bind /dev $ROOTFS/dev
# sudo mount -vt devpts devpts -o gid=5,mode=0620 $ROOTFS/dev/pts
# sudo mount -vt proc proc $ROOTFS/proc
# sudo mount -vt sysfs sysfs $ROOTFS/sys
# sudo mount -vt tmpfs tmpfs $ROOTFS/run

# if [ -h $ROOTFS/dev/shm ]; then
#     sudo install -v -d -m 1777 $ROOTFS$(realpath /dev/shm)
# else
#     sudo mount -vt tmpfs -o nosuid,nodev tmpfs $ROOTFS/dev/shm
# fi

# Chroot
# sudo chroot "$ROOTFS" /usr/bin/env -i \
#     HOME=/root                      \
#     TERM="$TERM"                    \
#     PS1='(iipython-linux) \u:\w\$ ' \
#     PATH=/usr/bin:/usr/sbin         \
#     MAKEFLAGS="-j$(nproc)"          \
#     TESTSUITEFLAGS="-j$(nproc)"     \
#     /bin/bash --login
