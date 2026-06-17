#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr        \
                --disable-static     \
                --enable-thread-safe \
                --docdir=/usr/share/doc/mpfr-4.2.2
    make
    make html
    make check
    echo "Ensure all 198 tests passed, if not then abort now!"
    sleep 10
}

install() {
    make install
    make install-html
}

"$LX_STAGE"
