#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr       \
                --enable-shared     \
                --without-ensurepip \
                --without-static-libpython
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}