#!/usr/bin/env bash

build() {
    FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
    make -C doc install-html docdir=/usr/share/doc/tar-1.35
}
