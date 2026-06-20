#!/usr/bin/env bash

build() {
    if [[ -n "${LX_EXTRA_BOOTSTRAP}" ]]; then
        ./configure --prefix=/usr     \
                    --host=$LX_TARGET \
                    --build=$(build-aux/config.guess)
    else
        FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr
    fi

    make
}

package() {
    make DESTDIR="$LX_ROOTFS" install
    [[ -z "${LX_EXTRA_BOOTSTRAP}" ]] && make -C doc install-html docdir=/usr/share/doc/tar-1.35
    return 0
}
