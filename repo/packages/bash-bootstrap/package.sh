#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr                      \
                --build=$(sh support/config.guess) \
                --host=$LX_TARGET                  \
                --without-bash-malloc
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
    ln -sv bash $LX_ROOTFS/usr/bin/sh
}