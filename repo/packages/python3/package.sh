#!/usr/bin/env bash

build() {
    if [[ -n "${LX_EXTRA_BOOTSTRAP}" ]]; then
        ./configure --prefix=/usr       \
                    --enable-shared     \
                    --without-ensurepip \
                    --without-static-libpython
    else
        patch -Np1 -i ../patch/Python-3.14.6-openssl_4-1.patch
        ./configure --prefix=/usr          \
                    --enable-shared        \
                    --with-system-expat    \
                    --enable-optimizations \
                    --without-static-libpython
    fi

    make
}

package() {
    make DESTDIR="$LX_ROOTFS" install
}