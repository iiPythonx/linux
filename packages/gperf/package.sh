#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.3
    make
}

package() {
    make DESTDIR=$LX_ROOTFS install
}