#!/usr/bin/env bash

build() {
    if [[ -n "${LX_EXTRA_BOOTSTRAP}" ]]; then
        ./configure --prefix=/usr               \
                --localstatedir=/var/lib/locate \
                --host=$LX_TARGET               \
                --build=$(build-aux/config.guess)
    else
        ./configure --prefix=/usr --localstatedir=/var/lib/locate
    fi

    make
}

package() {
    make DESTDIR="$LX_ROOTFS" install
}
