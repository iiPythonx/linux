#!/usr/bin/env bash

build() {
    ./autogen.sh
    ./configure --prefix=/usr
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}
