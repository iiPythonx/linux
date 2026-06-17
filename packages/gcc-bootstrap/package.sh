#!/usr/bin/env bash

build() {
    mv -v ../{mpfr,gmp,mpc} .

    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
    sed '/thread_header =/s/@.*@/gthr-posix.h/' -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

    mkdir build && cd build

    ../configure                   \
        --build=$(../config.guess) \
        --host=$LX_TARGET          \
        --target=$LX_TARGET        \
        --prefix=/usr              \
        --enable-default-pie       \
        --enable-default-ssp       \
        --disable-nls              \
        --disable-multilib         \
        --disable-libatomic        \
        --disable-libgomp          \
        --disable-libquadmath      \
        --disable-libsanitizer     \
        --disable-libssp           \
        --disable-libvtv           \
        --disable-fixincludes      \
        --enable-languages=c,c++   \
        --with-build-sysroot=$LX_ROOTFS \
        LDFLAGS_FOR_TARGET=-L$PWD/$LX_TARGET/libgcc
    make
}

package() {
    cd build
    make DESTDIR=$LX_ROOTFS install
    ln -sv gcc $LX_ROOTFS/usr/bin/cc
}