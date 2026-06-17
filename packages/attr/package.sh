#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr     \
                --disable-static  \
                --sysconfdir=/etc \
                --docdir=/usr/share/doc/attr-2.5.2
    make
}

install() {
    make install
}

"$LX_STAGE"
