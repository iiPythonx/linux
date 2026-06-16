#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr       \
                --enable-shared     \
                --without-ensurepip \
                --without-static-libpython
    make
}

install() {
    make DESTDIR=$LX_ROOTFS install
}

"$LX_STAGE"
