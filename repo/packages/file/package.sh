#!/usr/bin/env bash

build() {
    if [[ -n "${LX_EXTRA_BOOTSTRAP}" ]]; then
        mkdir build && pushd build
        ../configure --disable-bzlib      \
                    --disable-libseccomp \
                    --disable-xzlib      \
                    --disable-zlib
        make && popd
        ./configure --prefix=/usr --host=$LX_TARGET --build=$(./config.guess)
        make FILE_COMPILE=$(pwd)/build/src/file
    else
        ./configure --prefix=/usr
        make
    fi
}

package() {
    make DESTDIR="$LX_ROOTFS" install
    [[ -n "${LX_EXTRA_BOOTSTRAP}" ]] && rm -v $LX_ROOTFS/usr/lib/libmagic.la
    return 0
}