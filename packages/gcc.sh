#!/usr/bin/sh

NAME="gcc"
VERSION="15.2.0"
SOURCE="https://ftp.gnu.org/gnu/gcc/gcc-${VERSION}/gcc-${VERSION}.tar.xz"
SHA256=""

build() {
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64

    mkdir build && cd build

    ../configure                    \
        --target=$COMPILE_TARGET    \
        --prefix=$SYSTEM_ROOT/tools \
        --with-glibc-version=2.42   \
        --with-sysroot=$LFS         \
        --with-newlib               \
        --without-headers           \
        --enable-default-pie        \
        --enable-default-ssp        \
        --disable-nls               \
        --disable-shared            \
        --disable-multilib          \
        --disable-threads           \
        --disable-libatomic         \
        --disable-libgomp           \
        --disable-libquadmath       \
        --disable-libssp            \
        --disable-libvtv            \
        --disable-libstdcxx         \
        --enable-languages=c,c++

    make
}

install() {
    make install
    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
        `dirname $($COMPILE_TARGET-gcc -print-libgcc-file-name)`/include/limits.h
}
