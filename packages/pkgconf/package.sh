#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr    \
                --disable-static \
                --docdir=/usr/share/doc/pkgconf-2.5.1
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
    ln -sv pkgconf   /usr/bin/pkg-config
    ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1
}