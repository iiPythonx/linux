#!/usr/bin/env bash

build() {
    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64

    if [[ -n "${LX_EXTRA_BOOTSTRAP}" ]]; then
        sed '/thread_header =/s/@.*@/gthr-posix.h/' -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in
        mv -v ../{mpfr,gmp,mpc} .
    fi

    mkdir build && cd build

    CONFIG_OPTS=(
        --prefix=/usr
        --enable-languages=c,c++
        --enable-default-pie
        --enable-default-ssp
        --enable-host-pie
        --disable-multilib
        --disable-fixincludes
    )

    if [[ -n "${LX_EXTRA_BOOTSTRAP}" ]]; then
        CONFIG_OPTS+=(
            --build=$(../config.guess)
            --host=$LX_TARGET
            --target=$LX_TARGET
            --disable-nls
            --disable-libatomic
            --disable-libgomp
            --disable-libquadmath
            --disable-libsanitizer
            --disable-libssp
            --disable-libvtv
            --with-build-sysroot=$LX_ROOTFS
            LDFLAGS_FOR_TARGET=-L$PWD/$LX_TARGET/libgcc
        )
    else
        CONFIG_OPTS+=(
            --disable-bootstrap
            --with-system-zlib
            LD=ld
        )
    fi

    ./configure "${CONFIG_OPTS[@]}"
    make
}

package() {
    cd build
    make DESTDIR="$LX_ROOTFS" install

    if [[ -n "${LX_EXTRA_BOOTSTRAP}" ]]; then
        ln -sv gcc $LX_ROOTFS/usr/bin/cc
    else
        ln -svr /usr/bin/cpp /usr/lib
        ln -sv gcc.1 /usr/share/man/man1/cc.1
        ln -sfvr $(gcc -print-prog-name=liblto_plugin.so) /usr/lib/bfd-plugins/
        mkdir -pv /usr/share/gdb/auto-load/usr/lib
        mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
    fi
}