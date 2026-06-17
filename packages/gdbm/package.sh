#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr    \
                --disable-static \
                --enable-libgdbm-compat
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}
