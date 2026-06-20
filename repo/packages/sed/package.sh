#!/usr/bin/env bash

build() {
    if [[ -n "${LX_EXTRA_BOOTSTRAP}" ]]; then
        ./configure --prefix=/usr     \
                    --host=$LX_TARGET \
                    --build=$(./build-aux/config.guess)
        make
    else
        ./configure --prefix=/usr
        make
        make html
    fi
}

package() {
    make DESTDIR="$LX_ROOTFS" install
    [[ -z "${LX_EXTRA_BOOTSTRAP}" ]] && install -vDm644 doc/sed.html -t /usr/share/doc/sed-4.10
    return 0
}
