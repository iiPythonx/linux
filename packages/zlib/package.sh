#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr
    make && make check
}

install() {
    make DESTDIR=$LX_ROOTFS install
    rm -fv /usr/lib/libz.a
}

"$LX_STAGE"
