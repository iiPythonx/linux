#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr --sysconfdir=/etc
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}