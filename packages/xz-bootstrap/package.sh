#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr                     \
                --host=$LX_TARGET                 \
                --build=$(build-aux/config.guess) \
                --disable-static                  \
                --docdir=/usr/share/doc/xz-5.8.3
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
    rm -v $LX_ROOTFS/usr/lib/liblzma.la
}