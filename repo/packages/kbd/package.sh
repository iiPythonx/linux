#!/usr/bin/env bash

build() {
    sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
    sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
    ./configure --prefix=/usr --disable-vlock
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}
