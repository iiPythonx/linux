#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr    \
                --disable-static \
                --docdir=/usr/share/doc/acl-2.3.2
    make
}

install() {
    make install
}

"$LX_STAGE"
