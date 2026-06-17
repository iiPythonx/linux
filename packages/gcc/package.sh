#!/usr/bin/env bash

build() {
    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64

    mkdir build && cd build

    ../configure --prefix=/usr           \
                LD=ld                    \
                --enable-languages=c,c++ \
                --enable-default-pie     \
                --enable-default-ssp     \
                --enable-host-pie        \
                --disable-multilib       \
                --disable-bootstrap      \
                --disable-fixincludes    \
                --with-system-zlib

    make
}

package() {
    cd build
    make DESTDIR=$LX_ROOTFS install
    ln -svr /usr/bin/cpp /usr/lib
    ln -sv gcc.1 /usr/share/man/man1/cc.1
    ln -sfvr $(gcc -print-prog-name=liblto_plugin.so) /usr/lib/bfd-plugins/
    mkdir -pv /usr/share/gdb/auto-load/usr/lib
    mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
}