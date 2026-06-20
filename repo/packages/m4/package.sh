#!/usr/bin/env bash

build() {
    if [[ ! -z "${LX_EXTRA_BOOTSTRAP}" ]]; then
        ./configure --prefix=/usr \
            --host=$LX_TARGET     \
            --build=$(build-aux/config.guess)
    else
        ./configure --prefix=/usr
    fi

    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}
