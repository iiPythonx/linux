#!/usr/bin/env bash

build() {
    sed -i 's/extras//' Makefile.in
    ./configure --prefix=/usr     \
                --host=$LX_TARGET \
                --build=$(build-aux/config.guess)
    make
}

install() {
    make DESTDIR=$LX_ROOTFS install
}

"$LX_STAGE"
