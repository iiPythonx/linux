#!/usr/bin/env bash

build() {
    CC='gcc -std=c99' ./configure --prefix=/usr -G -O3 -r
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}