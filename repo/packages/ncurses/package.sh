#!/usr/bin/env bash

build() {
    CONFIG_OPTS=(
        --prefix=/usr
        --mandir=/usr/share/man
        --with-shared
        --without-debug
        --without-normal
        --with-cxx-shared
    )

    if [[ -n "${LX_EXTRA_BOOTSTRAP}" ]]; then
        CONFIG_OPTS+=(
                --host=$LX_TARGET
                --build=$(./config.guess)
                --with-manpage-format=normal
                --without-ada
                --disable-stripping
                AWK=gawk
        )
    else
        CONFIG_OPTS+=(
            --enable-pc-files
            --with-pkg-config-libdir=/usr/lib/pkgconfig
        )
    fi

    ./configure "${CONFIG_OPTS[@]}"
    make
}

package() {
    [[ -z "${LX_EXTRA_BOOTSTRAP}" ]] && LX_ROOTFS="$PWD/dest"

    make DESTDIR="$LX_ROOTFS" install
    sed -e 's/^#if.*XOPEN.*$/#if 1/' -i dest/usr/include/curses.h
    ln -sfv libncursesw.so $LX_ROOTFS/usr/lib/libcurses.so

    if [[ -z "${LX_EXTRA_BOOTSTRAP}" ]]; then
        cp --remove-destination -av dest/* /
        for lib in ncurses form panel menu ; do
            ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
            ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
        done
    fi
}
