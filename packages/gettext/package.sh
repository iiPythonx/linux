#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr    \
                --disable-static \
                --docdir=/usr/share/doc/gettext-1.0
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
    chmod -v 0755 /usr/lib/preloadable_libintl.so
}