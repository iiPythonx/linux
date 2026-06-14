#!/usr/bin/env bash

build() {
    make mrproper
    make headers
}

install() {
    find usr/include -type f ! -name '*.h' -delete
    mkdir -p $LX_ROOTFS/usr
    cp -rv usr/include $LX_ROOTFS/usr
}

"$LX_STAGE"
