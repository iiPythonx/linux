#!/usr/bin/env bash

build() {
    sed -i 's/extras//' Makefile.in

    if [[ -n "${LX_EXTRA_BOOTSTRAP}" ]]; then
        ./configure --prefix=/usr     \
                    --host=$LX_TARGET \
                    --build=$(build-aux/config.guess)
    else
        ./configure --prefix=/usr
    fi

    make
}

package() {
    if [[ -z "${LX_EXTRA_BOOTSTRAP}" ]]; then
        rm -f /usr/bin/gawk-5.4.0
        ln -sv gawk.1 /usr/share/man/man1/awk.1
    fi

    make DESTDIR="$LX_ROOTFS" install
}
