#!/usr/bin/sh

NAME="binutils"
VERSION="2.45"
SOURCE="https://sourceware.org/pub/binutils/releases/binutils-${VERSION}.tar.xz"
SHA256=""

build() {
    mkdir build && cd build

    ../configure --prefix=$SYSTEM_ROOT/tools \
             --with-sysroot=$SYSTEM_ROOT     \
             --target=$COMPILE_TARGET        \
             --disable-nls                   \
             --enable-gprofng=no             \
             --disable-werror                \
             --enable-new-dtags              \
             --enable-default-hash-style=gnu

    make
}

install() {
    make install
}
