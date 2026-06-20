#!/usr/bin/env bash

build() {
    if [[ -n "${LX_EXTRA_BOOTSTRAP}" ]]; then
        ./configure --prefix=/usr --host=$LX_TARGET
    else
        ./configure --prefix=/usr
    fi

    make
}

package() {
    make DESTDIR="$LX_ROOTFS" install
}
