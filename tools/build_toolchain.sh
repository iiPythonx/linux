#!/usr/bin/env bash
# Copyright (c) 2026 iiPython

set -e
set -euo pipefail

# environment
ROOTFS="$(realpath rootfs)"
mkdir -p "$ROOTFS"

if [ -z "${LX_ENV:-}" ]; then
    SCRIPT="$(realpath $0)"
    exec env -i \
        LX_ENV=1 \
        PATH="$ROOTFS/toolchain/bin:$PATH" \
        ROOTFS="$ROOTFS" \
        LC_ALL=POSIX \
        CONFIG_SITE="$ROOTFS/usr/share/config.site" \
        MAKEFLAGS="-j$(nproc)" \
        bash --noprofile --norc "$SCRIPT" "$@"
fi

hash -r
set +h

# init
TARGET=x86_64-iipython-linux-gnu
TEMP="$(realpath temp)"

mkdir -p "$ROOTFS/toolchain"
mkdir -p "$TEMP" && cd "$TEMP"

# binutils
curl -O https://sourceware.org/pub/binutils/releases/binutils-2.46.1.tar.xz
tar -xf binutils-2.46.1.tar.xz && cd binutils-2.46.1
mkdir build && cd build

../configure --prefix=$ROOTFS/toolchain      \
            --with-sysroot=$ROOTFS           \
            --target=$TARGET                 \
            --disable-nls                    \
            --enable-gprofng=no              \
            --disable-werror                 \
            --enable-new-dtags               \
            --enable-default-hash-style=gnu

make && make install
cd $TEMP

# gcc
curl -O https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.2.tar.xz
curl -O https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz
curl -O https://ftp.gnu.org/gnu/mpc/mpc-1.4.1.tar.xz
curl -O https://ftp.gnu.org/gnu/gcc/gcc-16.1.0/gcc-16.1.0.tar.xz

tar -xf gcc-16.1.0.tar.xz && cd gcc-16.1.0
tar -xf ../mpfr-4.2.2.tar.xz
mv -v mpfr-4.2.2 mpfr
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.4.1.tar.xz
mv -v mpc-1.4.1 mpc

sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
mkdir build && cd build

../configure                     \
    --target=$TARGET             \
    --prefix=$ROOTFS/toolchain   \
    --with-glibc-version=2.43    \
    --with-sysroot=$ROOTFS       \
    --with-newlib                \
    --without-headers            \
    --enable-default-pie         \
    --enable-default-ssp         \
    --disable-nls                \
    --disable-shared             \
    --disable-multilib           \
    --disable-threads            \
    --disable-libatomic          \
    --disable-libgomp            \
    --disable-libquadmath        \
    --disable-libssp             \
    --disable-libvtv             \
    --disable-libstdcxx          \
    --enable-languages=c,c++

make && make install

cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($TARGET-gcc -print-libgcc-file-name)`/include/limits.h

cd $TEMP

# linux headers
curl -O https://www.kernel.org/pub/linux/kernel/v7.x/linux-7.0.12.tar.xz
tar -xf linux-7.0.12.tar.xz && cd linux-7.0.12

make mrproper
make headers

find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $ROOTFS/usr

cd $TEMP

# glibc
curl -O https://ftp.gnu.org/gnu/glibc/glibc-2.43.tar.xz
tar -xf glibc-2.43.tar.xz && cd glibc-2.43

ln -sfv $ROOTFS/lib/ld-linux-x86-64.so.2 $ROOTFS/lib64
ln -sfv $ROOTFS/lib/ld-linux-x86-64.so.2 $ROOTFS/lib64/ld-lsb-x86-64.so.3

mkdir build && cd build

../configure                             \
      --prefix=/usr                      \
      --host=$TARGET                     \
      --build=$(../scripts/config.guess) \
      --disable-nscd                     \
      libc_cv_slibdir=/usr/lib           \
      --enable-kernel=5.4

make && make DESTDIR=$ROOTFS install

sed '/RTLDLIST=/s@/usr@@g' -i $ROOTFS/usr/bin/ldd

cd $TEMP

# libstdc++
cd gcc-16.1.0
rm -rf build && mkdir build && cd build

../libstdc++-v3/configure      \
    --host=$TARGET             \
    --build=$(../config.guess) \
    --prefix=/usr              \
    --disable-multilib         \
    --disable-nls              \
    --disable-libstdcxx-pch    \
    --with-gxx-include-dir=/tools/$TARGET/include/c++/16.1.0

make && make DESTDIR=$ROOTFS install
rm -v $ROOTFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la
