#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr    \
                --disable-static \
                --docdir=/usr/share/doc/xz-5.8.3
    make
}

install() {
    make install
}

"$LX_STAGE"
