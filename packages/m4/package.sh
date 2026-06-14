#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr \
        --host=$ROOTFS        \
        --build=$(build-aux/config.guess)

    make
}

install() {
    make DESTDIR=$ROOTFS install
}

"$LX_STAGE"
