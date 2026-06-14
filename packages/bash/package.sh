#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr                      \
                --build=$(sh support/config.guess) \
                --host=$LX_TARGET                  \
                --without-bash-malloc
    make
}

install() {
    make DESTDIR=$LX_ROOTFS install
    ln -sv $LX_ROOTFS/usr/bin/bash $LX_ROOTFS/usr/bin/sh
}

"$LX_STAGE"
