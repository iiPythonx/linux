#!/usr/bin/env bash

build() {
    if [[ -n "${LX_EXTRA_BOOTSTRAP}" ]]; then
        ./configure --prefix=/usr                      \
                    --build=$(sh support/config.guess) \
                    --host=$LX_TARGET                  \
                    --without-bash-malloc
    else
        ./configure --prefix=/usr             \
                    --without-bash-malloc     \
                    --with-installed-readline \
                    --docdir=/usr/share/doc/bash-5.3
    fi

    make
}

package() {
    make DESTDIR="$LX_ROOTFS" install
    [[ -n "${LX_EXTRA_BOOTSTRAP}" ]] && ln -sv bash "$LX_ROOTFS/usr/bin/sh"
    return 0
}