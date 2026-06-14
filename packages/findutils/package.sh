#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr                   \
                --localstatedir=/var/lib/locate \
                --host=$LX_TARGET               \
                --build=$(build-aux/config.guess)
    make
}

install() {
    make DESTDIR=$LX_ROOTFS install
}

"$LX_STAGE"
