#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr                \
                --host=$LX_TARGET            \
                --build=$(./config.guess)    \
                --mandir=/usr/share/man      \
                --with-manpage-format=normal \
                --with-shared                \
                --without-normal             \
                --with-cxx-shared            \
                --without-debug              \
                --without-ada                \
                --disable-stripping          \
                AWK=gawk
    make
}

install() {
    make DESTDIR=$LX_ROOTFS install
    ln -sv libncursesw.so $LX_ROOTFS/usr/lib/libncurses.so
    sed -e 's/^#if.*XOPEN.*$/#if 1/' \
        -i $LX_ROOTFS/usr/include/curses.h
}

"$LX_STAGE"
