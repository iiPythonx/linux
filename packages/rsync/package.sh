#!/usr/bin/env bash

build() {
    ./configure \
        --disable-openssl \
        --disable-xxhash  \
        --disable-zstd    \
        --disable-lz4
    make
}

install() {
    make install
}

"$LX_STAGE"
