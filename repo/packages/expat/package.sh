#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr    \
                --disable-static \
                --docdir=/usr/share/doc/expat-2.8.1
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}