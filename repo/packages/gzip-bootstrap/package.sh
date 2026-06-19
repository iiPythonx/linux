#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr --host=$LX_TARGET
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}