#!/usr/bin/env bash

build() {
    ./configure \
        --disable-openssl \
        --disable-xxhash  \
        --disable-zstd    \
        --disable-lz4
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}