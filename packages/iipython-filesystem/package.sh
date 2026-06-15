#!/usr/bin/env bash

build() {
    return 0
}

install() {
    mkdir -pv "$LX_ROOTFS"/{etc,var}
    mkdir -pv "$LX_ROOTFS"/usr/{bin,lib,sbin}

    for i in bin lib sbin; do
        ln -sv "usr/$i" "$LX_ROOTFS/$i"
    done

    mkdir -pv "$LX_ROOTFS/lib64"
}

"$LX_STAGE"
