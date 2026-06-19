#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.18.1
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}