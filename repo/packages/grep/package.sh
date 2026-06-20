#!/usr/bin/env bash

build() {
    if [[ -n "${LX_EXTRA_BOOTSTRAP}" ]]; then
        ./configure --prefix=/usr     \
                    --host=$LX_TARGET \
                    --build=$(./build-aux/config.guess)
    else
        sed -i "s/echo/#echo/" src/egrep.sh
        ./configure --prefix=/usr
    fi

    make
}

package() {
    make DESTDIR="$LX_ROOTFS" install
}