#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr    \
                --disable-static \
                --docdir=/usr/share/doc/mpc-1.4.1
    make
    make html
}

install() {
    make install
    make install-html
}

"$LX_STAGE"
