#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr --host=$LX_TARGET
    make
}

install() {
    make DESTDIR=$LX_ROOTFS install
}

"$LX_STAGE"
