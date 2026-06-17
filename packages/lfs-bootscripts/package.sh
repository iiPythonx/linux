#!/usr/bin/env bash

build() {
    return 0
}

package() {
    make DESTDIR=$LX_ROOTFS install
}
