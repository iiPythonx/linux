#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr          \
                --enable-shared        \
                --with-system-expat    \
                --enable-optimizations \
                --without-static-libpython
    make
}

install() {
    make install
}

"$LX_STAGE"
