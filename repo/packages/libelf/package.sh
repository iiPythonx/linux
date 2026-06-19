#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr        \
                --disable-debuginfod \
                --enable-libdebuginfod=dummy
    make -C lib
    make -C libelf
}

package() {
    make DESTDIR=$LX_ROOTFS -C libelf install
    install -vm644 config/libelf.pc /usr/lib/pkgconfig
    rm /usr/lib/libelf.a
}
