#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr     \
                --disable-static  \
                --sysconfdir=/etc \
                --docdir=/usr/share/doc/attr-2.5.2
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}