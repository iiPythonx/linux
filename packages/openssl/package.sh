#!/usr/bin/env bash

build() {
    ./config --prefix=/usr        \
            --openssldir=/etc/ssl \
            --libdir=lib          \
            shared                \
            zlib-dynamic
    make
}

package() {
    make DESTDIR=$LX_ROOTFS INSTALL_LIBS= MANSUFFIX=ssl install
    mv -v /usr/share/doc/openssl /usr/share/doc/openssl-4.0.1
}