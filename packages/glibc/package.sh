#!/usr/bin/env bash

build() {
    mkdir build && cd build
    echo "rootsbindir=/usr/sbin" > configparms

    ../configure                             \
          --prefix=/usr                      \
          --host=$LX_TARGET                  \
          --build=$(../scripts/config.guess) \
          --disable-nscd                     \
          libc_cv_slibdir=/usr/lib           \
          --enable-kernel=5.4

    make
}

install() {
    cd build
    make DESTDIR=$LX_ROOTFS install
    sed '/RTLDLIST=/s@/usr@@g' -i $LX_ROOTFS/usr/bin/ldd
}

"$LX_STAGE"
