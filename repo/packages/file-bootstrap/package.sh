#!/usr/bin/env bash

build() {
    mkdir build
    pushd build
    ../configure --disable-bzlib      \
                 --disable-libseccomp \
                 --disable-xzlib      \
                 --disable-zlib
    make
    popd
    ./configure --prefix=/usr --host=$LX_TARGET --build=$(./config.guess)
    make FILE_COMPILE=$(pwd)/build/src/file

}

package() {
    make DESTDIR=$LX_ROOTFS install
    rm -v $LX_ROOTFS/usr/lib/libmagic.la
}