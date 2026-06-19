#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr             \
                --without-bash-malloc     \
                --with-installed-readline \
                --docdir=/usr/share/doc/bash-5.3
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}