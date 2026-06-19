#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr                           \
                --docdir=/usr/share/doc/procps-ng-4.0.6 \
                --disable-static                        \
                --disable-kill                          \
                --enable-watch8bit
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}
