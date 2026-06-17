#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr    \
                --disable-static \
                --docdir=/usr/share/doc/mpc-1.4.1
    make
    make html
}

package() {
    make DESTDIR=$LX_ROOTFS install
    make DESTDIR=$LX_ROOTFS install-html
}