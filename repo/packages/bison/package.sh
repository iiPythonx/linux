#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}