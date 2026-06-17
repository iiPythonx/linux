#!/usr/bin/env bash

build() {
    patch -Np1 -i ../sysvinit-patch/sysvinit-3.14-consolidated-1.patch
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}
