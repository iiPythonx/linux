#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr
    make && make check
}

package() {
    make DESTDIR=$LX_ROOTFS install
    rm -fv /usr/lib/libz.a
}