#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr
    make
}

install() {
    make DESTDIR=$LX_ROOTFS install
}

"$LX_STAGE"
