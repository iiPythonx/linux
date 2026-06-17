#!/usr/bin/env bash

build() {
    sed '6031s/$add_dir//' -i ltmain.sh
    mkdir build && cd build
    ../configure                   \
        --prefix=/usr              \
        --build=$(../config.guess) \
        --host=$LX_TARGET          \
        --disable-nls              \
        --enable-shared            \
        --enable-gprofng=no        \
        --disable-werror           \
        --enable-64-bit-bfd        \
        --enable-new-dtags         \
        --enable-default-hash-style=gnu
    make
}

package() {
    cd build
    make DESTDIR=$LX_ROOTFS install
    rm -v $LX_ROOTFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}
}