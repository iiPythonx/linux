#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr --localstatedir=/var/lib/locate
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}
