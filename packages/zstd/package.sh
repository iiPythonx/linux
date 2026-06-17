#!/usr/bin/env bash

build() {
    make prefix=/usr
}

install() {
    make prefix=/usr install
    rm -v /usr/lib/libzstd.a
}

"$LX_STAGE"
