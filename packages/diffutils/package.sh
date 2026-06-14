#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr     \
                --host=$LX_TARGET \
                gl_cv_func_strcasecmp_works=y \
                --build=$(./build-aux/config.guess)
    make
}

install() {
    make DESTDIR=$LX_ROOTFS install
}

"$LX_STAGE"
