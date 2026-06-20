#!/usr/bin/env bash

build() {
    if [[ ! -z "${LX_EXTRA_BOOTSTRAP}" ]]; then
        ./configure --prefix=/usr                     \
                    --host=$LX_TARGET                 \
                    --build=$(build-aux/config.guess) \
                    --disable-static                  \
                    --docdir=/usr/share/doc/xz-5.8.3
    else
        ./configure --prefix=/usr    \
                    --disable-static \
                    --docdir=/usr/share/doc/xz-5.8.3
    fi

    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
    [[ -n "${LX_EXTRA_BOOTSTRAP}" ]] && rm -v $LX_ROOTFS/usr/lib/liblzma.la
    return 0
}