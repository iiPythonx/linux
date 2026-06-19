#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr    \
                --disable-static \
                --with-gcc-arch=native
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}