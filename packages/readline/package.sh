#!/usr/bin/env bash

build() {
    sed -i '/MV.*old/d' Makefile.in
    sed -i '/{OLDSUFF}/c:' support/shlib-install
    sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf

    sed -e '270a\
        else\
        chars_avail = 1;'      \
        -e '288i\   result = -1;' \
        -i.orig input.c

    ./configure --prefix=/usr    \
                --disable-static \
                --with-curses    \
                --docdir=/usr/share/doc/readline-8.3

    make SHLIB_LIBS="-lncursesw"
}

package() {
    make DESTDIR=$LX_ROOTFS install
}