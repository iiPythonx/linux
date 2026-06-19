#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}
