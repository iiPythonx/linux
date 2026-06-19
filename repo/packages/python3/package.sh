#!/usr/bin/env bash

build() {
    patch -Np1 -i ../python-patch/Python-3.14.6-openssl_4-1.patch

    ./configure --prefix=/usr          \
                --enable-shared        \
                --with-system-expat    \
                --enable-optimizations \
                --without-static-libpython
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}